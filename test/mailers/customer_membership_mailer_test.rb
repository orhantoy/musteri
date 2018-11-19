require "test_helper"

class CustomerMembershipMailerTest < ActionMailer::TestCase
  test "#confirmation" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer = space.customers.create!(name: "Shape A/S")
    user = User.create!(email: "bacon@example.com")
    membership = customer.memberships.create!(user: user)  

    CustomerMembershipMailer.confirmation(membership).deliver_now
  end
end
