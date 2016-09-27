class AffiliateWindow::ETL
  class Schema
    def tables
      [
        Table.new(
          name: :merchants,
          columns: {
            id: integer_type,
            name: string_type,
            display_url: string_type,
            click_through_url: string_type,
            primary_region_name: string_type,
            primary_region_country_code: string_type,
            primary_region_currency_code: string_type,
            logo_url: string_type,
            feed_modified: string_type,
            strapline: string_type,
            description: string_type(10_000),
            approval_percentage: string_type,
            epc: string_type,
            conversion_rate: string_type,
            validation_days: integer_type,
            awin_grade: string_type,
            commission_ranges_commission_range_type: string_type,
            commission_ranges_commission_range_min: string_type,
            commission_ranges_commission_range_max: string_type,
            sectors_merchant_sector_sector_id: integer_type,
            sectors_merchant_sector_sector_name: string_type,
            details_version: string_type,
            details_modified: string_type,
            feed_version: string_type,
          },
        ),
        Table.new(
          name: :commission_ranges,
          columns: {
            merchant_id: integer_type,
            type: string_type,
            min: string_type,
            max: string_type,
          },
        ),
        Table.new(
          name: :merchant_sectors,
          columns: {
            merchant_id: integer_type,
            sector_id: integer_type,
            sector_name: string_type,
          },
        ),
        Table.new(
          name: :commission_groups,
          columns: {
            merchant_id: integer_type,
            commission_group_code: string_type,
            commission_group_name: string_type,
            amount_amount: string_type,
            amount_currency: string_type,
            percentage: string_type,
          },
        ),
        Table.new(
          name: :transactions,
          columns: {
            id: integer_type,
            status: string_type,
            type: string_type,
            ip: string_type,
            paid: boolean_type,
            payment_id: integer_type,
            merchant_id: integer_type,
            sale_amount_amount: string_type,
            sale_amount_currency: string_type,
            commission_amount_amount: string_type,
            commission_amount_currency: string_type,
            click_date: timestamp_type,
            transaction_date: timestamp_type,
            clickref: string_type,
            validation_date: string_type,
            declined_reason: string_type,
          },
        ),
        Table.new(
          name: :transaction_parts,
          columns: {
            transaction_id: integer_type,
            commission_group_name: string_type,
            sale_amount_amount: string_type,
            sale_amount_currency: string_type,
            commission_amount_amount: string_type,
            commission_amount_currency: string_type,
            commission: string_type,
            commission_type: string_type,
          },
        ),
        Table.new(
          name: :transaction_products,
          columns: {
            id: bigint_type,
            transaction_id: integer_type,
            name: string_type,
            unit_price_amount: string_type,
            unit_price_currency: string_type,
          },
        ),
        Table.new(
          name: :click_stats,
          columns: {
            link_name: string_type,
            link_type: string_type,
            merchant_name: string_type,
            pending_count: integer_type,
            pending_value_amount: string_type,
            pending_value_currency: string_type,
            pending_commission_amount: string_type,
            pending_commission_currency: string_type,
            confirmed_count: integer_type,
            confirmed_value_amount: string_type,
            confirmed_value_currency: string_type,
            confirmed_commission_amount: string_type,
            confirmed_commission_currency: string_type,
            declined_count: integer_type,
            declined_value_amount: string_type,
            declined_value_currency: string_type,
            declined_commission_amount: string_type,
            declined_commission_currency: string_type,
            clicks: integer_type,
          },
        ),
        Table.new(
          name: :impression_stats,
          columns: {
            link_name: string_type,
            link_type: string_type,
            merchant_name: string_type,
            pending_count: integer_type,
            pending_value_amount: string_type,
            pending_value_currency: string_type,
            pending_commission_amount: string_type,
            pending_commission_currency: string_type,
            confirmed_count: integer_type,
            confirmed_value_amount: string_type,
            confirmed_value_currency: string_type,
            confirmed_commission_amount: string_type,
            confirmed_commission_currency: string_type,
            declined_count: integer_type,
            declined_value_amount: string_type,
            declined_value_currency: string_type,
            declined_commission_amount: string_type,
            declined_commission_currency: string_type,
            impressions: integer_type,
          },
        ),
      ]
    end

    def to_sql
      sql = ""

      tables.each do |table|
        sql += "CREATE TABLE #{table.name} (\n"
        sql += table.sql_definition
        sql += "\n);\n"
      end

      sql
    end

    private

    def integer_type
      "integer"
    end

    def bigint_type
      "bigint"
    end

    def string_type(size = 255)
      "varchar(#{size})"
    end

    def boolean_type
      "boolean"
    end

    def timestamp_type
      "timestamp with time zone"
    end

    class Table
      attr_accessor :name, :columns

      def initialize(name:, columns:)
        self.name = name
        self.columns = columns
      end

      def sql_definition
        columns.map { |name, type| "  #{name} #{type}" }.join(",\n")
      end
    end
  end
end
