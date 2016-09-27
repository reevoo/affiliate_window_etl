class AffiliateWindow::ETL
  class Database
    def initialize(params)
      ActiveRecord::Base.establish_connection(params.merge(
        adapter: "postgresql",
        encoding: "unicode",
        pool: 5,
      ))
    end

    def model(record_type)
      {
        click_stat: ClickStat,
        commission_group: CommissionGroup,
        commission_range: CommissionRange,
        impression_stat: ImpressionStat,
        merchant: Merchant,
        merchant_sector: MerchantSector,
        transaction: Transaction,
        transaction_part: TransactionPart,
        transaction_product: TransactionProduct,
      }.fetch(record_type)
    end

    class ClickStat          < ActiveRecord::Base; end
    class CommissionGroup    < ActiveRecord::Base; end
    class CommissionRange    < ActiveRecord::Base; end
    class ImpressionStat     < ActiveRecord::Base; end
    class Merchant           < ActiveRecord::Base; end
    class MerchantSector     < ActiveRecord::Base; end
    class Transaction        < ActiveRecord::Base; end
    class TransactionPart    < ActiveRecord::Base; end
    class TransactionProduct < ActiveRecord::Base; end

    Transaction.inheritance_column = :_disabled
    CommissionRange.inheritance_column = :_disabled
  end
end
