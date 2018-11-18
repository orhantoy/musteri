class CustomerMembershipConfirmationsController < ApplicationController
  # GET /confirm/:membership_id/access?secret_token=xxx
  def new
    @membership = CustomerMembership.find_by(id: params[:membership_id], confirmation_token: String(params[:secret_token]))
  end

  # POST /confirm/:membership_id/access
  def create
    @membership = CustomerMembership.find_by(id: params[:membership_id], confirmation_token: String(params[:secret_token]))

    if @membership
      @membership.update!(confirmed_at: Time.zone.now, confirmation_token: nil)
      redirect_to url_for(action: "success")
    else
      redirect_to url_for(action: "success")
    end
  end

  # GET /confirm/:membership_id/success
  def success; end

  # GET /confirm/:membership_id/error
  def error; end
end
