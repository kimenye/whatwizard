class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  set_current_tenant_through_filter
  before_filter :find_tenant_by_params

  def find_tenant_by_params
    if params[:account].present? and params[:account].is_a?(String)
      account = Account.find_by(phone_number: params[:account])
      set_current_tenant(account)
    end
  end

  def get_random records
    records[rand(records.length)]
  end

  def personalize raw_text
    raw_text.gsub(/{{contact_name}}/, person.name)
  end	

  def remove_nil responses
    responses.reject! { |r| r.nil? }
    responses
  end
end
