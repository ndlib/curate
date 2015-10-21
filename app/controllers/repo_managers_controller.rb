class RepoManagersController < ApplicationController
  with_themed_layout '1_column'

  def edit
    @repo_manager = find_repo_manager!
  end

  def update
    @repo_manager = find_repo_manager!
    @repo_manager.active = params[:repo_manager][:active]
    @repo_manager.save
    flash[:notice] = "Your Repository Manager status has been #{@repo_manager.active? ? 'activated' : 'deactivated'}"
    redirect_to root_path
  end

  private

  def find_repo_manager!
    RepoManager.find_by!(username: current_user.user_key)
  end
end
