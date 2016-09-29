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

    def last_n_days
      env.fetch("LAST_N_DAYS", 7)
    end

    def output_stream
      name = env.fetch("DEBUG_STREAM", "stdout")
      name = name.downcase.to_sym

      { stdout: $stdout, stderr: $stderr, none: nil }.fetch(name)
    end
  end
end
