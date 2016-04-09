class PaymentsBetaUser < ActiveRecord::Base
  before_validation :sanitize_email
  validates :email, uniqueness: true

  def sanitize_email
    self.email = email.strip.downcase
  end

end
