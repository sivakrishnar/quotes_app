class UserSessionController < ApplicationController
  # Login Facebook
  def login_facebook
     url = "https://www.facebook.com/dialog/oauth?client_id=#{getFacebookApiKey()}&scope=email&redirect_uri=#{getAppUrl()}login/facebook/callback"
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
       r = RestClient.get url
       access_token = r.to_s.split("access_token=")[1]
       graph_url = "https://graph.facebook.com/me?access_token=#{access_token.uri_escape}"
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

end
