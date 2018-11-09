class CustomersController < ApplicationController
  def index
    @customers = current_space.customers.order(:id)
  end
end
