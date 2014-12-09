class ApplicationController < ActionController::Base
  include Pundit
  include ActionRendering
  include ActionRescuing
  
  def root
    authorize :application, :index?
    render json: { }
  end
  
  def sinkhole
    raise ActionController::RoutingError.new 'Not found'
  end
  
  concerning :CurrentUser do
    attr_accessor :current_user # TO-DO: proxy login
  end
end
