class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  validates_presence_of :user_id, :friend_id
  #ensures that the (user_id,friend_id) pair is unique
  validates_uniqueness_of :user_id, :scope => :friend_id

  acts_as_paranoid

end
