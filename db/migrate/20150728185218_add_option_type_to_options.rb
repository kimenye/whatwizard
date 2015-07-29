class AddOptionTypeToOptions < ActiveRecord::Migration
  def change
    add_column :options, :option_type, :string, default: 'key'
  end
end
