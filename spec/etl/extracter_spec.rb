require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Extracter do
  let(:client) { FakeClient.new }

  subject { described_class.new(client: client) }

  it "extracts merchants and their commission groups" do
    enumerator = subject.extract(:merchants)
    records = enumerator.to_a

    expect(records).to eq [
      { record_type: :merchant, s_name: "Apple" },
      { record_type: :merchant, s_name: "Google" },
      { record_type: :commission_group, merchant_id: 123, commission_group_name: "foo" },
      { record_type: :commission_group, merchant_id: 456, commission_group_name: "foo" },
    ]
  end

  it "extracts daily transactions" do
    enumerator = subject.extract(:daily_transactions, date: "2016-01-01")
    records = enumerator.to_a

    expect(records).to eq [
      { record_type: :transaction, i_id: 111, d_click_date: "2016-01-01T00:00:00" },
      { record_type: :transaction_product, name: "iPhone 7" },
    ]
  end

  it "extracts daily clicks" do
    enumerator = subject.extract(:daily_clicks, date: "2016-01-01")
    records = enumerator.to_a

    expect(records).to eq [
      { record_type: :click_stat, i_clicks: 123 },
    ]
  end

  it "extracts daily impressions" do
    enumerator = subject.extract(:daily_impressions, date: "2016-01-01")
    records = enumerator.to_a

    expect(records).to eq [
      { record_type: :impression_stat, i_impressions: 456 },
    ]
  end

  it "raises an error if not all of the records have been returned" do
    client.rows_returned = 0
    enumerator = subject.extract(:daily_transactions, date: "2016-01-01")

    expect {
      enumerator.to_a
    }.to raise_error(/0 retrieved out of 1/)
  end

  it "can be provided with an optional output stream to log behaviour" do
    output = StringIO.new

    subject = described_class.new(client: client, output: output)

    enumerator = subject.extract(:merchants, date: "2016-01-01")
    enumerator.to_a

    expect(output.string).to match(%r{Extracted 2 / 2 merchants})
  end
end
