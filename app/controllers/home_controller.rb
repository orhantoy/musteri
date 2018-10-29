class HomeController < ApplicationController
  def index
    redirect_to app_path(tenant: "ALPI")
  end
end
