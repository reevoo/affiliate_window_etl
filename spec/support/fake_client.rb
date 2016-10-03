class FakeClient
  attr_accessor :rows_returned

  def initialize
    self.rows_returned = 1
  end

  def get_merchant_list # rubocop:disable Style/AccessorMethodName
    { merchant: [{ i_id: 123 }, { i_id: 456 }] }
  end

  def get_merchant(params)
    merchant_ids = params.fetch(:merchant_ids)

    data = {
      123 => { s_name: "Apple" },
      456 => { s_name: "Google" },
    }

    { merchant: merchant_ids.map { |id| data.fetch(id) } }
  end

  def get_commission_group_list(_params)
    {
      commission_group: [
        { commission_group_name: "foo" },
      ],
    }
  end

  def get_transaction_list(params)
    start_date = params.fetch(:start_date)

    {
      results: {
        transaction: [
          { i_id: 111, d_click_date: start_date },
        ],
      },
      pagination: {
        i_rows_available: 1,
        i_rows_returned: rows_returned,
      },
    }
  end

  def get_transaction(params)
    transaction_ids = params.fetch(:transaction_ids)
    transactions = transaction_ids.map { |id| { i_id: id } }

    { transaction: transactions }
  end

  def get_transaction_product(params)
    transaction_ids = params.fetch(:transaction_ids)
    products = transaction_ids.map { |id| { name: "iPhone #{id}" } }
    products = products.first if products.size == 1

    { transaction_product: products }
  end

  def get_click_stats(_params)
    {
      results: {
        click_stats: [
          { i_clicks: 123 },
        ],
      },
      pagination: {
        i_rows_available: 1,
        i_rows_returned: 1,
      },
    }
  end

  def get_impression_stats(_params)
    {
      results: {
        impression_stats: [
          { i_impressions: 456 },
        ],
      },
      pagination: {
        i_rows_available: 1,
        i_rows_returned: 1,
      },
    }
  end
end
