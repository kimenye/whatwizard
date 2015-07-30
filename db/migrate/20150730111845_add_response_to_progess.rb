class AddResponseToProgess < ActiveRecord::Migration
  def change
    add_column :progresses, :response, :text
  end
end
