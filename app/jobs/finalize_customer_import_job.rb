class FinalizeCustomerImportJob < ApplicationJob
  def perform(customer_import)
    customer_import.finalize!
  end
end
