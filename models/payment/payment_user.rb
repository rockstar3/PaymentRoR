module Payment
  class PaymentUser < ActiveRecord::Base
    belongs_to :user
    has_many :escrow_items, class_name: "EscrowItem"
    has_many :escrow_item_events, class_name: "EscrowItemEvent"
    has_many :payments, class_name: "Payment::Payment", foreign_key: "payment_user_id"
    has_paper_trail

    delegate :address_line1, :address_line2, :city, :state_governing_law, :country, :date_of_birth, :phone_number, to: :user

    private
  end
end