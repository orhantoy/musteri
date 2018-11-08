class ParseCustomerImportJob < ApplicationJob
  def perform(customer_import)
    customer_import.parse!
  end
end
