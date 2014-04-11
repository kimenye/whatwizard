class AddPlayerToProgress < ActiveRecord::Migration
  def change
    add_reference :progresses, :player, index: true
  end
end
