class ParseCustomerImportHeaderJob < ApplicationJob
  after_enqueue do |job|
    job.arguments.first.touch(:started_parsing_header_at)
  end

  def perform(customer_import)
    customer_import.parse_header!
  rescue => e
    customer_import.update(
      parsing_failed_at: Time.zone.now,
      parsing_failure_message: "Something went wrong while parsing the header of the file",
    )

    Rails.logger.error e.message
  end
end
