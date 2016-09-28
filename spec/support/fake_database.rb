class FakeDatabase
  attr_accessor :messages, :filters

  def initialize
    self.messages = []
    self.filters = []
  end

  def model(record_type)
    FakeModel.new(record_type, self)
  end

  class FakeModel
    attr_accessor :record_type, :database

    def initialize(record_type, database)
      self.record_type = record_type
      self.database = database
    end

    def create!(attributes)
      database.messages.push(
        record_type: record_type,
        attributes: attributes,
      )
    end

    def where(*args)
      database.filters.push(args)
      self
    end

    def pluck(*args)
      [3, 5]
    end
  end
end
