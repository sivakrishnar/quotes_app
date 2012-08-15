module ApplicationHelper

  def getTwitterConsumerKey()
    return '0pq5YGD7IU2CFYbA2cYiw'
  end

  def getTwitterConsumerSecret()
    return "mO1NbrDJidvxXL5i4itbvKMkF2ny1bokOBJ4NII"
  end

  def getGoogleClientId()
    return 'google_client_id'
  end

  def getGoogleClientSecret()
    return 'google_client_secret'
  end

  def getFacebookApiKey()
    return '329866533769138'
  end

  def getFacebookSecret()
    return '988838ac25e6f18326efa876bed9f4aa'
  end
  
  def getAppUrl()
   ###return 'http://localhost:3000/'
   return 'http://quotesapp.herokuapp.com/'
  end

  def uri_escape(url)
    require 'uri'
    str = URI.escape(url)
    return str
  end


end
