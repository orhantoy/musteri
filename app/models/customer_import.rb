require 'csv'

class CustomerImport < ApplicationRecord
  belongs_to :space
  has_many :rows, class_name: "CustomerImportRow", foreign_key: "owner_id"

  has_one_attached :uploaded_file

  def parsing?
    if started_parsing_at?
      !(parsed_at? || parsing_failed_at?)
    elsif started_parsing_header_at?
      !(parsed_header_at? || parsing_failed_at?)
    end
  end

  def awaits_choosing_header_mapping?
    parsed_header_at? && !started_parsing_at?
  end

  def finalizing?
    started_finalizing_at? && !finalized_at?
  end

  def parsing_failed?
    parsing_failed_at?
  end

  def header_columns
    header_data["as_array"].each_with_index.map do |name, index|
      OpenStruct.new(name: name, index: index)
    end
  end

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

  def can_be_finalized?
    started_finalizing_at.nil? && finalized_at.nil?
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

  def parse_header!
    return if parsed_header_at?

    csv_contents = uploaded_file.download
    csv_contents.force_encoding("UTF-8")

    header_as_array, *_rest = CSV.parse(csv_contents)

    transaction do
      update!(
        header_data: { "as_array" => header_as_array },
        parsed_header_at: Time.zone.now
      )
    end
  end

  def parse_with_dynamic_headers!
    return if parsed_at?

    csv_contents = uploaded_file.download
    csv_contents.force_encoding("UTF-8")

    transaction do
      header_has_been_skipped = nil

      CSV.parse(csv_contents) do |cell_data|
        if header_has_been_skipped
          rows.create!(cell_data: cell_data)
        else
          # Just skip the first row which we regard as the header row.
          header_has_been_skipped = true
        end
      end

      touch(:parsed_at)
    end
  end

  def finalize!
    valid_rows.each do |row|
      transaction do
        customer = space.customers.create!(row.as_customer_attributes)

        if row.user_email_is_valid?
          user = User.find_or_initialize_by(email: row.user_email)
          user.name ||= row.user_name.presence
          user.save!

          customer.memberships.create!(user: user)
        end

        row.touch(:finalized_at)
      end
    end

    touch(:finalized_at)
  end
end
