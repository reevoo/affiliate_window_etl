require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Config do
  let(:env) { { "POSTGRES_PORT" => 123 } }
  subject { described_class.new(env: env) }

  it "retrieves configuration from the environment" do
    expect(subject.postgres_port).to eq(123)
  end

  it "has sensible defaults" do
    expect(subject.postgres_host).to eq("localhost")
    expect(subject.postgres_database).to eq("affiliate_window")
    expect(subject.postgres_password).to be_empty
  end
end
