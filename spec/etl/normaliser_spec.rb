require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Normaliser do
  it "returns an array of records for each element in an array" do
    record = {
      i_id: 123,
      some_array: {
        nested: [
          { foo: "bar" },
          { foo: "baz" },
        ]
      },
    }

    result = subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
    )

    expect(result).to eq [
      { foo: "bar", record_type: :nested, foreign: 123 },
      { foo: "baz", record_type: :nested, foreign: 123 },
    ]
  end

  it "coerces to a single-element array if the value is actually a hash" do
    record = {
      i_id: 123,
      some_array: {
        nested: { foo: "bar" },
      },
    }

    result = subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
    )

    expect(result).to eq [
      { foo: "bar", record_type: :nested, foreign: 123 },
    ]
  end

  it "returns an empty array if top-level field is nil" do
    record = { some_array: nil }

    result = subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
    )

    expect(result).to eq []
  end

  it "returns an empty array if the top-level field is missing" do
    record = {}

    result = subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
    )

    expect(result).to eq []
  end

  it "removes the top-level field from the record" do
    record = { some_array: nil }

    subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
    )

    expect(record).not_to have_key(:some_array)
  end

  it "can optionally take the name of the top-level id field" do
    record = {
      i_id: 123,
      some_other_id: 456,
      some_array: {
        nested: [
          { foo: "bar" },
          { foo: "baz" },
        ]
      },
    }

    result = subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
      id_name: :some_other_id,
    )

    expect(result).to eq [
      { foo: "bar", record_type: :nested, foreign: 456 },
      { foo: "baz", record_type: :nested, foreign: 456 },
    ]
  end

  it "can optionally take a record_type to set on the normalised records" do
    record = {
      i_id: 123,
      some_array: {
        nested: [
          { foo: "bar" },
          { foo: "baz" },
        ]
      },
    }

    result = subject.normalise!(
      record,
      field_name: :some_array,
      nested_name: :nested,
      foreign_name: :foreign,
      record_type: :some_other_record_type,
    )

    expect(result).to eq [
      { foo: "bar", record_type: :some_other_record_type, foreign: 123 },
      { foo: "baz", record_type: :some_other_record_type, foreign: 123 },
    ]
  end
end
