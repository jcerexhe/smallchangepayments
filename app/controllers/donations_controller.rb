require 'json'
require 'faraday'

class DonationsController < ApplicationController

  def new
    @user_id = params[:user_id] if params[:user_id]
    @charity_name = params[:charity_name]
    @submission_id = params[:submission_id]
    @charity_id = params[:charity_id]
    @amount = params[:amount] ? (params[:amount]).to_i * 100 : 300
  end

  def create
    @conn = Faraday.new(:url => 'http://smallchangegiving.co') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    @user_id = params[:user_id]
    @charity_name = params[:charity_name]
    @submission_id = params[:submission_id]
    @charity_id = params[:charity_id]
    @amount = params[:amount] ? (params[:amount]).to_i * 100 : 300
    @email = params[:email]

    charge = Stripe::Charge.create(
      :source    => params[:stripeToken],
      :amount      => @amount,
      :description => params[:charity_name],
      :currency    => 'aud'
    )

    payload = {:donation => {:amount => @amount, :charity_id => @charity_id, :submission_id => @submission_id, :user_id => @user_id, :charity_name => params[:charity_name], :email => params[:email]}}

    if charge['paid'] == true
      response = @conn.post "/donations", payload

      if response.status == 200
        puts @user_id
        puts @charity_name
        puts @submission_id
        puts @charity_id
        puts @amount
        puts @email
        redirect_to "http://smallchangegiving.co/thanks?amount=" + @amount.to_s + "&charity_id=" + @charity_id.to_s + "&submission_id=" + @submission_id.to_s
      end
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_donation_path
  end
end




