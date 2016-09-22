require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Loader do
  let(:logger) { FakeLogger.new }
  subject { described_class.new(logger: logger) }

  it "routes records according to record_type" do
    subject.load(record_type: :merchant, foo: 1)
    subject.load(record_type: :transaction, foo: 2)
    subject.load(record_type: :merchant, foo: 3)

    expect(logger.messages).to eq [
      { tag: "affwin.merchants", record: { foo: 1 } },
      { tag: "affwin.transactions", record: { foo: 2 } },
      { tag: "affwin.merchants", record: { foo: 3 } },
    ]
  end
end
