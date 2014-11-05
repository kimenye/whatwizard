class AddResponseTypeToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :response_type, :string
  end
end
