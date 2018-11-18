class CustomerImportRow < ApplicationRecord
  belongs_to :owner, class_name: "CustomerImport"

  before_create :check_for_errors
  before_create :check_for_duplicate_in_file
  before_create :check_for_duplicate_persisted_customers

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

  def country_code
    parsed_data["country_code"]
  end

  def country_name
    country.name
  end

  def country
    ISO3166::Country.new(country_code) if country_code.present?
  end

  def as_customer_attributes
    {
      name: parsed_data["customer_name"],
      address: parsed_data["address"],
      city: parsed_data["city"],
      country_code: country ? country.alpha2 : nil,
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

  def check_for_duplicate_in_file
    if customer_name.present?
      existing_row_with_same_customer_name = owner.rows.where("parsed_data->>'customer_name' = ?", customer_name).first

      if existing_row_with_same_customer_name
        self.duplicated = true
        self.error_message ||= "duplicate_in_file"
      end
    end

    true
  end

  def check_for_duplicate_persisted_customers
    if customer_name.present?
      existing_customer_with_same_name = owner.space.customers.find_by_name(customer_name)

      if existing_customer_with_same_name
        self.duplicated = true
        self.error_message ||= "customer_already_exists"
      end
    end

    true
  end
end
