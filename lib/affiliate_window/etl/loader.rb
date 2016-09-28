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
      identity = attributes.slice(*model.identity)

      if (record = model.find_by(identity))
        record.update!(attributes)
      else
        model.create!(attributes)
      end
    end
  end
end
