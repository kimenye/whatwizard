class AddValueToSystemResponses < ActiveRecord::Migration
  def change
    add_column :system_responses, :value, :string
  end
end
