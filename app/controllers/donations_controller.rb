require 'json'
require 'faraday'

class DonationsController < ApplicationController

  def new
    @user_id = params[:user_id] if params[:user_id]
    @charity_name = params[:charity_name]
  end

  def create
    @conn = Faraday.new(:url => 'http://www.smallchangegiving.co') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    @user_id = params[:user_id]
    @charity_name = params[:charity_name]
    @amount = params[:amount] ? params[:amount] * 100 : 300

    charge = Stripe::Charge.create(
      :source    => params[:stripeToken],
      :amount      => @amount,
      :description => params[:charity_name],
      :currency    => 'aud'
    )

    # Change these to params
    # payload = {:donation => {:amount => params[:amount], :charity_id => params[:charity], :submission_id => params[:submission_id], :user_id => params[:user_id], :charity_name => params[:charity_name]}}
    payload = {:donation => {:amount => 1000, :charity_id => 1, :submission_id => 98,:user_id => 1,:charity_name => "Greenpeace"}}

    if charge['paid'] == true
      @conn.post '/donations', payload
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to :new
  end
  
end


      

    