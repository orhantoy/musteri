class CustomerImportRow < ApplicationRecord
  belongs_to :owner, class_name: "CustomerImport"

  before_create :check_for_errors

  scope :with_errors, -> { where(with_errors: true) }
  scope :duplicated, -> { where(duplicated: true) }
  scope :valid, -> { where(duplicated: false, with_errors: false) }

  def customer_name
    parsed_data["customer_name"]
  end

  def address
    parsed_data["address"]
  end

  def city
    parsed_data["city"]
  end

  def country
    "-"
  end

  def as_customer_attributes
    {
      name: parsed_data["customer_name"],
      address: parsed_data["address"],
      city: parsed_data["city"],
      country_code: parsed_data["country_code"],
    }
  end

  private

  def check_for_errors
    if parsed_data["customer_name"].blank?
      self.with_errors = true
      self.error_message ||= "blank_name"
    end

    true
  end
end
