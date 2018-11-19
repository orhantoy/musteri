class ApplicationController < ActionController::Base
  helper_method :current_space

  protected

  def current_space
    @current_space ||= Space.find_by_slug!(params[:tenant])
  end
end
