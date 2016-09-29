class AffiliateWindow::ETL
  attr_accessor :config

  def initialize(env: ENV)
    self.config = Config.new(env: env)
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

    schema.migrate
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
      output: config.output_stream,
    )
  end

  def transformer
    Transformer.new(normaliser: normaliser)
  end

  def loader
    Loader.new(database: database)
  end

  def database
    Database.new(
      host: config.postgres_host,
      port: config.postgres_port,
      database: config.postgres_database,
      username: config.postgres_username,
      password: config.postgres_password,
    )
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
end
