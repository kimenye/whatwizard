class SystemResponse < ActiveRecord::Base
  
  belongs_to :step
  has_attached_file :image, :styles => { :medium => "480x480>", :thumb => "48x48>" }

  def response_type_enum
    [ ['Valid','valid'], ['Invalid', 'invalid'], ['More Than', 'more_than'], ['Less Than', 'less_than'], ['Equal', 'equal']]
  end

  after_commit :upload_to_whatsapp
  after_commit :upload_to_whatsapp

  private
    def upload_to_whatsapp
      # has the image changed
      
      if !image.nil?
        result =  ImageUploader.post('/assets/', :query => { files: [File.new(image.path)]  }, :detect_mime_type => true)
        puts "result #{result}"
      end
    end
end
