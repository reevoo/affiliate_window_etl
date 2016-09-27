class FakeDatabase
  attr_accessor :messages

  def initialize
    self.messages = []
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
  end
end
