class Customer < ApplicationRecord
  belongs_to :space

  def country
    ISO3166::Country.new(country_code) if country_code?
  end

  def country_name
    country.name if country
  end
end
