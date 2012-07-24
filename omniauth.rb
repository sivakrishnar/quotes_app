Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['329866533769138'], ENV['988838ac25e6f18326efa876bed9f4aa'],
           :scope => 'email,user_birthday,read_stream', :display => 'popup'

end