class AffiliateWindow::ETL
  class Transformer
    attr_accessor :normaliser

    def initialize(normaliser:)
      self.normaliser = normaliser
    end

    def transform(record)
      record = record.dup
      record_type = record.fetch(:record_type)

      transformed_records = []

      case record_type
      when :merchant
        normalise_commision_ranges!(record, transformed_records)
        normalise_sectors!(record, transformed_records)
      when :transaction
        normalise_transaction_parts!(record, transformed_records)
      when :transaction_product
        normalise_transaction_products!(record, transformed_records)

        # transaction_product has no other top-level attributes
        return transformed_records
      end

      attributes = infer_field_names(record)
      transformed_records.push(attributes)
    end

    private

    def normalise_commision_ranges!(record, transformed_records)
      commision_ranges = normaliser.normalise!(
        record,
        field_name: :a_commission_ranges,
        nested_name: :commission_range,
        foreign_name: :merchant_id,
      )

      commision_ranges.each do |record|
        attributes = infer_field_names(record)
        transformed_records.push(attributes)
      end
    end

    def normalise_sectors!(record, transformed_records)
      sectors = normaliser.normalise!(
        record,
        field_name: :a_sectors,
        nested_name: :merchant_sector,
        foreign_name: :merchant_id,
      )

      sectors.each do |record|
        attributes = infer_field_names(record)
        transformed_records.push(attributes)
      end
    end

    def normalise_transaction_parts!(record, transformed_records)
      transaction_parts = normaliser.normalise!(
        record,
        field_name: :a_transaction_parts,
        nested_name: :transaction_part,
        foreign_name: :transaction_id,
      )

      transaction_parts.each do |record|
        attributes = infer_field_names(record)
        transformed_records.push(attributes)
      end
    end

    def normalise_transaction_products!(record, transformed_records)
      transaction_products = normaliser.normalise!(
        record,
        field_name: :a_products,
        nested_name: :product,
        foreign_name: :transaction_id,
        id_name: :i_transaction_id,
        record_type: :transaction_product,
      )

      transaction_products.each do |record|
        attributes = infer_field_names(record)
        transformed_records.push(attributes)
      end
    end

    def infer_field_names(record, prefix = nil)
      record.keys.each.with_object({}) do |field_name, hash|
        value = record.fetch(field_name)
        new_name = new_field_name(field_name)

        case value
        when Hash
          sub_record = record.fetch(field_name)
          sub_prefix = "#{prefix}#{new_name}_"
          sub_attributes = infer_field_names(sub_record, sub_prefix)

          hash.merge!(sub_attributes)
        when Array
          raise arrays_unsupported_error(field_name, value)
        else
          new_name = "#{prefix}#{new_name}".to_sym
          attributes = record.fetch(field_name, nil)

          hash.merge!(new_name => attributes)
        end
      end
    end

    def new_field_name(field_name)
      if field_name.to_s[1] == "_"
        field_name.to_s[2..-1]
      else
        field_name
      end
    end

    def arrays_unsupported_error(field_name, array)
      message = "Unable to transform '#{field_name}' because its value is an array.\n"
      message += "To cope with this, normalise elements of the array into a separate table.\n"
      message += "Then, add a foreign key from the normalised record to this one."

      TypeError.new(message)
    end

    class TypeError < StandardError; end
  end
end
