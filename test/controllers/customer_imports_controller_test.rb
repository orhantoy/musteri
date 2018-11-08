require 'test_helper'
require 'csv'

class CustomerImportsControllerTest < ActionDispatch::IntegrationTest
  test "uploading CSV file creates a customer import" do
    space = Space.create!(slug: "ZBX")

    begin
      csv_file = Tempfile.new(["upload", ".csv"])

      CSV.open(csv_file.path, "wb") do |csv|
        csv << ["customer_name", "address", "city", "country_name", "country_code"]
        csv << ["Shape A/S", "Njalsgade 17A", "Copenhagen", "", "dk"]
      end

      csv_file.rewind

      assert_difference "CustomerImport.count" do
        post app_customer_imports_url(tenant: space.slug), params: { import_file: fixture_file_upload(csv_file.path, 'text/csv') }
      end
    ensure
      csv_file.close
      csv_file.unlink
    end

    assert_response :redirect
    follow_redirect!
  end
end
