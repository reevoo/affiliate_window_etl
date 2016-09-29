require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Scheduler do
  let(:database) { FakeDatabase.new }

  subject do
    described_class.new(
      database: database,
      last_n_days: 5,
    )
  end

  around do |example|
    Timecop.freeze("2016-01-01") { example.run }
  end

  it "schedules 'pending' transactions that are older than n days ago" do
    jobs = subject.jobs.select do |job|
      job.type == :transactions
    end

    expect(jobs.count).to eq(1)
    expect(jobs.first.args).to eq(transaction_ids: [3, 5])

    expect(database.filters).to eq [
      [{ status: "pending" }],
      ["transaction_date < ?", Date.new(2015, 12, 28)],
    ]
  end

  it "schedules the last n days of transactions" do
    jobs = subject.jobs.select do |job|
      job.type == :daily_transactions
    end

    expect(jobs.count).to eq(5)
    expect(jobs.first.args).to eq(date: "2015-12-28")
    expect(jobs.last.args).to eq(date: "2016-01-01")
  end

  it "schedules the last n days of clicks" do
    jobs = subject.jobs.select do |job|
      job.type == :daily_clicks
    end

    expect(jobs.count).to eq(5)
    expect(jobs.first.args).to eq(date: "2015-12-28")
    expect(jobs.last.args).to eq(date: "2016-01-01")
  end

  it "schedules the last n days of impressions" do
    jobs = subject.jobs.select do |job|
      job.type == :daily_clicks
    end

    expect(jobs.count).to eq(5)
    expect(jobs.first.args).to eq(date: "2015-12-28")
    expect(jobs.last.args).to eq(date: "2016-01-01")
  end

  it "schedules all the merchants" do
    jobs = subject.jobs.select do |job|
      job.type == :merchants
    end

    expect(jobs.count).to eq(1)
    expect(jobs.first.args).to be_empty
  end
end
