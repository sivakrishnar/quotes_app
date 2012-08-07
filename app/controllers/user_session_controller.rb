class UserSessionController < ApplicationController
  # Login Facebook
  def login_facebook
     url = "https://www.facebook.com/dialog/oauth?client_id=#{getFacebookApiKey()}&scope=email,publish_stream&redirect_uri=#{getAppUrl()}login/facebook/callback"
     redirect_to url
  end
  
  # Login Twitter
  def login_twitter
    require 'oauth/consumer'
    @consumer=OAuth::Consumer.new "0pq5YGD7IU2CFYbA2cYiw", 
                                  "mO1NbrDJidvxXL5i4itbvKMkF2ny1bokOBJ4NII", 
                                   {:site=>"https://api.twitter.com/oauth/request_token"}
    request_token = @consumer.get_request_token
    session[:twitter_request_token] = request_token
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:twitter_access_token] = access_token
    puts 'Requested twitter token and stored request token in session '+session[:twitter_request_token]+" and access token is #{session[:twitter_access_token]}"
    puts "Now redirecting to #{request_token.authorize_url}"
    redirect_to request_token.authorize_url
  end

  # Login Facebook callback
  def login_facebook_callback
    require 'json'
    require 'rest_client'

    str_error = "There was an error trying to login to your Facebook account, please try again."

    if(params[:error] and params[:error] != '')
       flash[:error] = str_error
       puts params[:error]
       redirect_to '/fblogin'
    elsif(params[:code] and params[:code] != '')
      puts "Got code back..."
       code = params[:code]
       url = "https://graph.facebook.com/oauth/access_token?client_id=#{getFacebookApiKey()}&client_secret=#{getFacebookSecret()}&redirect_uri=#{getAppUrl()}login/facebook/callback&code=#{code}"
       puts url
       r = RestClient.get url
       puts r.to_s.gsub(/\&expires\=\d*$/,'')
       access_token = r.to_s.split("access_token=")[1]
       session[:access_token] = access_token.gsub(/\&expires\=\d*$/,'')
       puts uri_escape(session[:access_token])
       graph_url = "https://graph.facebook.com/me?access_token=#{uri_escape(session[:access_token])}"
       puts graph_url
       r = RestClient.get graph_url
       user = JSON.parse(r.to_s)
       doFacebookLogin(user)
       flash[:notice] = "You have logged in successfully, access_token is #{session[:access_token]}"
       redirect_to '/quotes'
    else
       flash[:error] = str_error
       puts "unknown error"
       redirect_to '/fblogin'
    end
  end

  def doFacebookLogin(user)
    puts "#{user} logged in successfully with facebook #{user.class}"
    puts 'Storing first name in session ...'+user['first_name']
    session[:currentuser] = user['first_name']
    session[:username] = user['username']
    session[:loggedIn] = true
  end

  def logout_facebook
    url = "https://www.facebook.com/logout.php?next=#{getAppUrl()}&access_token=#{session[:access_token]}"
    puts url
    reset_session
    redirect_to url
  end

  def post_to_facebook()
   require 'json'
   require 'rest_client'

   login_facebook unless session or session.has_key?access_token or session[:access_token]
   if params[:quote_id]
      quote = Quote.find(params[:quote_id])
      puts "Posting quote #{quote.quote}"
      link = getAppUrl()+'quotes/'+quote.id.to_s
      puts session[:access_token]
      puts uri_escape(session[:access_token]) 
      url = "https://graph.facebook.com/#{session[:username]}/feed?access_token=#{uri_escape(session[:access_token])}&message=#{uri_escape(quote.quote)}&link=#{link}&caption=#{uri_escape('Posted via QuotesApp')}"
      puts url
      begin
        r = RestClient.post "https://graph.facebook.com/#{session[:username]}/feed", { :access_token => session[:access_token], :message => "#{quote.quote} -- by #{quote.author}", :link => "http://quotesapp.herokuapp.com/quotes/#{params[:quote_id]}", :caption => "Shared via quotesapp", :icon => "http://quotesapp.herokuapp.com/assets/quote_header.jpg" }
        responsegot = JSON.parse r.to_s
        flash[:notice] = 'Share on your facebook timeline success...'
        redirect_to '/quotes'
      rescue Exception => ex
        flash[:notice] = ex.message
        puts ex
        redirect_to '/quotes'
      end
      #client = FBGraph::Client.new(:client_id => getFacebookApiKey(), :secret_id => getFacebookSecret() ,:token => session[:access_token])
      #user = client.selection.me.info!
      #client.selection.me.publish!(:message => quote.quote, :name => 'QuotesApp', :link => getAppUrl()+'quotes/'+quote.id.to_s)
    end
  end

end
