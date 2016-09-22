class AffiliateWindow::ETL
  class Loader
    attr_accessor :logger

    def initialize(logger:)
      self.logger = logger
    end

    def load(record)
      table_name = record.fetch(:record_type)
      record.delete(:record_type)
      fluentd_tag = "affwin.#{table_name}s"

      logger.post(fluentd_tag, record)
    end
  end
end
