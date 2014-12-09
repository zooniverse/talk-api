class ApplicationController < ActionController::Base
  include Pundit
  include ActionRescuing
  
  def root
    authorize :application, :index?
    render json: { }
  end
  
  def sinkhole
    raise ActionController::RoutingError.new 'Not found'
  end
end
