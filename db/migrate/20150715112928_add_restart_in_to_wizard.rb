class AddRestartInToWizard < ActiveRecord::Migration
  def change
    add_column :wizards, :restart_in, :integer
  end
end
