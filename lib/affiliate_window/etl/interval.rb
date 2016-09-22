class AffiliateWindow::ETL
  class Interval
    attr_accessor :from, :to

    def initialize(from:, to:)
      self.from = from
      self.to = to
    end

    def each_day(&block)
      (from..to).each do |date|
        block.call(
          "#{date.to_s}T00:00:00",
          "#{date.to_s}T23:59:59",
        )
      end
    end
  end
end
