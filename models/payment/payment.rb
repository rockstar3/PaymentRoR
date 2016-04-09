module Payment
  class Payment < ActiveRecord::Base
    belongs_to :contractor, class_name: 'User', foreign_key: "contractor_id"
    belongs_to :client, class_name: 'User', foreign_key: "client_id"
    belongs_to :payment_user, class_name: 'PaymentUser'
    belongs_to :agreement, class_name: 'Agreement'
    belongs_to :invoice, class_name: 'Invoice'
    has_paper_trail
  end
end