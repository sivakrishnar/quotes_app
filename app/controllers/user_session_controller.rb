class UserSessionController < ApplicationController
  # Login Facebook
  def login_facebook
     url = "https://www.facebook.com/dialog/oauth?client_id=#{getFacebookApiKey()}&scope=email,publish_actions&redirect_uri=#{getAppUrl()}login/facebook/callback"
     redirect_to url
  end

  # Login Facebook callback
  def login_facebook_callback
    require 'json'
    require 'rest_client'

    str_error = "There was an error trying to login to your Facebook account, please try again."

    if(params[:error] and params[:error] != '')
       flash[:error] = str_error
       redirect_to '/login'
    elsif(params[:code] and params[:code] != '')
       code = params[:code]
       url = "https://graph.facebook.com/oauth/access_token?client_id=#{getFacebookApiKey()}&client_secret=#{getFacebookSecret()}&redirect_uri=#{getAppUrl()}login/facebook/callback&code=#{code}"
       puts url
       r = RestClient.get url
       access_token = r.to_s.split("access_token=")[1]
       puts uri_escape(access_token)
       session[:access_token] = uri_escape(access_token)
       graph_url = "https://graph.facebook.com/me?access_token=#{uri_escape(access_token)}"
       puts graph_url
       r = RestClient.get graph_url
       user = JSON.parse(r.to_s)
       doFacebookLogin(user)
       flash[:notice] = "You have logged in successfully."
       redirect_to '/quotes'
    else
       flash[:error] = str_error
       redirect_to '/login'
    end
  end

  def doFacebookLogin(user)
    puts "#{user} logged in successfully with facebook #{user.class}"
    puts 'Storing first name in session ...'+user['first_name']
    session[:currentuser] = user['first_name']
    session[:username] = user['username']
    session[:loggedIn] = true
  end

  def post_to_facebook()
   login_facebook unless session[:access_token]
   if params[:quote_id]
      quote = Quote.find(params[:quote_id])
      me = FbGraph::User.me(session[:access_token])
      me.feed!(
        :message => quote.quote,
        :description => 'Posted by QuotesApp'
        )	
     end
  end

end
