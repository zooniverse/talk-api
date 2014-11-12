class ApplicationController < ActionController::Base
  def root
    render json: { }
  end
end
