class AddNameEmailToHelpRequest < ActiveRecord::Migration
  def change
      add_column :help_requests, :name, :string
      add_column :help_requests, :email, :string
  end
end
