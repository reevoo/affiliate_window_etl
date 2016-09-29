class AffiliateWindow::ETL
  class Schema
    def migrate
      ActiveRecord::Schema.define do
        create_table :merchants do |t|
          t.string :name
          t.string :display_url
          t.string :click_through_url
          t.string :primary_region_name
          t.string :primary_region_country_code
          t.string :primary_region_currency_code
          t.string :logo_url
          t.string :feed_modified
          t.string :strapline
          t.text :description
          t.string :approval_percentage
          t.string :epc
          t.string :conversion_rate
          t.integer :validation_days
          t.string :awin_grade
          t.string :commission_ranges_commission_range_type
          t.string :commission_ranges_commission_range_min
          t.string :commission_ranges_commission_range_max
          t.integer :sectors_merchant_sector_sector_id
          t.string :sectors_merchant_sector_sector_name
          t.string :details_version
          t.string :details_modified
          t.string :feed_version
          t.timestamps
        end

        create_table :commission_ranges do |t|
          t.integer :merchant_id
          t.string :type
          t.string :min
          t.string :max
          t.timestamps
        end

        create_table :merchant_sectors do |t|
          t.integer :merchant_id
          t.integer :sector_id
          t.string :sector_name
          t.timestamps
        end

        create_table :commission_groups do |t|
          t.integer :merchant_id
          t.string :commission_group_code
          t.string :commission_group_name
          t.string :amount_amount
          t.string :amount_currency
          t.string :percentage
          t.timestamps
        end

        create_table :transactions do |t|
          t.string :type
          t.string :status
          t.string :declined_reason
          t.string :ip
          t.boolean :paid
          t.integer :payment_id
          t.integer :merchant_id
          t.string :sale_amount_amount
          t.string :sale_amount_currency
          t.string :commission_amount_amount
          t.string :commission_amount_currency
          t.string :clickref
          t.datetime :click_date
          t.datetime :transaction_date
          t.datetime :validation_date
          t.timestamps
        end

        create_table :transaction_parts do |t|
          t.integer :transaction_id
          t.string :commission_group_name
          t.string :sale_amount_amount
          t.string :sale_amount_currency
          t.string :commission_amount_amount
          t.string :commission_amount_currency
          t.string :commission
          t.string :commission_type
          t.timestamps
        end

        create_table :transaction_products, id: false do |t|
          t.string :id, primary_key: true
          t.integer :transaction_id
          t.string :name
          t.string :unit_price_amount
          t.string :unit_price_currency
          t.timestamps
        end

        create_table :click_stats do |t|
          t.timestamp :date
          t.string :merchant_name
          t.string :link_name
          t.string :link_type
          t.integer :pending_count
          t.string :pending_value_amount
          t.string :pending_value_currency
          t.string :pending_commission_amount
          t.string :pending_commission_currency
          t.integer :confirmed_count
          t.string :confirmed_value_amount
          t.string :confirmed_value_currency
          t.string :confirmed_commission_amount
          t.string :confirmed_commission_currency
          t.integer :declined_count
          t.string :declined_value_amount
          t.string :declined_value_currency
          t.string :declined_commission_amount
          t.string :declined_commission_currency
          t.integer :clicks
          t.timestamps
        end

        create_table :impression_stats do |t|
          t.timestamp :date
          t.string :merchant_name
          t.string :link_name
          t.string :link_type
          t.integer :pending_count
          t.string :pending_value_amount
          t.string :pending_value_currency
          t.string :pending_commission_amount
          t.string :pending_commission_currency
          t.integer :confirmed_count
          t.string :confirmed_value_amount
          t.string :confirmed_value_currency
          t.string :confirmed_commission_amount
          t.string :confirmed_commission_currency
          t.integer :declined_count
          t.string :declined_value_amount
          t.string :declined_value_currency
          t.string :declined_commission_amount
          t.string :declined_commission_currency
          t.integer :impressions
          t.timestamps
        end

        Database::MODELS.each do |record_type, model|
          table_name = "#{record_type}s"
          index_name = "#{record_type}_identity"

          add_index table_name, model.identity, unique: true, name: index_name
        end

        add_index :transactions, :status
        add_index :transactions, :paid
        add_index :transactions, :merchant_id
        add_index :transactions, :clickref
        add_index :transactions, :click_date
        add_index :transactions, :transaction_date
        add_index :transactions, :validation_date
        add_index :transaction_parts, :transaction_id
        add_index :transaction_products, :transaction_id
      end
    end
  end
end
