require 'csv'

class CustomerImport < ApplicationRecord
  belongs_to :space
  has_many :rows, class_name: "CustomerImportRow", foreign_key: "owner_id"

  has_one_attached :uploaded_file

  def rows_with_errors
    rows.with_errors
  end

  def rows_with_duplicates
    rows.duplicated
  end

  def valid_rows
    rows.valid
  end

  def rows_of_type(type)
    case type
    when "errors"
      rows_with_errors
    when "duplicates"
      rows_with_duplicates
    when "valid"
      valid_rows
    else
      CustomerImportRow.none
    end
  end

  def parse!
    return if parsed_at?

    csv_contents = uploaded_file.download

    transaction do
      CSV.parse(csv_contents, headers: true) do |row_from_csv|
        rows.create!(parsed_data: row_from_csv.to_hash)
      end

      all_customer_names = rows.map { |row| row.parsed_data["customer_name"] }
      duplicate_customer_names = all_customer_names.detect { |customer_name| all_customer_names.count(customer_name) > 1 }

      rows
        .where("parsed_data->>'customer_name' IN (?)", duplicate_customer_names)
        .where(with_errors: false)
        .update_all(duplicated: true, error_message: "duplicate_in_file")

      touch(:parsed_at)
    end
  end

  def finalize!
    valid_rows.each do |row|
      transaction do
        space.customers.create!(row.as_customer_attributes)
        row.touch(:finalized_at)
      end
    end

    touch(:finalized_at)
  end
end
