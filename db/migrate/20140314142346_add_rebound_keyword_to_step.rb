class AddReboundKeywordToStep < ActiveRecord::Migration
  def change
    add_column :steps, :rebound, :text
  end
end
