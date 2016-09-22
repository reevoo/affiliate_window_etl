require "spec_helper"

RSpec.describe AffiliateWindow::ETL::Transformer do
  it "transforms a record to an array of attributes" do
    result = subject.transform(
      record_type: :record_type,
      s_foo: "foo",
      i_bar: 123,
    )

    expect(result).to eq [{
      record_type: :record_type,
      foo: "foo",
      bar: 123,
    }]
  end

  it "does not affect keys that do not start with *_" do
    result = subject.transform(
      record_type: :record_type,
      foo: "bar",
    )

    expect(result).to eq [{
      record_type: :record_type,
      foo: "bar",
    }]
  end

  it "flattens out nested hashes" do
    result = subject.transform(
      record_type: :record_type,
      o_foo: {
        s_bar: "bar",
        i_baz: 123,
        o_qux: {
          s_abc: "abc",
          bcd: 456
        }
      }
    )

    expect(result).to eq [{
      record_type: :record_type,
      foo_bar: "bar",
      foo_baz: 123,
      foo_qux_abc: "abc",
      foo_qux_bcd: 456,
    }]
  end

  it "raises a helpful error if the value is an array" do
    expect {
      subject.transform(record_type: :record_type, foo: [])
    }.to raise_error(described_class::TypeError, /normalise elements of the array/)
  end

  describe "normalisations" do
    it "normalises transaction_parts" do
      record = {
        record_type: :transaction,
        i_id: 123,
        foo: "bar",
        a_transaction_parts: {
          transaction_part: [
            { bar: "baz" },
            { bar: "qux" },
          ]
        },
      }

      result = subject.transform(record)

      expect(result).to match_array [
        {
          record_type: :transaction_part,
          transaction_id: 123,
          bar: "baz",
        },
        {
          record_type: :transaction_part,
          transaction_id: 123,
          bar: "qux",
        },
        {
          record_type: :transaction,
          id: 123,
          foo: "bar",
        }
      ]
    end
  end
end
