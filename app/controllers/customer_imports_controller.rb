class CustomerImportsController < ApplicationController
  def new; end

  def create
    if params[:import_file].blank?
      redirect_to url_for(action: "new")
      return
    end

    customer_import = current_space.customer_imports.create!(uploaded_file: params[:import_file])
    ParseCustomerImportJob.perform_later(customer_import)

    redirect_to url_for(action: "show", id: customer_import.id)
  end

  def show
    @customer_import = current_space.customer_imports.find(params[:id])

    if @customer_import.parsing?
      render :parsing
    elsif @customer_import.finalizing?
      render :finalizing
    elsif params[:row_type].present?
      @rows = @customer_import.rows_of_type(params[:row_type])
      render
    else
      redirect_to url_for(row_type: "valid")
    end
  end

  def finalize
    customer_import = current_space.customer_imports.find(params[:id])
    FinalizeCustomerImportJob.perform_later(customer_import)

    redirect_to url_for(action: "show", id: customer_import.id)
  end
end
