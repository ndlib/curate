class RepoManager < ActiveRecord::Base
  validates_uniqueness_of :username

  def self.usernames
    RepoManager.all.collect{|manager| manager.username }
  end

  def active?
    self.active == true
  end
end
