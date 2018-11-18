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
    csv_contents.force_encoding("UTF-8")

    transaction do
      CSV.parse(csv_contents, headers: true) do |row_from_csv|
        rows.create!(parsed_data: row_from_csv.to_hash)
      end

      touch(:parsed_at)
    end
  end

  def finalize!
    valid_rows.each do |row|
      transaction do
        customer = space.customers.create!(row.as_customer_attributes)

        if row.user_email.present?
          user = User.find_or_create_by!(email: row.user_email)

          customer.memberships.create!(user: user)
        end

        row.touch(:finalized_at)
      end
    end

    touch(:finalized_at)
  end
end
