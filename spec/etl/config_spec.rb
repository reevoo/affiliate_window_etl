require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Config do
  subject { described_class.new(env: env) }

  context "with config in the environment" do
    let(:env) do
      {
        "ACCOUNT_ID" => 123,
        "AFFILIATE_API_PASSWORD" => "sekret",
        "LAST_N_DAYS" => 15,
        "DATABASE_URL" => "postgres://foo@bar/whatever",
        "DEBUG_STREAM" => "none",
      }
    end

    it "retrieves configuration from the environment" do
      expect(subject.account_id).to eq(123)
      expect(subject.affiliate_api_password).to eq("sekret")
      expect(subject.last_n_days).to eq(15)
      expect(subject.database_url).to eq("postgres://foo@bar/whatever")
      expect(subject.output_stream).to be_nil
    end
  end

  context "without config in the environment" do
    let(:env) { {} }

    it "has sensible defaults" do
      expect(subject.account_id).to eq(1234)
      expect(subject.affiliate_api_password).to eq("password")
      expect(subject.last_n_days).to eq(7)
      expect(subject.database_url).to eq("postgres://#{`whoami`.strip}@localhost:5432/affiliate_window?pool=5&encoding=unicode")
      expect(subject.output_stream).to eq($stdout)
    end
  end
end
