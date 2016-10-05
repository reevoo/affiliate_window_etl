class CreateIndexes < ActiveRecord::Migration[5.0]
  MODELS = AffiliateWindow::ETL::Database::MODELS

  def change
    MODELS.each do |record_type, model|
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
