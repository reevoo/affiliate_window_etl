class AffiliateWindow
  class ETL
    class Scheduler
      attr_accessor :database, :last_n_days

      def initialize(database:, last_n_days:)
        self.database = database
        self.last_n_days = last_n_days
      end

      def jobs
        jobs = []

        schedule_last_n_days(:daily_transactions, jobs)
        schedule_last_n_days(:daily_clicks, jobs)
        schedule_last_n_days(:daily_impressions, jobs)
        schedule_old_pending_transactions(jobs)
        schedule_merchants(jobs)

        jobs
      end

      private

      def schedule_last_n_days(type, jobs)
        today = Date.today

        (n_days_ago..today).each do |date|
          job = Job.new(type, date: date.to_s)
          jobs.push(job)
        end
      end

      def schedule_old_pending_transactions(jobs)
        model = database.model(:transaction)
        pending = model.where(status: "pending")
        old_pending = pending.where("transaction_date < ?", n_days_ago)

        transaction_ids = old_pending.pluck(:id)

        job = Job.new(:transactions, transaction_ids: transaction_ids)
        jobs.push(job)
      end

      def schedule_merchants(jobs)
        jobs.push(Job.new(:merchants))
      end

      def n_days_ago
        Date.today - last_n_days + 1
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
end
