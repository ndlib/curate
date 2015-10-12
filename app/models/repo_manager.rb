class RepoManager < ActiveRecord::Base
  def self.usernames
    RepoManager.pluck(:username)
  end
end
