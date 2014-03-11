RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
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
      end

      list do
        field :name
        field :step_type
        field :next_step
        field :expected_answer
      end
    end

    config.model 'Question' do
      list do
        field :step
        field :text
      end 
    end

    config.model 'SystemResponse' do
      label 'Response'  

      edit do 
        field :text
        field :response_type
        field :step
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
