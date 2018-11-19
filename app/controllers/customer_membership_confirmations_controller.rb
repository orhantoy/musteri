class CustomerMembershipConfirmationsController < ApplicationController
  # GET /confirm/:membership_id/access?secret_token=xxx
  def new
    @membership = CustomerMembership.find_by(id: params[:membership_id], confirmation_token: String(params[:secret_token]))
  end

  # POST /confirm/:membership_id/access
  def create
    @membership = CustomerMembership.find_by(id: params[:membership_id], confirmation_token: String(params[:secret_token]))

    if @membership && @membership.confirm(confirmation_args)
      redirect_to url_for(action: "success")
    elsif @membership
      render :new
    else
      redirect_to url_for(action: "error")
    end
  end

  # GET /confirm/:membership_id/success
  def success; end

  # GET /confirm/:membership_id/error
  def error; end

  private

  def confirmation_args
    {
      user_password: params[:user_password],
      user_password_confirmation: params[:user_password_confirmation],
    }
  end
end
