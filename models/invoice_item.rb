class InvoiceItem < ActiveRecord::Base
  belongs_to  :invoice
  before_save :default_values
  default_scope { order('created_at asc')}
  attr_accessor :destroy
  has_paper_trail #tracks model changes and saved meta data (like IP and user agent)

  private

  def default_values
  end
end