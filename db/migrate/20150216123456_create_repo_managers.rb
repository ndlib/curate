class CreateRepoManagers < ActiveRecord::Migration
  def change
    create_table :repo_managers do |t|
      t.string :username
      t.boolean :active
      t.timestamps
    end

    add_index :repo_managers, :username
  end

  def self.down
    drop_table :repo_managers
  end
end
