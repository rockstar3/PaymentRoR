module Payment
  Stripe.api_key = Rails.application.secrets.stripe_secret_key

  # API_HOSTNAME = ENV["PP_API_HOSTNAME"] || 'https://test.api.promisepay.com' # The environment API URL
  # ADMIN_USER = ENV["PP_ADMIN_USER"] || 'nish@hellobonsai.com' # The email address used to create the marketplace
  # ADMIN_TOKEN = ENV["PP_ADMIN_TOKEN"] || '8956b4db435fa77d1466caacfafb03e9' # The API key

  # # 5% for freelancers paying-out
  # BONSAI_ESCROW_FEE = (Rails.env == 'production' ? '8f7db3e1-f9a9-4aab-b144-2e8956c90c6b' : '62f16b89-fc93-41a7-8a21-739e11c74d4f')

  # # 2.9% for clients paying-in
  # CLIENT_CC_FEE = (Rails.env == 'production' ? 'af681e36-a965-4b6c-9d63-56e8f62e2b42' : 'a7ed8686-e5db-4bd7-9d07-3c967a7fe518')

  # # $25 for freelancers paying-out
  # INT_WIRE_FEE = (Rails.env == 'production' ? '792c3d6c-f906-4308-8935-78910efa3d08' : '0784428f-815b-491c-920b-bfc460722f94')
end