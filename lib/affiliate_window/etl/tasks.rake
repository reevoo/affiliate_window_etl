require "affiliate_window/etl"

config = AffiliateWindow::ETL::Config.new(env: ENV)
schema = AffiliateWindow::ETL::Schema.new

desc "Runs the extract-transform-load process"
task :run do
  AffiliateWindow::ETL.new.run
end

desc "Writes the SQL database schema to stdout"
task :schema do
  puts schema.to_sql
end
