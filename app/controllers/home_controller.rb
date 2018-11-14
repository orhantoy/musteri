class HomeController < ApplicationController
  def index
    default_space = Space.find_or_create_by!(slug: "alpi", title: "ALPI")

    redirect_to app_path(tenant: default_space.slug)
  end
end
