module Payment
  class API

    def self.create_user(user)
      # freelancers and clients have the same endpoint with same params
      # returns token
    end

    def self.create_bank_account(params)
      # returns token
    end

    def self.create_card_account(params)
      # returns token
    end

    def self.create_paypal_account(params)
      # returns token
    end

    def self.add_freelancer_disbursement_account(params)
      # returns status
    end

    def self.create_escrow_item(params)
      # returns token
    end

    def self.get_session_token_for_widget(params)
      # returns token for widget
      auth = {:username => Payment::ADMIN_USER, :password => Payment::ADMIN_TOKEN}
      session_seller = HTTParty.get(Payment::API_HOSTNAME + "/request_session_token?" + params.to_param, :basic_auth => auth)
    end

    def self.cancel_escrow_item(id)
      # cancels pending escrow item by id
      auth = {:username => Payment::ADMIN_USER, :password => Payment::ADMIN_TOKEN}
      result = HTTParty.delete(Payment::API_HOSTNAME + "/items/#{id}", :basic_auth => auth)
    end

    def self.get_escrow_item(id)
      # returns escrow item data by id
      auth = {:username => Payment::ADMIN_USER, :password => Payment::ADMIN_TOKEN}
      result = HTTParty.get(Payment::API_HOSTNAME + "/items/#{id}", :basic_auth => auth)
    end

    def self.get_escrow_item_status(id)
      # returns escrow item data by id
      auth = {:username => Payment::ADMIN_USER, :password => Payment::ADMIN_TOKEN}
      result = HTTParty.get(Payment::API_HOSTNAME + "/items/#{id}/status", :basic_auth => auth)
    end

    def self.get_items_by_user(id)
      # returns all escrow items by user id
      auth = {:username => Payment::ADMIN_USER, :password => Payment::ADMIN_TOKEN}
      result = HTTParty.get(Payment::API_HOSTNAME + "/users/#{id}/items", :basic_auth => auth)
    end

  end
end