class AffiliateWindow::ETL
  class Loader
    attr_accessor :database

    def initialize(database:)
      self.database = database
    end

    def load(attributes)
      record_type = attributes.delete(:record_type)
      attributes.delete_if { |_, v| v.nil? }

      model = database.model(record_type)
      model.create!(attributes)
    end
  end
end
