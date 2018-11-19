require "securerandom"

class CustomerMembership < ApplicationRecord
  belongs_to :customer
  belongs_to :user

  before_create :assign_new_confirmation_token
  after_create_commit :send_confirmation_email

  def confirmed?
    confirmed_at?
  end

  def confirm(user_password: nil, user_password_confirmation: nil)
    if user_password
      user.password = user_password
      user.password_confirmation = String(user_password_confirmation)
    end

    self.confirmed_at = Time.zone.now
    self.confirmation_token = nil

    user.save && save
  end

  def send_confirmation_email
    CustomerMembershipMailer.confirmation(self).deliver_later
  end

  def assign_new_confirmation_token
    self.confirmation_token = SecureRandom.base58
  end
end
