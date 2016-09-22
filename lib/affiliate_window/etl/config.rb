class AffiliateWindow::ETL
  class Config
    attr_accessor :env

    def initialize(env:)
      self.env = env
    end

    def account_id
      env.fetch("ACCOUNT_ID", 1234)
    end

    def affiliate_api_password
      env.fetch("AFFILIATE_API_PASSWORD", "password")
    end

    def fluentd_socket
      env.fetch("FLUENTD_SOCKET", "/tmp/affwin.sock")
    end

    def postgres_host
      env.fetch("POSTGRES_HOST", "localhost")
    end

    def postgres_port
      env.fetch("POSTGRES_PORT", 5432)
    end

    def postgres_database
      env.fetch("POSTGRES_DATABASE", "affiliate_window")
    end

    def postgres_username
      env.fetch("POSTGRES_USERNAME", `whoami`.strip)
    end

    def postgres_password
      env.fetch("POSTGRES_PASSWORD", "")
    end

    def start_date
      one_week_ago = (Date.today - 7).to_s
      Date.parse(env.fetch("START_DATE", one_week_ago))
    end

    def end_date
      yesterday = (Date.today - 1).to_s
      Date.parse(env.fetch("END_DATE", yesterday))
    end

    def output_stream
      name = env.fetch("DEBUG_STREAM", "stdout")
      name = name.downcase.to_sym

      { stdout: $stdout, stderr: $stderr, none: nil }.fetch(name)
    end
  end
end
