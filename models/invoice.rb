class Invoice < ActiveRecord::Base

  include Remindable

  belongs_to  :contractor, class_name: "User"
  belongs_to  :client, class_name: "User"
  belongs_to  :agreement
  has_many    :invoice_items, foreign_key: "invoice_id"
  has_many    :payments, class_name: "Payment::Payment", foreign_key: "invoice_id"
  accepts_nested_attributes_for :invoice_items

  validates :token, uniqueness: true
  validates :public_url_token, uniqueness: true
  before_save :default_values

  attr_accessor :contractor_name, :client_name, :symbol_first
  has_paper_trail #tracks model changes and saved meta data (like IP and user agent)
  mount_uploader :pdf, InvoicePdfUploader

  default_scope { order('created_at asc')}

  def status
    if archived_date.present?
      return "archived"
    elsif paid_date.present?
      return "paid"
    elsif sent_date.present?
      return "sent"
    elsif created_at.present?
      return "drafted"
    else
      return "new"
    end
  end

  def contractor_name
    if contractor_first_name.present? && contractor_last_name.present?
      "#{contractor_first_name} #{contractor_last_name}"
    elsif contractor_first_name.present?
      "#{contractor_first_name}"
    else
      "#{contractor.name}"
    end
  end

  def client_name
    if client_last_name.present?
      "#{client_first_name} #{client_last_name}"
    else
      "#{client_first_name}"
    end
  end

  def contractor_name_or_email
    if contractor_name.present?
      "#{contractor_name}"
    else
      "#{contractor_email}"
    end
  end

  def client_name_or_email
    if client_name.present?
      "#{client_name}"
    elsif client_company_name.present?
      "#{client_company_name}"
    else
      "#{client_email}"
    end
  end

  def check_completion
    unless self.contractor_name.present?
      return { valid: false, message: 'Please enter your name for this invoice.' }
    end
    unless self.contractor_email.present?
      return { valid: false, message: 'Please enter your email for this invoice.' }
    end
    unless self.client_email.present?
      return { valid: false, message: 'Please enter an email for your client.' }
    end
    unless self.title.present? || self.invoice_number.present? || self.issued_date.present? || self.due_date.present? || self.currency.present?
      return { valid: false, message: 'Please fill out the invoice completely.' }
    end
    if self.issued_date > self.due_date
      return { valid: false, message: 'Please make sure the due date is on or after the issued date.' }
    end

    ## Check that there's atleast 1 complete invoice item
    complete_invoice_items = self.invoice_items.where("name <> ''").where("amount > 0").where("rate > 0")
    if !complete_invoice_items.present?
      return { valid: false, message: 'Please add at least one invoice item.' }
    end

    ## Check that total amount is atleast $2
    min_amount_obj = Money.new(200, "USD") ## Amount in cents
    min_amount = "%.2f" % min_amount_obj.exchange_to(self.currency).amount.to_f
    if self.total_amount < min_amount.to_f
      amount = Money.new(min_amount.to_f*100, self.currency).format
      return { valid: false, message: "Please make sure your invoice total is at least #{amount}." }
    end

    return { valid: true, message: '' }
  end

  def subtotal
    subtotal = 0.0
    invoice_items.each do |invoice_item|
      if invoice_item.name.present? && invoice_item.amount.present? && invoice_item.rate.present?
        subtotal = subtotal + (invoice_item.amount.to_f * invoice_item.rate.to_f)
      end
    end
    subtotal
  end

  def tax_amount
    tax_amount = 0.0
    if tax_percent.present? && tax_percent.to_f > 0
      tax_amount = subtotal * (tax_percent.to_f / 100.0)
    end
    tax_amount
  end

  def amount_due
    amount_due = 0
    if total_amount.present?
      amount_due  = total_amount
      days_late   = 0
      late_fee    = self.late_fee.present? ? self.late_fee : 0
      due_date    = self.due_date
      timezone    = self.timezone
      if sent_date.present? && paid_date == nil && timezone.present? && due_date.present? && late_fee.to_f > 0
        ## NOTE: Late fee is currently non-compounding, only based on the total_amount, not the total_amount and late fees
        late_amount = (total_amount * late_fee.to_f/100)
        todays_date = Time.now.in_time_zone(timezone).to_date
        if todays_date > due_date
          ## If 1 day over due_date, then add late fee
          days_late = (todays_date - due_date).to_i
          if days_late > 0
            amount_due = total_amount + late_amount
          end

          ## If months over due_date (plus one day), add late fee for every additional month
          due_date = due_date + 1.day
          months_after_first_fee = (due_date.year - todays_date.year) * 12 + todays_date.month - due_date.month - (todays_date.day >= due_date.day ? 0 : 1)
          if months_after_first_fee > 0
            amount_due = amount_due + (months_after_first_fee * late_amount)
          end
        end
      elsif sent_date.present? && paid_date.present?
        amount_due = 0
      end
    end
    return amount_due
  end

  private

  def default_values
    self.contractor_email = self.contractor_email.strip.downcase if self.contractor_email.present?
    self.client_email     = self.client_email.strip.downcase if self.client_email.present?
    self.timezone         = "Pacific Time (US & Canada)" unless self.timezone.present?
    set_tokens
  end

  def set_tokens
    unless self.token.present?
      begin
        token = SecureRandom.hex[0..14]
      end while Invoice.exists?(:token => token)
      self.token = token
    end
    unless self.public_url_token.present?
      begin
        public_url_token = SecureRandom.hex[0..14]
      end while Invoice.exists?(:public_url_token => public_url_token)
      self.public_url_token = public_url_token
    end
  end
end