require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Loader do
  let(:database) { FakeDatabase.new }
  subject { described_class.new(database: database) }

  it "routes records according to record_type" do
    subject.load(record_type: :merchant, foo: 1)
    subject.load(record_type: :transaction, foo: 2)
    subject.load(record_type: :merchant, foo: 3)

    expect(database.messages).to eq [
      { record_type: :merchant, attributes: { foo: 1 } },
      { record_type: :transaction, attributes: { foo: 2 } },
      { record_type: :merchant, attributes: { foo: 3 } },
    ]
  end
end
