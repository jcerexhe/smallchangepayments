require 'json'
require 'faraday'

class DonationsController < ApplicationController

  def new
    @user_id = params[:user_id] if params[:user_id]
    @charity_name = params[:charity_name]
    @submission_id = params[:submission_id]
    @charity_id = params[:charity_id]
    @amount = params[:amount] ? (params[:amount]).to_i * 100 : 300
    @charity_category_id = params[:charity_category_id]
  end

  def create
    @conn = Faraday.new(:url => 'http://www.smallchangegiving.co') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    @user_id = params[:user_id]
    @charity_name = params[:charity_name]
    @submission_id = params[:submission_id]
    @charity_id = params[:charity_id]
    @amount = params[:amount] ? (params[:amount]).to_i * 100 : 300
    @charity_category_id = params[:charity_category_id]

    charge = Stripe::Charge.create(
      :source    => params[:stripeToken],
      :amount      => @amount,
      :description => params[:charity_name],
      :currency    => 'aud'
    )

    # Change these to params
    payload = {:donation => {:amount => @amount, :charity_category_id => @charity_category_id, :charity_id => @charity_id, :submission_id => @submission_id, :user_id => @user_id, :charity_name => params[:charity_name]}}
    # payload = {:donation => {:amount => 1000, :charity_id => 1, :submission_id => 98,:user_id => 1,:charity_name => "Greenpeace"}}

    if charge['paid'] == true
      @conn.post "/donations", payload
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_donation_path
  end

end




