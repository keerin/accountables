# ------------------------
# Accountabl.es
# Author: Kieran McNairn
# V0.1
# ------------------------

# Require everything needed

require 'rubygems'

require 'sinatra'
require 'haml'
require 'tilt/haml'
require 'sinatra/flash'

require 'warden'
require 'bcrypt'
require 'data_mapper'
require 'dm-sqlite-adapter'

require './model'
require 'bundler'
Bundler.require

# Set up Warden authentication and strategies

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && params['user']['username'] && params['user']['password']
  end

  def authenticate!
    user = User.first(username: params['user']['username'])

    if user.nil?
      throw(:warden, message: "The username you entered does not exist.")
    elsif user.authenticate(params['user']['password'])
      success!(user)
    else
      throw(:warden, message: "The username and password combination doesn't exist")
    end
  end
end

class Accountables < Sinatra::Base

  enable :sessions
  register Sinatra::Flash
  set :session_secret, "supersecret"

  use Warden::Manager do |config|
    # Tell Warden how to save our User info into a session.
    # Sessions can only take strings, not Ruby code, we'll store
    # the User's `id`
    config.serialize_into_session{|user| user.id }
    # Now tell Warden how to take what we've stored in the session
    # and get a User from that information.
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      # "strategies" is an array of named methods with which to
      # attempt authentication. We have to define this later.
      strategies: [:password],
      # The action is a route to send the user to when
      # warden.authenticate! returns a false answer. We'll show
      # this route below.
      action: 'auth/unauthenticated'
    # When a user tries to log in and cannot, this specifies the
    # app to send the user to.
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end
  
# Set up root redirect structure

  get '/' do
    redirect '/myaccount'
  end

# Warden login and logout authentication routes

  get '/auth/login' do
    haml :login, layout_engine: :haml
  end

  post '/auth/login' do
    env['warden'].authenticate!

    flash[:success] = "Successfully logged in"
    
    if session[:return_to].nil?
      redirect '/myaccount'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/auth/login'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?

  # Set the error and use a fallback if the message is not defined
    flash[:error] = env['warden.options'][:message] || "You must log in"
    redirect '/auth/login'
  end

# My own register GET and POST routes

  get '/register' do
    haml :register, layout_engine: :haml
  end

  post '/register' do
    User.create(
      :name           => params[:name],
      :username       => params[:username],
      :habit          => params[:habit],
      :password       => params[:password],
      :current_streak => '0',
    )
    redirect '/myaccount'
  end

# My Account page - ie where the magic happens
  
  get '/myaccount' do
    env['warden'].authenticate!
    
    session['name'] = env['warden'].user[:name]
    session["habit"] = env['warden'].user[:habit].downcase
    session["current_streak"] = env['warden'].user[:current_streak]
    
    haml :myaccount, layout_engine: :haml
  end
  
  post '/myaccount' do
    if params{"Yep!"}
      @user = User.first(name: session['name'])
      @user.current_streak +=1
      @user.save
      session["current_streak"] = @user.current_streak
    end
    haml :myaccount, layout_engine: :haml
  end
  
end
