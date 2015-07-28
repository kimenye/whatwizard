class VotingController < ApplicationController
  skip_before_action :verify_authenticity_token 
  before_action :set_contact, only: [:wizard]

  def wizard
    if is_text?
      text = params[:text]

      wizard = Wizard.where('start_keyword like ?', text.upcase).first
      if wizard.nil?
        render json: { ignore: true }
      else
        render json: { success: true }
      end
    else
      render json: { success: true }
    end
  end

end