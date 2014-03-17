RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
    # warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    config.excluded_models << Progress

    ## With an audit adapter, you can add:
    # history_index
    # history_show

    config.model 'Step' do
      edit do
        field :name
        field :step_type
        field :order_index
        field :next_step
        field :expected_answer        
        field :wrong_answer
        field :rebound
        field :allow_continue  
        field :action      
      end

      list do
        field :name
        field :step_type
        field :order_index
        field :next_step
        field :expected_answer
        field :wrong_answer
        field :allow_continue
        field :rebound
      end
    end

    config.model 'Question' do
      list do
        field :step
        field :text
        field :media
      end 

      edit do
        field :text
        field :step
        field :media
      end
    end

    config.model 'SystemResponse' do
      label 'Response' 

      list do
        field :step 
        field :response_type  
        field :text
        field :media
      end

      edit do 
        field :text
        field :response_type
        field :step
        field :media
      end
    end

    config.model 'Media' do
      list do
        field :name
        field :image
        field :uploaded
      end

      edit do
        field :name
        field :image
      end
    end

    member :upload_image do
      register_instance_option :link_icon do
        'icon-upload'
      end

      register_instance_option :visible? do
        bindings[:abstract_model].to_s == "Media"
      end      

      register_instance_option :http_methods do
          [:get, :post]
      end

      register_instance_option :controller do
        Proc.new do
          if params.has_key?(:submit)
            require 'httmultiparty'
            class ImageUploader
              include HTTMultiParty
              base_uri ENV['API_URL']  
            end
            
            response = Media.find_by_id(params[:id])          

            if !response.image.nil?
              result =  ImageUploader.post('/assets/', :query => { files: [File.new(response.image.path)]  }, :detect_mime_type => true,
                :headers => { "Accept" => "application/json"})

              response.remote_asset_id = result["id"]
              response.save!
            end

            redirect_to back_or_index, notice: "Image Uploaded"
          else
            render "upload_image"
          end
        end
      end

    end

    collection :reset_participants do
      register_instance_option :link_icon do
        'icon-envelope-alt'
      end

      register_instance_option :visible? do
        bindings[:abstract_model].to_s == "Contact"
      end

      register_instance_option :http_methods do
          [:get, :post]
      end

      register_instance_option :controller do
        Proc.new do
          if params.has_key?(:submit)
            # count = RenewalService.send_renewals
            # redirect_to back_or_index, notice: "#{count} Renewals sent"
            count = Contact.delete_all
            Progress.delete_all
            redirect_to back_or_index, notice: "#{count} Contacts reset"
          else
            render "reset_participants"
          end
        end
      end
    end
  end
end
