class CustomerMembershipConfirmationsController < ApplicationController
  # GET /confirm/:membership_id/access?secret_token=xxx
  def new
    @membership = CustomerMembership.find_by(id: params[:membership_id], confirmation_token: String(params[:secret_token]))
  end

  # POST /confirm/:membership_id/access
  def create
    @membership = CustomerMembership.find_by(id: params[:membership_id], confirmation_token: String(params[:secret_token]))

    if @membership
      if params[:user_password]
        @membership.user.password = params[:user_password]
        @membership.user.password_confirmation = String(params[:user_password_confirmation])
      end

      @membership.confirmed_at = Time.zone.now
      @membership.confirmation_token = nil

      if @membership.user.save && @membership.save
        redirect_to url_for(action: "success")
      else
        render :new
      end
    else
      redirect_to url_for(action: "success")
    end
  end

  # GET /confirm/:membership_id/success
  def success; end

  # GET /confirm/:membership_id/error
  def error; end
end
