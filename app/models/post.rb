class Post < ActiveRecord::Base
  attr_accessible :content, :user
	belongs_to :user

end
