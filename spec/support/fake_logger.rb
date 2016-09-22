class FakeLogger
  attr_accessor :messages

  def initialize
    self.messages = []
  end

  def post(tag, record)
    messages.push(tag: tag, record: record)
  end
end
