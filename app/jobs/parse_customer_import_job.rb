class ParseCustomerImportJob < ApplicationJob
  after_enqueue do |job|
    job.arguments.first.touch(:started_parsing_at)
  end

  def perform(customer_import)
    if customer_import.parsed_header_at?
      customer_import.parse_with_dynamic_headers!
    else
      customer_import.parse!
    end
  rescue => e
    customer_import.update(
      parsing_failed_at: Time.zone.now,
      parsing_failure_message: "Something went wrong while parsing the file",
    )

    Rails.logger.error e.message
  end
end
