class Invitation < ActiveRecord::Base
  has_many :guests, :dependent => :delete_all
end
