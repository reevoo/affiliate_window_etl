class AffiliateWindow::ETL
  class Scheduler
    DAYS = 30

    attr_accessor :database

    def initialize(database:)
      self.database = database
    end

    def jobs
      jobs = []

      schedule_last_n_days(:daily_transactions, jobs)
      schedule_last_n_days(:daily_clicks, jobs)
      schedule_last_n_days(:daily_impressions, jobs)
      schedule_merchants(jobs)

      jobs
    end

    private

    def schedule_last_n_days(type, jobs)
      today = Date.today
      n_days_ago = today - DAYS + 1

      (n_days_ago..today).each do |date|
        job = Job.new(type, date: date.to_s)
        jobs.push(job)
      end
    end

    def schedule_merchants(jobs)
      jobs.push(Job.new(:merchants))
    end

    class Job
      attr_accessor :type, :args

      def initialize(type, args = {})
        self.type = type
        self.args = args
      end

      def ==(other)
        type == other.type && args == other.args
      end
    end
  end
end
