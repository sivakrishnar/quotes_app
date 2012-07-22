class ApplicationController < ActionController::Base
    include ApplicationHelper
    helper_method :isLoggedIn?, :currentuser

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
         return ''
       end	 
    end

end
