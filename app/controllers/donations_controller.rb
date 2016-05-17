require 'json'
require 'faraday'
require 'stripe'

class DonationsController < ApplicationController

  def new
    @user_id = params[:user_id] if params[:user_id]
    @charity_name = params[:charity_name]
    @submission_id = params[:submission_id]
    @charity_id = params[:charity_id]
    @amount = params[:amount] ? (params[:amount]).to_i * 100 : 300
    @charity_category_id = params[:charity_category_id]
    @contact_me = params[:contact_me]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @phone = params[:phone]

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
    @email = params[:email]
    @charity_category_id = params[:charity_category_id]
    @contact_me = params[:contact_me]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @phone = params[:phone]

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :source    => params[:stripeToken],
      :amount      => @amount,
      :description => @charity_name,
      :currency    => 'aud'
    )

    # Change these to params
    payload = {:donation => {:amount => @amount, :email => @email, :phone => @phone, :first_name => @first_name, :last_name => @last_name, :charity_category_id => @charity_category_id, :contact_me => @contact_me, :charity_id => @charity_id, :submission_id => @submission_id, :user_id => @user_id, :charity_name => params[:charity_name]}}
    # payload = {:donation => {:amount => 1000, :charity_id => 1, :submission_id => 98,:user_id => 1,:charity_name => "Greenpeace"}}

    if charge['paid'] == true
      response = @conn.post "/donations", payload

      if response.status == 200
        # puts "user_id:" + @user_id if @user_id
        # puts "charity_name:" + @charity_name if @charity_name
        # puts "submission_id:" + @submission_id if @submission_id
        # puts "charity_id:" + @charity_id if @charity_id
        # puts "amount:" + @amount.to_s if @amount
        # puts "email:" + @email if @email
        if params[:email]
          redirect_to "http://www.smallchangegiving.co/thanks?email=" + @email
        else
          redirect_to "http://www.smallchangegiving.co/thanks"
        end
      end
    end

    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_donation_path
  end
end
