require 'test_helper'
require 'csv'

class CustomerImportsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "uploading CSV file creates a customer import" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << ["customer_name", "address", "city", "country_name", "country_code"]
        csv << ["Shape A/S", "Njalsgade 17A", "Copenhagen", "", "dk"]
      end

      csv_file.rewind

      assert_difference "space.customer_imports.count" do
        post app_customer_imports_url(tenant: space.slug), params: { import_file: fixture_file_upload(csv_file.path, 'text/csv') }
      end
    ensure
      csv_file.close
      csv_file.unlink
    end

    assert_response :redirect
    follow_redirect!
  end

  test "finalizing a customer import will create customers" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer_import = space.customer_imports.new

    csv_headers = ["customer_name", "address", "city", "country_name", "country_code"]

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << csv_headers
        csv << ["Shape A/S", "Njalsgade 17A", "Copenhagen", "", "dk"]
        csv << ["Devotus", "", "Hvidovre", "", "dk"]
      end

      csv_file.rewind

      customer_import.uploaded_file.attach(io: csv_file, filename: "upload.csv")
      customer_import.save!
    ensure
      csv_file.close
      csv_file.unlink
    end

    customer_import.header_data = {
      "as_array" => csv_headers,
      "index_mapping" => { "customer_name" => 0, "address" => 1, "city" => 2, "country_code" => 4 },
    }
    customer_import.save!

    customer_import.parse_with_dynamic_headers!

    assert_difference "space.customers.count", 2 do
      perform_enqueued_jobs do
        post finalize_app_customer_import_url(tenant: space.slug, id: customer_import.id)
      end
    end
  end
end
