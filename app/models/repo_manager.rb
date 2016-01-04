class RepoManager < ActiveRecord::Base
  def self.with_active_privileges(user)
    return false unless user.present?

    if user.respond_to?(:user_key)
      username = user.user_key
    else
      username = user.to_sym
    end

    self.find_by(username: username, active: true)
  end

  def self.with_active_privileges?(user)
    with_active_privileges(user) ? true : false
  end

  def self.usernames
    RepoManager.pluck(:username)
  end
end
