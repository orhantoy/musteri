class FinalizeCustomerImportJob < ApplicationJob
  before_enqueue do |job|
    job.arguments.first.touch(:started_finalizing_at)
  end

  def perform(customer_import)
    customer_import.finalize!
  end
end
