Rails.configuration.stripe = {
  :publishable_key => 'pk_test_Mjb03gv0kQ0aLkjd5Q6rwu7B',
  :secret_key      => 'sk_test_UltQvzhLQIuN8USaRpIl17wj'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]