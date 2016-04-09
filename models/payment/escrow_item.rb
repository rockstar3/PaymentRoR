module Payment
  class EscrowItem < ActiveRecord::Base
    belongs_to :contractor, class_name: 'PaymentUser'
    belongs_to :client, class_name: 'PaymentUser'
    belongs_to :sender, class_name: 'PaymentUser'
    belongs_to :agreement, class_name: 'Agreement'
    has_many :escrow_item_events, class_name: 'EscrowItemEvent'
    has_paper_trail

    validates :amount, :format => { :with => /\A\d+(?:\.\d{0,2})?\z/ }, :numericality => {:greater_than => 0, :message => "Your escrow payment's amount must be greater than zero."}, :presence => {:message => "Your escrow payment's amount must be greater than zero."}
    validates :deposit_amount, :format => { :with => /\A\d+(?:\.\d{0,2})?\z/ }, :numericality => {:greater_than_or_equal_to => 0, :message => "Your escrow payment's deposit cannot be a negative number."}, :presence => {:message => "Your escrow payment's deposit cannot be a negative number."}

    # Virtual attributes (not stored in database)
    attr_accessor :sender_role,
                  :sender_country,
                  :sender_has_company,
                  :sender_company_name,
                  :sender_company_type,
                  :sender_title,
                  :recipient_country,
                  :recipient_has_company,
                  :recipient_company_name,
                  :recipient_company_type,
                  :recipient_title,
                  :recipient_message

    scope :visible_to, ->(user) do
      where('contractor_id=? OR client_id=? OR recipient_email=?', user.payment_user.id, user.payment_user.id, user.email)
    end

    def status
      PaymentsHelper.convert_status(status_key)
    end

  end
end