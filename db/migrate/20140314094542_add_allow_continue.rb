class AddAllowContinue < ActiveRecord::Migration
  def change
  	add_column :steps, :allow_continue, :boolean
  end
end
