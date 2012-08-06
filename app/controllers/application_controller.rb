class ApplicationController < ActionController::Base
    include ApplicationHelper
    helper_method :isLoggedIn?, :currentUser, :getTags

    protect_from_forgery

    def isLoggedIn?
      if session[:loggedIn]
        puts 'User logged in'
        return session[:loggedIn]
      else
        return false
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
