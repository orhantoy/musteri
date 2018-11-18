require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "giving user customer membership results in sending an email" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer = space.customers.create!(name: "Shape A/S")
    user = User.create!(email: "bacon@example.com")

    assert_enqueued_emails 1 do
      customer.memberships.create!(user: user)
    end
  end

  test "giving user customer membership results in creating a confirmation token" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer = space.customers.create!(name: "Shape A/S")
    user = User.create!(email: "bacon@example.com")
    membership = customer.memberships.create!(user: user)

    assert membership.confirmation_token
  end
end
