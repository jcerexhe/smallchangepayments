require 'stripe'

Rails.configuration.stripe = {
  :publishable_key => ENV['SCP_STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['SCP_STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]