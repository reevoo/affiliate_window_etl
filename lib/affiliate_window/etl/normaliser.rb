class AffiliateWindow::ETL
  class Normaliser
    def normalise!(record, field_name:, nested_name:, foreign_name:, id_name: :i_id, record_type: nil)
      record_type ||= nested_name

      value = record.delete(field_name)
      return [] unless value

      elements = [value.fetch(nested_name)].flatten
      foreign_id = record.fetch(id_name)

      elements.map do |attributes|
        attributes.merge(
          record_type: record_type,
          foreign_name => foreign_id,
        )
      end
    end
  end
end
