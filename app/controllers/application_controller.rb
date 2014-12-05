class ApplicationController < ActionController::Base
  include Pundit
  
  def root
    render json: { }
  end
end
