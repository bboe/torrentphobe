class User < ActiveRecord::Base
  has_many :relationships
  has_many :friends, :through => :relationships, :uniq => true
end
