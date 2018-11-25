class CustomerImportsController < ApplicationController
  def new; end

  def create
    if params[:import_file].blank?
      redirect_to url_for(action: "new")
      return
    end

    customer_import = current_space.customer_imports.create!(uploaded_file: params[:import_file])
    ParseCustomerImportHeaderJob.perform_later(customer_import)

    redirect_to url_for(action: "show", id: customer_import.id)
  end

  def show
    @customer_import = current_space.customer_imports.find(params[:id])

    if @customer_import.parsing?
      render :parsing
    elsif @customer_import.finalizing?
      render :finalizing
    elsif @customer_import.parsing_failed?
      render :parsing_failed
    elsif @customer_import.awaits_choosing_header_mapping?
      render :choose_header_mapping
    elsif params[:row_type].present?
      @rows = @customer_import.rows_of_type(params[:row_type])
      render
    else
      redirect_to url_for(row_type: "valid")
    end
  end

  def save_header_mapping
    customer_import = current_space.customer_imports.find(params[:id])
    customer_import.header_data["index_mapping"] = header_index_mapping_from_params
    customer_import.save!

    ParseCustomerImportJob.perform_later(customer_import)

    redirect_to url_for(action: "show", id: customer_import.id)
  end

  def finalize
    customer_import = current_space.customer_imports.find(params[:id])
    FinalizeCustomerImportJob.perform_later(customer_import)

    redirect_to url_for(action: "show", id: customer_import.id)
  end

  private

  def header_index_mapping_from_params
    {
      "customer_name" => params[:mapping][:customer_name],
      "address" => params[:mapping][:address],
      "city" => params[:mapping][:city],
      "country_code" => params[:mapping][:country_code],
      "user_name" => params[:mapping][:user_name],
      "user_email" => params[:mapping][:user_email],
    }.transform_values { |v| v.present? ? Integer(v) : nil }
  end
end
