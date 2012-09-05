class UserSessionController < ApplicationController

  def new
    if isLoggedIn?
      reset_session
    else
      puts 'Rendering login page...'
    end
  end

  def create 
     user = User.authenticate(params[:user_session][:email], params[:user_session][:password])  
     if user  
        session[:user_id] = user.id  
	session[:loggedIn] = true
	puts "Logged in #{session[:user_id]}"
        redirect_to getStoredUrl, :notice => "Logged in!"  
     else
        puts "Invalid email or password"
        flash.now.alert = "Invalid email or password" 
	reset_session
        render "new"  
     end  
  end  
    
  def destroy  
     session[:user_id] = nil
     session[:loggedIn] = false
     reset_session
     redirect_to root_url, :notice => "Logged out!"  
  end 

  # Login Facebook
  def login_facebook
     if isLoggedIn?
       url = "https://www.facebook.com/dialog/oauth?client_id=#{getFacebookApiKey()}&scope=email,publish_stream&redirect_uri=#{getAppUrl()}login/facebook/callback"
       redirect_to url
     else
       redirect_to login_url, :notice => "Please login"
     end
  end
  
  # Login Twitter
  def login_twitter
    if isLoggedIn?
       @client = TwitterOAuth::Client.new(
                        :consumer_key => getTwitterConsumerKey(),
                        :consumer_secret => getTwitterConsumerSecret()
                        )
       oauth_confirm_url = getAppUrl()+'login_twitter_callback'
       request_token = @client.request_token(:oauth_callback => oauth_confirm_url)
       session[:twitter_request_token] = request_token.token
       session[:twitter_request_token_secret] = request_token.secret
       redirect_to request_token.authorize_url
     else
       redirect_to login_url, :notice => "Please login"
     end
  end
  
  # Login Twitter callback
  def login_twitter_callback
   ###oauth_token = getTwitterConsumerKey()
   ###oauth_token_secret = getTwitterConsumerSecret()
   puts "Twitter login callback ... #{request.url}"
   @client = TwitterOAuth::Client.new(
      :consumer_key => getTwitterConsumerKey(),
      :consumer_secret => getTwitterConsumerSecret()
      )
   @access_token = @client.authorize(
        session[:twitter_request_token],
        session[:twitter_request_token_secret],
        :oauth_verifier => params[:oauth_verifier]
    )
    
    if @client.authorized?
       # Storing the access tokens so we don't have to go back to Twitter again
       # in this session.  In a larger app you would probably persist these details somewhere.
       session[:twitter_access_token] = @access_token.token
       session[:twitter_secret_access_token] = @access_token.secret
       session[:twitter_loggedIn] = true
       session[:twitter_currentuser] = @client.info["name"]
       puts "Redirecting to home page after twitter authentication"
       flash[:notice] = "Successfully authenticated twitter account to post quotes..."
       redirect_to '/quotes'
    end
  end

  # Login Facebook callback
  def login_facebook_callback
    require 'json'
    require 'rest_client'

    str_error = "There was an error trying to login to your Facebook account, please try again."
    puts "login facebook callback request received...#{request.url}"
    if(params[:error] and params[:error] != '')
       flash[:error] = str_error
       puts params[:error]
       redirect_to '/login'
    elsif(params[:code] and params[:code] != '')
      puts "Got code back..."
       code = params[:code]
       url = "https://graph.facebook.com/oauth/access_token?client_id=#{getFacebookApiKey()}&client_secret=#{getFacebookSecret()}&redirect_uri=#{getAppUrl()}login/facebook/callback&code=#{code}"
       puts url
       r = RestClient.get url
       puts r.to_s.gsub(/\&expires\=\d*$/,'')
       access_token = r.to_s.split("access_token=")[1]
       session[:facebook_access_token] = access_token.gsub(/\&expires\=\d*$/,'')
       graph_url = "https://graph.facebook.com/me?access_token=#{uri_escape(session[:facebook_access_token])}"
       puts graph_url
       r = RestClient.get graph_url
       user = JSON.parse(r.to_s)
       session[:facebook_loggedIn] = true
       session[:facebook_currentuser] = user['first_name']+' '+user['last_name']
       session[:facebook_username] = user['username']
       puts "#{user} logged in successfully with facebook #{user.class}"
       flash[:notice] = "Facebook authentication successfull, Now you can share to your facebook wall."
       redirect_to '/quotes'
    else
       flash[:error] = str_error
       puts "unknown error"
       redirect_to '/fblogin'
    end
  end

  def logout_facebook
    ##url = "https://www.facebook.com/logout.php?next=#{getAppUrl()}&access_token=#{session[:access_token]}"
    ##puts url
    session[:facebook_loggedIn] = false
    session[:facebook_access_token] = nil
    session[:facebook_currentuser] = nil
    session[:facebook_username] = nil
    redirect_to '/'
  end

  def post_to_facebook()
   require 'json'
   require 'rest_client'
   quote_id = params[:quote_id]

   if not isLoggedIn? 
     redirect_to '/login'
     return
   elsif not isLoggedInFacebook?
      redirect_to '/fblogin'
   end

   if quote_id
      quote = Quote.find(quote_id)
      puts "Posting quote #{quote.quote}"
      link = getAppUrl()+'quotes/'+quote.id.to_s
      ####url = "https://graph.facebook.com/#{session[:facebook_username]}/feed?access_token=#{uri_escape(session[:facebook_access_token])}&message=#{uri_escape(quote.quote)}&link=#{link}&caption=#{uri_escape('Posted via QuotesApp')}"
      ####puts url
      begin
        r = RestClient.post "https://graph.facebook.com/#{session[:facebook_username]}/feed", { :access_token => session[:facebook_access_token], :message => "#{quote.quote} -- by #{quote.author}", :link => "http://quotesapp.herokuapp.com/quotes/#{params[:quote_id]}", :caption => "Shared via quotesapp", :icon => "http://quotesapp.herokuapp.com/assets/quote_header.jpg" }
        responsegot = JSON.parse r.to_s
        flash[:notice] = 'Share on your facebook timeline success...'
        redirect_to '/quotes'
      rescue Exception => ex
        flash[:notice] = ex.message
        puts ex
        redirect_to '/quotes'
      end
    end
  end
  
   def post_to_twitter()
     ####oauth_token = "0pq5YGD7IU2CFYbA2cYiw"
     ####oauth_token_secret = "mO1NbrDJidvxXL5i4itbvKMkF2ny1bokOBJ4NII"
     if not isLoggedIn?
       redirect_to '/login'
       return
     elsif not isLoggedInTwitter?
       redirect_to '/twitterlogin'
     end

     if params[:quote_id]
        quote = Quote.find(params[:quote_id])
        puts "Tweeting quote #{quote.quote}"
        link = getAppUrl()+'quotes/'+quote.id.to_s
        begin
          @client = TwitterOAuth::Client.new(
	       :consumer_key => getTwitterConsumerKey(),
	       :consumer_secret => getTwitterConsumerSecret(),
	       :token => session[:twitter_access_token],
	       :secret => session[:twitter_secret_access_token]
          )

	  if @client.authorized?
	     userinfo = @client.info
             @client.update(quote.quote+" -- #{quote.author}, Posted via #{link}")
             flash[:notice] = 'Tweeted successfully to your twitter account...'
             redirect_to '/quotes'
          else
             redirect_to '/twitterlogin'
          end
        rescue Exception => ex
          flash[:notice] = ex.message
          puts ex
          redirect_to '/quotes'
        end
      end
  end

end
