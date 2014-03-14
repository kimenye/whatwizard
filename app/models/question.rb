class Question < ActiveRecord::Base
  belongs_to :step
  belongs_to :media
  has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

  def uploaded
  	!remote_asset_id.nil?
  end
end
