class Quote < ActiveRecord::Base
  attr_accessible :author, :category_id, :quote, :tags
  belongs_to :category
end
