require 'test_helper'
require 'csv'

class CustomerImportTest < ActiveSupport::TestCase
  test "parsing rows" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    space.customers.create!(name: "Farm Backup")

    customer_import = space.customer_imports.new

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << ["customer_name", "address", "city", "country_name", "country_code", "user_name", "user_email"]
        csv << ["Shape A/S", "Njalsgade 17A", "København S", "", "dk", "Bacon", "bacon.the.dog@example.com"]
        csv << ["Farm Backup", "Njalsgade 23C", "Copenhagen", "", "dk"]
        csv << ["", "-", "-", "", "dk"]
        csv << ["Duplicate Company", "", "", "", ""]
        csv << ["Duplicate Company", "", "", "", ""]
      end

      csv_file.rewind

      customer_import.uploaded_file.attach(io: csv_file, filename: "upload.csv")
      customer_import.save!
    ensure
      csv_file.close
      csv_file.unlink
    end

    customer_import.parse!

    assert_equal 5, customer_import.rows.count
    assert_equal 1, customer_import.rows_with_errors.count
    assert_equal 2, customer_import.rows_with_duplicates.count
    assert_equal 2, customer_import.valid_rows.count

    assert_equal ["blank_name"], customer_import.rows_with_errors.pluck(:error_message)
    assert_equal ["customer_already_exists", "duplicate_in_file"], customer_import.rows_with_duplicates.order(:id).pluck(:error_message)
  end

  test "parsing rows with dynamic columns" do
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
    customer_import = space.customer_imports.new

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << ["customer_name", "address", "city", "country_name", "country_code", "user_name", "user_email"]
        csv << ["Shape A/S", "Njalsgade 17A", "København S", "", "dk", "Bacon", "bacon.the.dog@example.com"]
        csv << ["", "-", "-", "", "dk"]
        csv << ["Duplicate Company", "", "", "", ""]
        csv << ["Duplicate Company", "", "", "", ""]
      end

      csv_file.rewind

      customer_import.uploaded_file.attach(io: csv_file, filename: "upload.csv")
      customer_import.save!
    ensure
      csv_file.close
      csv_file.unlink
    end

    customer_import.parse!

    assert_difference -> { space.customers.count } => 2, -> { space.users.count} => 1 do
      customer_import.finalize!
    end
  end
end
