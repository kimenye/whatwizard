class AddImageToMedia < ActiveRecord::Migration
  def change
  	add_attachment :media, :image
  	add_column :media, :remote_asset_id, :integer
  	add_column :questions, :media_id, :integer
  	add_index :questions, :media_id
   	add_column :system_responses, :media_id, :integer
  	add_index :system_responses, :media_id
  end
end
