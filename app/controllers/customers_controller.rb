class CustomersController < ApplicationController
  def index
    @customers = current_space.customers.order(:id)
  end

  def show
    @customer = current_space.customers.find(params[:id])
  end
end
