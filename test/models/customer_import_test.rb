require 'test_helper'

class CustomerImportTest < ActiveSupport::TestCase
  test "parsing rows" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    space.customers.create!(name: "Farm Backup")

    customer_import = space.customer_imports.new

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << ["customer_name", "address", "city", "country_name", "country_code"]
        csv << ["Shape A/S", "Njalsgade 17A", "København S", "", "dk"]
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

  test "finalizing import" do
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
      customer_import.save!
    ensure
      csv_file.close
      csv_file.unlink
    end

    customer_import.parse!

    assert_difference "space.customers.count", 2 do
      customer_import.finalize!
    end
  end
end
