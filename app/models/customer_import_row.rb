require "uri"

class CustomerImportRow < ApplicationRecord
  belongs_to :owner, class_name: "CustomerImport"

  before_create :check_for_errors
  before_create :check_for_duplicate_in_file
  before_create :check_for_duplicate_persisted_customers

  scope :with_errors, -> { where(with_errors: true) }
  scope :duplicated, -> { where(duplicated: true) }
  scope :valid, -> { where(duplicated: false, with_errors: false) }

  def customer_name
    read_value_from_column("customer_name").presence
  end

  def address
    read_value_from_column("address")
  end

  def city
    read_value_from_column("city")
  end

  def country_code
    read_value_from_column("country_code")
  end

  def user_email
    read_value_from_column("user_email").try(:downcase)
  end

  def user_email_is_valid?
    user_email.present? && user_email =~ URI::MailTo::EMAIL_REGEXP
  end

  def user_name
    read_value_from_column("user_name")
  end

  def country_name
    country.name
  end

  def country
    ISO3166::Country.new(country_code) if country_code.present?
  end

  def as_customer_attributes
    {
      name: customer_name,
      address: address,
      city: city,
      country_code: country ? country.alpha2 : nil,
    }
  end

  private

  def read_value_from_column(column)
    if owner.header_data
      index = header_index_for(column)
      index ? cell_data[index] : nil
    else
      parsed_data[column]
    end
  end

  def header_index_for(column)
    owner.header_data["index_mapping"][column]
  end

  def check_for_errors
    if customer_name.blank?
      self.with_errors = true
      self.error_message ||= "blank_name"
    end

    true
  end

  def check_for_duplicate_in_file
    if customer_name.present?
      existing_row_with_same_customer_name =
        if owner.header_data
          index = header_index_for("customer_name")
          index ? owner.rows.where("cell_data->>#{index} = ?", customer_name).first : nil
        else
          owner.rows.where("parsed_data->>'customer_name' = ?", customer_name).first
        end

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
