require 'test_helper'

class CustomerImportsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "parsing rows" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer_import = space.customer_imports.new

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << ["customer_name", "address", "city", "country_name", "country_code"]
        csv << ["Shape A/S", "Njalsgade 17A", "Copenhagen", "", "dk"]
        csv << ["", "-", "-", "", "dk"]
        csv << ["Duplicate Company", "", "", "", ""]
        csv << ["Duplicate Company", "", "", "", ""]
      end

      csv_file.rewind

      customer_import.uploaded_file.attach(io: csv_file, filename: "upload.csv")
      perform_enqueued_jobs { customer_import.save! }
    ensure
      csv_file.close
      csv_file.unlink
    end

    assert_equal 4, customer_import.rows.count
    assert_equal 1, customer_import.rows_with_errors.count
    assert_equal 2, customer_import.rows_with_duplicates.count
    assert_equal 1, customer_import.valid_rows.count
  end
end
