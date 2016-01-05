# This migration comes from curate_engine (originally 20160105151133)
class AddIndexesToRepoManagers < ActiveRecord::Migration
  def change
    add_index :repo_managers, :active
    add_index :repo_managers, [:username, :active]
  end
end
