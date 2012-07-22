module ApplicationHelper

  def getTwitterConsumerKey()
    return 'twitter_consumer_key'
  end

  def getTwitterConsumerSecret()
    return 'twitter_secret_key'
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
   return 'http://quotesapp.heroku.com/'
  end

  def uri_escape(url)
    require 'uri'
    str = URI.escape(url)
    return str
  end

end
