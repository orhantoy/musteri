class CustomerMembershipMailer < ApplicationMailer
  def confirmation(customer_membership)
    @customer_membership = customer_membership
    @user = customer_membership.user
    @customer = customer_membership.customer
    @space = customer_membership.customer.space

    mail(to: @customer_membership.user.email)
  end
end
