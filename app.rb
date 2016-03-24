# ------------------------
# Accountabl.es
# Author: Kieran McNairn
# V0.2
# ------------------------

# Require everything needed

require 'rubygems'

require 'sinatra'
require 'haml'
require 'tilt/haml'
require 'sinatra/flash'
require 'date'
require 'to_words'
require 'pony'

require 'warden'
require 'bcrypt'
require 'data_mapper'
require 'dm-aggregates'

require './model'
require './warden'
require 'bundler'
Bundler.require

# Set up Warden authentication and strategies

class Accountables < Sinatra::Base

  enable :sessions
  register Sinatra::Flash
  set :session_secret, ENV['SESSION_SECRET']
  set :method_override, true

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

    if session[:return_to].nil?
      redirect '/myaccount'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
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
  
    if params[:name].empty? || params[:username].empty? || params[:habit].empty? || params[:password].empty?
      flash[:nope] = "Please fill out all fields"
      redirect '/register'
    elsif User.count(:username => params[:username]) == 0
      User.create(
        :name           => params[:name],
        :username       => params[:username],
        :habit          => params[:habit],
        :password       => params[:password],
        :current_streak => 0,
        :last_updated   => Date.today - 1
      )
      redirect '/myaccount'
      # Need to add username and password to session.
    else
      flash[:already] = "Someone's already using that email address here"
      redirect '/register'
    end
  end
  
# My Account page - ie where the magic happens
  
  get '/myaccount' do
    env['warden'].authenticate!

    # Set up sessions so they are the same as the authenticated user
    
    session['id'] = env['warden'].user[:id]
    session['name'] = env['warden'].user[:name]
    session["habit"] = env['warden'].user[:habit].downcase
    session["current_streak"] = env['warden'].user[:current_streak].to_words
    
    # Set up user variable to be the authenticated user
    # Set the last time the habit was completed to the last updated date stored in the db
    
    @user = User.first(id: session['id'])
    last_updated = @user.last_updated
    
    if session[:current_streak] == "zero"
      @message = "You've not completed a single day yet :( Hit the button below when you have." 
    elsif session[:current_streak] == "one"
      @message =  "You have been doing this task for #{session[:current_streak]} day. Keep going!"
    else
      @message = "You have been doing this task for #{session[:current_streak]} days now, that's pretty badass!"
    end
        
    # Only show the template with the yep button if it was completed at least one day ago
    
    if Date.today > last_updated
      haml :myaccount, layout_engine: :haml
    else
      haml :myaccountnope, layout_engine: :haml
    end
  end
  
  post '/myaccount' do
    if params{"Yep!"}
      @user = User.first(id: session['id'])
      @user.current_streak +=1
      @user.last_updated = Date.today
      @user.save
      Pony.mail(:to => 'thekieran@gmail.com', :from => 'thekieran@gmail.com', :subject => 'Test message', :body => 'Kieran completed his task today!')
      session["current_streak"] = @user.current_streak.to_words
      session["last_updated"] = @user.last_updated
    end
    
    if session[:current_streak] == "zero"
      @message = "You've not completed a single day yet :( Hit the button below when you have." 
    elsif session[:current_streak] == "one"
      @message =  "You have been doing this task for #{session[:current_streak]} day. Keep going!"
    else
      @message = "You have been doing this task for #{session[:current_streak]} days now, that's pretty badass!"
    end
    
    haml :myaccountnope, layout_engine: :haml
  end

  get '/settings' do
    env['warden'].authenticate!    
    @user = User.first(id: session['id'])
    haml :settings, layout_engine: :haml
  end

  patch '/settings' do
    @user = User.first(id: session['id'])

    @user.name = params[:name]
    @user.username = params[:username]
    @user.habit = params[:habit]
    @user.password = params[:password]
    @user.save
    flash[:changed] = "Your details have been changed successfully."
    redirect '/'
  end

  get '/confirm-delete' do
    env['warden'].authenticate!
    @user = User.first(id: session['id'])
    haml :delete, layout_engine: :haml
  end

  delete '/confirm-delete' do
    flash[:deleted] = "Your account has been successfully deleted. Come back soon!"
    @user = User.first(id: session['id'])
    @user.destroy
    redirect '/'
  end
end
