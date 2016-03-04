require 'json'
require 'faraday'

class DonationsController < ApplicationController

  def new
  end

  def show
  end

  def create
    @conn = Faraday.new(:url => 'http://www.smallchangegiving.co') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    @user_id = params[:user_id]

    charge = Stripe::Charge.create(
      :source    => params[:stripeToken],
      :amount      => 500,
      :description => params[:charity_name],
      :currency    => 'aud'
    )

    if charge['paid'] == true
      show = @conn.post '/donations', { user_id: 1, charity_name: "Greenpeace", charity_id: 1, submission_id: 41, amount: 1000 }

    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
  end
  
end


      

    