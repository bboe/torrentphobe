class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  #ensures that the (user_id,friend_id) pair is unique
  validates_uniqueness_of :user_id, :scope => :friend_id
end
