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
      show = @conn.post '/donations', { user_id: params[:user_id], charity_name: params[:charity_name], charity_id: params[:charity_id], submission_id: params[:submission_id], amount: params[:amount] }
      puts '########################'
      puts show
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_charge_path
  end
  
end


      

    