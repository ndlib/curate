class RepoManagersController < ApplicationController
  with_themed_layout '1_column'

  def edit
    @repo_manager = RepoManager.where(username: current_user.user_key).first
  end

  def update
    puts "Repo Params: #{params.inspect}"
    @repo_manager = RepoManager.find(params[:id])
    @repo_manager.active = params[:repo_manager][:active]
    @repo_manager.save
    redirect_to root_path
  end
end
