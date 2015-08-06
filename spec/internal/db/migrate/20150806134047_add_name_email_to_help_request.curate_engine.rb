# This migration comes from curate_engine (originally 20140926133617)
class AddNameEmailToHelpRequest < ActiveRecord::Migration
  def change
      add_column :help_requests, :name, :string
      add_column :help_requests, :email, :string
  end
end
