class AffiliateWindow
  class ETL
    attr_accessor :config, :logger

    def initialize(env: ENV, logger: nil)
      self.config = Config.new(env: env)
      self.logger = logger || config.logger
    end

    def run
      database.connect!

      scheduler.jobs.each do |job|
        extracter.extract(job.type, job.args).each do |record|
          transformer.transform(record).each do |transformed_record|
            loader.load(transformed_record)
          end
        end
      end
    end

    def migrate
      database.connect!
      ActiveRecord::Migrator.migrate("db/migrate")
    end

    def migration_filenames
      path = File.expand_path("../../../db/migrate/*", File.dirname(__FILE__))
      Dir[path].each
    end

    private

    def scheduler
      Scheduler.new(
        database: database,
        last_n_days: config.last_n_days,
      )
    end

    def extracter
      Extracter.new(
        client: client,
        logger: logger,
      )
    end

    def transformer
      Transformer.new(normaliser: normaliser)
    end

    def loader
      Loader.new(database: database)
    end

    def database
      Database.new(config.database_url)
    end

    def client
      AffiliateWindow.login(
        account_id: config.account_id,
        affiliate_api_password: config.affiliate_api_password,
      )
    end

    def schema
      Schema.new
    end

    def normaliser
      Normaliser.new
    end

    def migrator
      Migrator.new
    end
  end
end
