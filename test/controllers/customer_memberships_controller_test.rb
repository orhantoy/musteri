require "test_helper"

class CustomerMembershipConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "render new" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer = space.customers.create!(name: "Shape A/S")
    user = User.create!(email: "bacon@example.com")
    membership = customer.memberships.create!(user: user)

    get confirm_customer_membership_url(membership_id: membership.id, secret_token: membership.confirmation_token)

    assert_response :success
  end

  test "confirmation" do
    space = Space.create!(title: "Zeobix", slug: "ZBX")
    customer = space.customers.create!(name: "Shape A/S")
    user = User.create!(email: "bacon@example.com")
    membership = customer.memberships.create!(user: user)

    membership.reload
    refute membership.confirmed?
    refute membership.user.password_digest.present?

    post confirm_customer_membership_url(membership_id: membership.id), params: { secret_token: membership.confirmation_token, user_password: "password", user_password_confirmation: "password" }

    membership.reload
    assert membership.confirmed?
    assert membership.user.authenticate("password")

    assert_response :redirect
    follow_redirect!
  end
end
