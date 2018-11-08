class CustomerImportsController < ApplicationController
  def new
  end

  def create
    customer_import = current_space.customer_imports.create!(uploaded_file: params[:import_file])

    redirect_to url_for(action: "show", id: customer_import.id)
  end

  def show
    @customer_import = current_space.customer_imports.find(params[:id])
  end
end
