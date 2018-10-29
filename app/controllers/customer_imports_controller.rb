class CustomerImportsController < ApplicationController
  def new
  end

  def create
    redirect_to url_for(action: "show", id: "1")
  end

  def show
  end
end
