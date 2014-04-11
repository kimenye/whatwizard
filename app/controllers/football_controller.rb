class FootballController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_player, only: [:wizard]
  
  def wizard
    if params.has_key?(:text)
    end
  end


  def set_player
    @player = Player.find_by_phone_number(params[:phone_number])
    if @player.nil?
      @player = Player.create! phone_number: params[:phone_number], name: params[:name], subscribed: nil
    end
    @player
  end
end
