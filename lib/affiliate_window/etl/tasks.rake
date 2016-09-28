require "affiliate_window/etl"

desc "Runs the extract-transform-load process"
task :run do
  AffiliateWindow::ETL.new.run
end

namespace :db do
  task :migrate do
    AffiliateWindow::ETL.new.migrate
  end
end
