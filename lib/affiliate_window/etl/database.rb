class AffiliateWindow::ETL
  class Database
    attr_accessor :params

    def initialize(params)
      self.params = params
    end

    def connect!
      ActiveRecord::Base.establish_connection(params.merge(
        adapter: "postgresql",
        encoding: "unicode",
        pool: 5,
      ))
    end

    def model(record_type)
      MODELS.fetch(record_type)
    end

    class ClickStat < ActiveRecord::Base
      def self.identity
        [:date, :merchant_name]
      end
    end

    class CommissionGroup < ActiveRecord::Base
      def self.identity
        [:merchant_id, :commission_group_code]
      end
    end

    class CommissionRange < ActiveRecord::Base
      self.inheritance_column = :_disabled

      def self.identity
        [:merchant_id]
      end
    end

    class ImpressionStat < ActiveRecord::Base
      def self.identity
        [:date, :merchant_name]
      end
    end

    class Merchant < ActiveRecord::Base
      def self.identity
        [:id]
      end
    end

    class MerchantSector < ActiveRecord::Base
      def self.identity
        [:merchant_id, :sector_id]
      end
    end

    class Transaction < ActiveRecord::Base
      self.inheritance_column = :_disabled

      def self.identity
        [:id]
      end
    end

    class TransactionPart < ActiveRecord::Base
      def self.identity
        [:transaction_id, :commission_group_name]
      end
    end

    class TransactionProduct < ActiveRecord::Base
      def self.identity
        [:id]
      end
    end

    MODELS = {
      click_stat: ClickStat,
      commission_group: CommissionGroup,
      commission_range: CommissionRange,
      impression_stat: ImpressionStat,
      merchant: Merchant,
      merchant_sector: MerchantSector,
      transaction: Transaction,
      transaction_part: TransactionPart,
      transaction_product: TransactionProduct,
    }
  end
end
