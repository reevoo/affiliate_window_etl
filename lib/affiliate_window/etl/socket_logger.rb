# TODO: extract from this repository
class AffiliateWindow::ETL
  class SocketLogger
    def initialize(path)
      @path = path
    end

    def post(tag, record)
      @count ||= 0
      send([tag, Time.now.to_i, record])
      @count = 0
    rescue Errno::EPIPE
      backoff("Pipe error, reconnecting")
      @socket = nil
      retry
    rescue Errno::ECONNREFUSED, Errno::ENOENT
      backoff("Connection Error, retrying")
      retry
    end

    private

    def backoff(msg)
      $stderr.puts msg if @count == 0
      $stderr.print "."
      @count += 1
      sleep @count**2
    end

    def send(message)
      socket.send(message.to_msgpack, 0)
    rescue NoMethodError
      socket.send(JSON.parse(JSON.generate(message)).to_msgpack, 0)
    end

    attr_reader :path, :tag

    def socket
      @socket ||= UNIXSocket.new(path)
    end
  end
end
