##Affiliate Window ETL

This gem provides an extract-transform-load process for retrieving records from
the [Affiliate Window](http://www.affiliatewindow.com/) API and loading them
into a Postgres database. It works incrementally, updating existing records
rather than creating duplicates. It handles its own scheduling and determines
which records need to be retrieved from the API based on the current state of
the database.

##How to run it

You can either clone this repository and run the ETL with rake or add it as a
dependency of another application.

**To run from this repository:**

1. Create the database: `createdb affiliate_window`
2. Migrate the database: `rake db:migrate`
3. Run the ETL: `rake run`

**To run as a dependency:**

```ruby
require "affiliate_window/etl"
etl = AffiliateWindow::ETL.new

etl.migrate
etl.run
```

By default, it will inherit config from your environment variables. If you don't
want it do this, you can pass in a hash:

```ruby
AffiliateWindow::ETL.new(
  "START_DATE" => "2016-01-01",
  "END_DATE" => "2016-01-07",
  # ...
)
```

If you would like, you can add the gem's rake tasks to your app:

```ruby
# Rakefile
namespace :etl do
  spec = Gem::Specification.find_by_name "affiliate_window_etl"
  load "#{spec.gem_dir}/lib/affiliate_window/etl/tasks.rake"
end
```

##How to configure it

The library tries to be [twelve-factor](https://12factor.net/) compliant and is
configured via environment variables. When not specified, the configuration
defaults to something suitable for development purposes. If the library is used
as a dependency of something else, this configuration can be passed into the
`AffiliateWindow::ETL` initializer.

`ACCOUNT_ID`

The id of the Affiliate Window account for which to retrieve records.

`AFFILIATE_API_PASSWORD`

The API token of for the Publisher Service. Can be retrieved from
[this page](https://www.affiliatewindow.com/affiliates/accountdetails.php).

`POSTGRES_HOST`

The hostname of the Postgres server. Defaults to `localhost`.

`POSTGRES_PORT`

The port of the Postgres server. Defaults to `5432`.

`POSTGRES_DATABASE`

The name of the database on the Postgres server. Defaults to `affiliate_window`.

`POSTGRES_USERNAME`

The name of the user on the Postgres server. Defaults to the current user.

`POSTGRES_PASSWORD`

The password of the user on the Postgres server. Defaults to empty.

`LAST_N_DAYS`

The number of days to retrieve. When the ETL runs, it will fetch this many days
of data, prior to today. It can take a while for transactions to appear in the
API. It is recommended this be set to 60 in production. Defaults to 7.

`DEBUG_STREAM`

The stream to write debug output. Defaults to `stdout`.

Valid options are: `stdout`, `stderr` and `none`.

## How to contribute

Bug reports and pull requests are welcome on
[GitHub](https://github.com/reevoo/affiliate_window_etl). This project is
intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org/) code of conduct.

## License

The gem is available as open-source under the terms of the
[???](???).
