class AddMenuToOptions < ActiveRecord::Migration
  def change
    add_reference :options, :menu, index: true
  end
end
