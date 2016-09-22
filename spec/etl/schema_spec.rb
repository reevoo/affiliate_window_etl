require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Schema do
  describe "#tables" do
    it "returns the tables of the schema" do
      tables = subject.tables
      merchants = tables.first

      expect(merchants.name).to eq(:merchants)

      columns = merchants.columns
      id = columns.fetch(:id)
      name = columns.fetch(:name)

      expect(id).to eq("integer")
      expect(name).to eq("varchar(255)")
    end
  end

  describe "#to_sql" do
    it "returns sql statements to create each table in the schema" do
      sql = subject.to_sql
      first = sql.split(";").first

      expect(first).to eq [
        "CREATE TABLE merchants (",
        "  id integer,",
        "  name varchar(255),",
        "  display_url varchar(255),",
        "  click_through_url varchar(255),",
        "  primary_region_name varchar(255),",
        "  primary_region_country_code varchar(255),",
        "  primary_region_currency_code varchar(255),",
        "  logo_url varchar(255),",
        "  feed_modified varchar(255),",
        "  strapline varchar(255),",
        "  description varchar(10000),",
        "  approval_percentage varchar(255),",
        "  epc varchar(255),",
        "  conversion_rate varchar(255),",
        "  validation_days integer,",
        "  awin_grade varchar(255),",
        "  commission_ranges_commission_range_type varchar(255),",
        "  commission_ranges_commission_range_min varchar(255),",
        "  commission_ranges_commission_range_max varchar(255),",
        "  sectors_merchant_sector_sector_id integer,",
        "  sectors_merchant_sector_sector_name varchar(255)",
        ")",
      ].join("\n")
    end
  end
end
