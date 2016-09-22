require "affiliate_window/etl"

config = AffiliateWindow::ETL::Config.new(env: ENV)
schema = AffiliateWindow::ETL::Schema.new

desc "Runs the extract-transform-load process"
task :run do
  AffiliateWindow::ETL.new.run
end

desc "Runs fluentd. Re-generates the fluentd config file first."
task fluentd: :configure do
  system("fluentd -c config/fluentd.conf")
end

desc "Generates the fluentd config."
task :configure do
  template = File.read("config/fluentd.conf.erb")
  output = ERB.new(template).result(binding)

  File.open("config/fluentd.conf", "w") { |f| f.write(output) }
end

desc "Writes the SQL database schema to stdout"
task :schema do
  puts schema.to_sql
end
