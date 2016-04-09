class AgreementPdfGeneratorJob < ActiveJob::Base

  queue_as :pdfs

  def perform(agreement)
    ContractService.new(agreement).pdf_to_s3
  end

end