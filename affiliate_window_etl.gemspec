require "./lib/affiliate_window/etl/version"

Gem::Specification.new do |s|
  s.name        = "affiliate_window_etl"
  s.version     = AffiliateWindow::ETL::VERSION
  s.license     = "MIT"
  s.summary     = "Affiliate Window ETL"
  s.description = "An ETL for retrieving records from the Affiliate Window API" \
                  "and loading them into a Postgres database."
  s.author      = "Reevoo Developers"
  s.email       = "developers@reevoo.com"
  s.homepage    = "https://github.com/reevoo/affiliate_window_etl"
  s.files       = ["README.md"] + Dir["lib/**/*.*"]

  s.add_dependency "affiliate_window", "~> 0.1"
  s.add_dependency "activerecord", "~> 5.0"
  s.add_dependency "pg", "~> 0.19"

  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "rake", "~> 11.3"
  s.add_development_dependency "timecop", "~> 0.8"
  s.add_development_dependency "bundler-audit", "~> 0.5"
  s.add_development_dependency "reevoocop", "~> 0.0.8"
end
