class Customer < ApplicationRecord
  belongs_to :space
  has_many :memberships, class_name: "CustomerMembership"
  has_many :users, through: :memberships

  def country
    ISO3166::Country.new(country_code) if country_code?
  end

  def country_name
    country.name if country
  end
end
