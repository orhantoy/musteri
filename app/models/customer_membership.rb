require "securerandom"

class CustomerMembership < ApplicationRecord
  belongs_to :customer
  belongs_to :user

  before_create :assign_new_confirmation_token
  after_create_commit :send_confirmation_email

  def confirmed?
    confirmed_at?
  end

  def send_confirmation_email
    CustomerMembershipMailer.confirmation(self).deliver_later
  end

  def assign_new_confirmation_token
    self.confirmation_token = SecureRandom.base58
  end
end
