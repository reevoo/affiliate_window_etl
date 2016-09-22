require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Interval do
  subject do
    described_class.new(
      from: Date.new(2016, 1, 1),
      to: Date.new(2016, 1, 3),
    )
  end

  describe "#each_day" do
    it "can iterates through the interval one day at a time" do
      calls = []

      subject.each_day do |from, to|
        calls.push(from: from, to: to)
      end

      expect(calls).to eq [
        { from: "2016-01-01T00:00:00", to: "2016-01-01T23:59:59" },
        { from: "2016-01-02T00:00:00", to: "2016-01-02T23:59:59" },
        { from: "2016-01-03T00:00:00", to: "2016-01-03T23:59:59" },
      ]
    end
  end
end
