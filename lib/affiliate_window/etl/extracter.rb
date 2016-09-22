class AffiliateWindow::ETL
  class Extracter
    CHUNK_SIZE = 100

    attr_accessor :client, :interval, :output

    def initialize(client:, interval:, output: nil)
      self.client = client
      self.interval = interval
      self.output = output
    end

    def extract
      Enumerator.new do |yielder|
        extract_merchants(yielder)
        extract_transactions(yielder)
        extract_click_stats(yielder)
        extract_impression_stats(yielder)
      end
    end

    private

    def extract_merchants(yielder)
      response = client.get_merchant_list
      merchants = response.fetch(:merchant)
      merchant_ids = merchants.map { |m| m.fetch(:i_id) }

      count = 0
      merchant_ids.each_slice(CHUNK_SIZE) do |ids|
        response = client.get_merchant(merchant_ids: ids)
        merchants = response.fetch(:merchant)

        merchants.each do |record|
          yielder.yield(record.merge(record_type: :merchant))
        end

        count += [CHUNK_SIZE, ids.count].min
        write "Extracted #{count} / #{merchant_ids.count} merchants"
      end

      extract_commission_groups(merchant_ids, yielder)
    end

    def extract_commission_groups(merchant_ids, yielder)
      merchant_ids.each.with_index do |id, index|
        maybe_response = catch_invalid_relationship_error {
          client.get_commission_group_list(merchant_id: id)
        }

        next unless maybe_response
        response = maybe_response

        commission_groups = [response.fetch(:commission_group)].flatten

        commission_groups.each do |record|
          yielder.yield(record.merge(
            record_type: :commission_group,
            merchant_id: id,
          ))
        end

        write "Extracted commission groups for #{index + 1} / #{merchant_ids.count} merchants"
      end
    end

    def extract_transactions(yielder)
      transaction_ids = []

      interval.each_day do |start_of_day, end_of_day|
        response = client.get_transaction_list(
          start_date: start_of_day,
          end_date: end_of_day,
          date_type: "transaction",
        )
        results = response.fetch(:results)
        pagination = response.fetch(:pagination)

        check_all_records_received!(pagination)

        transactions = results.fetch(:transaction)
        transactions.each do |record|
          yielder.yield(record.merge(record_type: :transaction))
        end

        transaction_ids += transactions.map { |t| t.fetch(:i_id) }

        write "Extracted #{transactions.count} transactions for #{start_of_day}"
      end

      extract_transaction_products(transaction_ids, yielder)
    end

    def extract_transaction_products(transaction_ids, yielder)
      count = 0
      transaction_ids.each_slice(CHUNK_SIZE) do |ids|
        response = client.get_transaction_product(transaction_ids: ids)
        transaction_products = response.fetch(:transaction_product)

        transaction_products.each do |record|
          yielder.yield(record.merge(record_type: :transaction_product))
        end

        count += [CHUNK_SIZE, ids.count].min
        write "Extracted #{transaction_products.count} products for #{count} / #{transaction_ids.count} transactions"
      end
    end

    def extract_click_stats(yielder)
      interval.each_day do |start_of_day, end_of_day|
        response = client.get_click_stats(
          start_date: start_of_day,
          end_date: end_of_day,
          date_type: "transaction",
        )
        results = response.fetch(:results)
        pagination = response.fetch(:pagination)

        check_all_records_received!(pagination)

        click_stats = results.fetch(:click_stats)
        click_stats.each do |record|
          yielder.yield(record.merge(record_type: :click_stat))
        end

        write "Extracted #{click_stats.count} click stats for #{start_of_day}"
      end
    end

    def extract_impression_stats(yielder)
      interval.each_day do |start_of_day, end_of_day|
        response = client.get_impression_stats(
          start_date: start_of_day,
          end_date: end_of_day,
          date_type: "transaction",
        )
        results = response.fetch(:results)
        pagination = response.fetch(:pagination)

        check_all_records_received!(pagination)

        impression_stats = results.fetch(:impression_stats)
        impression_stats.each do |record|
          yielder.yield(record.merge(record_type: :impression_stat))
        end

        write "Extracted #{impression_stats.count} impression stats for #{start_of_day}"
      end
    end

    def check_all_records_received!(pagination)
      retrieved = pagination.fetch(:i_rows_returned)
      total = pagination.fetch(:i_rows_available)

      unless total == retrieved
        raise "Did not receive all records: #{retrieved} retrieved out of #{total}"
      end
    end

    # If the current account is not affiliated with the merchant, the API does
    # not let you retrieve commission groups for that merchant.
    def catch_invalid_relationship_error(&block)
      begin
        block.call
      rescue AffiliateWindow::Error => e
        raise unless e.message.match(%r{Invalid merchant / affiliate relationship})
        nil
      end
    end

    def write(message)
      return unless output
      output.puts(message)
    end
  end
end
