require 'test_helper'
require 'csv'

class CustomerImportTest < ActiveSupport::TestCase
  test "parsing rows" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")

    csv_headers = ["Kunde", "Adresse", "By", "Land", "Brugerens fulde navn", "Bruger-email"]

    csv_contents = ""
    CSV.generate(csv_contents, headers: csv_headers, write_headers: true) do |csv|
      csv << ["Shape A/S", "Njalsgade 17A", "København S", "dk", "Bacon", "bacon.the.dog@example.com"]
      csv << ["Farm Backup", "Njalsgade 23C", "Copenhagen", "dk"]
      csv << ["Duplicate Company", "", "", "", ""]
      csv << ["Duplicate Company", "", "", "", ""]
    end

    csv_file = StringIO.new(csv_contents)

    customer_import = space.customer_imports.new
    customer_import.uploaded_file.attach(io: csv_file, filename: "upload.csv")
    customer_import.header_data = {
      "as_array" => csv_headers,
      "index_mapping" => { "customer_name" => 0, "address" => 1, "city" => 2, "country_code" => 3, "user_name" => 4, "user_email" => 5 },
    }
    customer_import.save!

    customer_import.parse_with_dynamic_headers!

    assert_equal 4, customer_import.rows.count
    assert_equal 0, customer_import.rows_with_errors.count
    assert_equal 1, customer_import.rows_with_duplicates.count
    assert_equal 3, customer_import.valid_rows.count
  end

  test "finalizing import" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")

    csv_headers = ["customer_name", "address", "city", "country_name", "country_code", "user_name", "user_email"]

    csv_contents = ""
    CSV.generate(csv_contents, headers: csv_headers, write_headers: true) do |csv|
      csv << ["Shape A/S", "Njalsgade 17A", "København S", "", "dk", "Bacon", "bacon.the.dog@example.com"]
      csv << ["", "-", "-", "", "dk"]
      csv << ["Duplicate Company", "", "", "", ""]
      csv << ["Duplicate Company", "", "", "", ""]
    end

    csv_file = StringIO.new(csv_contents)

    customer_import = space.customer_imports.new
    customer_import.uploaded_file.attach(io: csv_file, filename: "upload.csv")
    customer_import.header_data = {
      "as_array" => csv_headers,
      "index_mapping" => { "customer_name" => 0, "address" => 1, "city" => 2, "country_code" => 4, "user_name" => 5, "user_email" => 6 },
    }
    customer_import.save!

    customer_import.parse_with_dynamic_headers!

    assert_difference -> { space.customers.count } => 2, -> { space.users.count } => 1 do
      customer_import.finalize!
    end
  end
end
