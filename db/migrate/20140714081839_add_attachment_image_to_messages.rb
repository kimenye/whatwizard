class AddAttachmentImageToMessages < ActiveRecord::Migration
  def self.up
    change_table :messages do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :messages, :image
  end
end
