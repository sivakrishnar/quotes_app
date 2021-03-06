class ApplicationController < ActionController::Base
    include ApplicationHelper
    helper_method :isLoggedIn?, :currentUser, :getTags, :currentTwitterUser, :currentFacebookUser, :isLoggedInTwitter?, :isLoggedInFacebook?, :getCategories, :getAuthors, :store_url, :getStoredUrl
    @categories = []
    @authors = []
    @tags = []

    protect_from_forgery
    
    def getCategories
      unless @categories
        @categories = Category.select("name").find(:all)
      else
        return @categories
      end
    end
    
    def getAuthors
      unless @authors
        @authors = Quote.select("distinct author").find(:all).collect {|tmp| tmp.author}
      else
        return @authors
      end
    end

    def store_url
      puts request.referrer
      session[:from_url] = request.referrer
    end

    def getStoredUrl
      session[:from_url] ? session[:from_url] : request.env['HTTP_HOST']+'/'
    end

    #### main logged in method
    def isLoggedIn?
      if session[:loggedIn] 
        true 
      else
        store_url
        false
      end	
    end
    
    def isLoggedInTwitter?
      session[:twitter_loggedIn] ? true : false
    end
    
    def currentTwitterUser
       session[:twitter_currentuser] ? session[:twitter_currentuser] : nil
    end

    def isLoggedInFacebook?
      session[:facebook_loggedIn] ? true : false
    end

    def currentFacebookUser
      session[:facebook_currentuser] ? session[:facebook_currentuser] : nil
    end

    def currentUser
      if session[:user_id]
         @current_user ||= User.find(session[:user_id]) if session[:user_id]
      else
         return nil
      end	 
    end
    
    def getTags
      unless @tags
        quotes = Quote.select('tags').find(:all)
        @tags = [] 
        quotes.each do |quote|
          if quote
            if quote.tags
              tags = quote.tags.split(' ')
              tags.each do |tag|
                @tags.push tag unless @tags.include?tag
              end
            end
          end
        end
	return @tags.uniq.sort
      else
        return @tags
      end
    end

end
