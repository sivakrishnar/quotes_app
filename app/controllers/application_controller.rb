class ApplicationController < ActionController::Base
    include ApplicationHelper
    helper_method :isLoggedIn?, :currentUser, :getTags, :currentTwitterUser, :isLoggedInTwitter?, :getCategories, :getAuthors
    @categories = []
    @authors = []
    
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

    def isLoggedIn?
      @current_user ||= User.find(session[:user_id]) if session[:user_id]  
    end
    
    def isLoggedInTwitter?
      if session[:loggedInTwitter]
         puts 'User logged in twitter'
         return session[:loggedInTwitter]
      else
         return false
      end
    end
    
    def currentTwitterUser
       if session[:currenttwitteruser]
         return session[:currenttwitteruser]
       else
         return 'Not Logged In'
       end	 
    end

    def currentUser
       if session[:currentuser]
         return session[:currentuser]
       else
         return 'Not Logged In'
       end	 
    end
    
    def getTags
      quotes = Quote.select('tags').find(:all)
      @alltags = [] 
      quotes.each do |quote|
        if quote
          if quote.tags
            tags = quote.tags.split(' ')
            tags.each do |tag|
              @alltags.push tag unless @alltags.include?tag
            end
          end
        end
      end
    end

end
