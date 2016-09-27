class AffiliateWindow::ETL
  attr_accessor :config, :client

  def initialize(env: ENV)
    self.config = Config.new(env: env)
    self.client = AffiliateWindow.login(
      account_id: config.account_id,
      affiliate_api_password: config.affiliate_api_password,
    )
  end

  def run
    extracter = Extracter.new(
      client: client,
      interval: interval,
      output: config.output_stream,
    )

    transformer = Transformer.new
    loader = Loader.new(database: database)

    extracter.extract.each do |record|
      transformer.transform(record).each do |transformed_record|
        loader.load(transformed_record)
      end
    end
  end

  private

  def interval
    Interval.new(
      from: config.start_date,
      to: config.end_date,
    )
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
end
