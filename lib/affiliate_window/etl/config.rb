class AffiliateWindow
  class ETL
    class Config
      attr_accessor :env

      def initialize(env:)
        self.env = env
      end

      def database_url
        env.fetch(
          "DATABASE_URL",
          "postgres://#{`whoami`.strip}@localhost:5432/affiliate_window?pool=5&encoding=unicode",
        )
      end

      def account_id
        env.fetch("ACCOUNT_ID", 1234)
      end

      def affiliate_api_password
        env.fetch("AFFILIATE_API_PASSWORD", "password")
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
end
