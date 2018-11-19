require "uri"

class User < ApplicationRecord
  has_secure_password(validations: false)

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED }, confirmation: { allow_blank: true }
end
