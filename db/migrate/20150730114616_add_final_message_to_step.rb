class AddFinalMessageToStep < ActiveRecord::Migration
  def change
    add_column :steps, :final_message, :text
  end
end
