module Payment
  class EscrowItemEvent < ActiveRecord::Base
    belongs_to :escrow_item, class_name: 'EscrowItem'
    belongs_to :payment_user, class_name: 'PaymentUser'
    default_scope { order('created_at desc')}

    def text
      if status_key == 'drafted'
        return "<b>#{data['creator']['name']}</b> drafted the escrow terms."

      elsif status_key == 'sent_to_recipient'
        return "<b>#{data['sender']['name']}</b> sent the escrow terms to <b>#{data['recipient']['email']}</b> for approval."

      elsif status_key == 'approved_by_recipient'
        if data['sender']['id'] == data['contractor']['id']
          recipient_name = data['client']['name']
        else
          recipient_name = data['contractor']['name']
        end
        return "<b>#{recipient_name}</b> approved the escrow terms."

      elsif status_key == 'payment_deposited'
        return "<b>#{data['client']['name']}</b> deposited #{data['pp_data']['amount']} into the escrow vault."

      elsif status_key == 'refund_flagged'
        return "<b>#{data['client']['name']}</b> requested a refund."

      elsif status_key == 'partially_refunded'
        return "<b>#{data['contractor']['name']}</b> refunded #{ActionController::Base.helpers.number_to_currency(data['refunded_amount'], precision: 2)} from the total amount held in the escrow vault."

      elsif status_key == 'refunded'
        return "<b>#{data['contractor']['name']}</b> refunded the remaining funds held in the escrow vault."

      elsif status_key == 'completed'
        return "<b>#{data['client']['name']}</b> released the escrow of #{data['pp_data']['amount']} to <b>#{data['contractor']['name']}</b>."
      else
        Airbrake.notify(
          :error_class      => "No text entered for EscrowItemEvent status:",
          :error_message    => "Needing text in mode for status: ID ##{status_key}",
          :environment_name => Rails.env
        )
        return ""
      end
    end

  end
end