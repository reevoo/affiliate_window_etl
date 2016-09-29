class AffiliateWindow
  class ETL
    class Extracter # rubocop:disable Metrics/ClassLength
      CHUNK_SIZE = 100

      attr_accessor :client, :output

      def initialize(client:, output: nil)
        self.client = client
        self.output = output
      end

      def extract(type, params = {})
        Enumerator.new do |yielder|
          public_send("extract_#{type}", yielder, params)
        end
      end

      def extract_merchants(yielder, _params) # rubocop:disable Metrics/AbcSize
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

        extract_commission_groups(yielder, merchant_ids: merchant_ids)
      end

      def extract_commission_groups(yielder, merchant_ids:)
        merchant_ids.each.with_index do |id, index|
          maybe_response = catch_invalid_relationship_error do
            client.get_commission_group_list(merchant_id: id)
          end

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

      def extract_daily_transactions(yielder, date:)
        response = client.get_transaction_list(
          start_date: "#{date}T00:00:00",
          end_date: "#{date}T23:59:59",
          date_type: "transaction",
        )
        results = response.fetch(:results)
        pagination = response.fetch(:pagination)

        check_all_records_received!(pagination)

        transactions = results.fetch(:transaction)
        transactions.each do |record|
          yielder.yield(record.merge(record_type: :transaction))
        end

        write "Extracted #{transactions.count} transactions for #{date}"

        transaction_ids = transactions.map { |t| t.fetch(:i_id) }
        extract_transaction_products(yielder, transaction_ids: transaction_ids)
      end

      def extract_transactions(yielder, transaction_ids:)
        count = 0
        transaction_ids.each_slice(CHUNK_SIZE) do |ids|
          response = client.get_transaction(transaction_ids: ids)

          transactions = response.fetch(:transaction)
          transactions.each do |record|
            yielder.yield(record.merge(record_type: :transaction))
          end

          count += [CHUNK_SIZE, ids.count].min
          write "Extracted #{count} / #{transaction_ids.count} transactions"
        end

        extract_transaction_products(yielder, transaction_ids: transaction_ids)
      end

      def extract_transaction_products(yielder, transaction_ids:)
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

      def extract_daily_clicks(yielder, date:)
        response = client.get_click_stats(
          start_date: "#{date}T00:00:00",
          end_date: "#{date}T23:59:59",
          date_type: "transaction",
        )
        results = response.fetch(:results)
        pagination = response.fetch(:pagination)

        check_all_records_received!(pagination)

        click_stats = results.fetch(:click_stats)
        click_stats.each do |record|
          yielder.yield(record.merge(
            record_type: :click_stat,
            date: date,
          ))
        end

        write "Extracted #{click_stats.count} click stats for #{date}"
      end

      def extract_daily_impressions(yielder, date:)
        response = client.get_impression_stats(
          start_date: "#{date}T00:00:00",
          end_date: "#{date}T23:59:59",
          date_type: "transaction",
        )
        results = response.fetch(:results)
        pagination = response.fetch(:pagination)

        check_all_records_received!(pagination)

        impression_stats = results.fetch(:impression_stats)
        impression_stats.each do |record|
          yielder.yield(record.merge(
            record_type: :impression_stat,
            date: date,
          ))
        end

        write "Extracted #{impression_stats.count} impression stats for #{date}"
      end

      def check_all_records_received!(pagination)
        retrieved = pagination.fetch(:i_rows_returned)
        total = pagination.fetch(:i_rows_available)

        fail "Did not receive all records: #{retrieved} retrieved out of #{total}" unless total == retrieved
      end

      # If the current account is not affiliated with the merchant, the API does
      # not let you retrieve commission groups for that merchant.
      def catch_invalid_relationship_error(&block)
        block.call
      rescue AffiliateWindow::Error => e
        raise unless e.message.match(/Invalid merchant \/ affiliate relationship/)
        nil
      end

      def write(message)
        return unless output
        output.puts(message)
      end
    end
  end
end
