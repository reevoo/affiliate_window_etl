require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Scheduler do
  let(:database) { FakeDatabase.new }
  subject { described_class.new(database: database) }

  around do |example|
    Timecop.freeze("2016-01-01") { example.run }
  end

  it "schedules all the merchants" do
    jobs = subject.jobs.select do |job|
      job.type == :merchants
    end

    expect(jobs.count).to eq(1)
    expect(jobs.first.args).to be_empty
  end

  it "schedules the last 30 days of transactions" do
    jobs = subject.jobs.select do |job|
      job.type == :daily_transactions
    end

    expect(jobs.count).to eq(30)
    expect(jobs.first.args).to eq(date: "2015-12-03")
    expect(jobs.last.args).to eq(date: "2016-01-01")
  end

  it "schedules the last 30 days of clicks" do
    jobs = subject.jobs.select do |job|
      job.type == :daily_clicks
    end

    expect(jobs.count).to eq(30)
    expect(jobs.first.args).to eq(date: "2015-12-03")
    expect(jobs.last.args).to eq(date: "2016-01-01")
  end

  it "schedules the last 30 days of impressions" do
    jobs = subject.jobs.select do |job|
      job.type == :daily_clicks
    end

    expect(jobs.count).to eq(30)
    expect(jobs.first.args).to eq(date: "2015-12-03")
    expect(jobs.last.args).to eq(date: "2016-01-01")
  end
end
