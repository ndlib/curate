class AddIndexesToRepoManagers < ActiveRecord::Migration
  def change
    add_index :repo_managers, :active
    add_index :repo_managers, [:username, :active]
  end
end
