class User < ActiveRecord::Base
   attr_accessible :email, :first_name, :last_name, :password
  
   validates_presence_of :email, :password, :first_name, :last_name
   validates_uniqueness_of :email
   validates_uniqueness_of :email, :case_sensitive => false
   validates_length_of :email, :within => 6..50
   validates_length_of :password, :within => 6..30

   before_save { |user| user.email = email.downcase }

end
