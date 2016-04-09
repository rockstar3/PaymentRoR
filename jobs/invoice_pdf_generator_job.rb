class InvoicePdfGeneratorJob < ActiveJob::Base

  queue_as :pdfs

  def perform(invoice)
    InvoiceService.new(invoice: invoice).pdf_to_s3
  end

end