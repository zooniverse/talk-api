class TagsController < ApplicationController
  include TalkResource
  
  def popular
    params.permit!
    raise ActionController::ParameterMissing.new(:section) unless params[:section]
    limit = clamp params.fetch(:limit, 10).to_i, (1..20)
    scoped = Tag.in_section params[:section]
    scoped = scoped.of_type(params[:type]) if params[:type]
    render json: {
      tags: scoped.popular(limit: limit).keys
    }
  end
  
  protected
  
  def clamp(value, range)
    value = [value, range.min].max
    value = [value, range.max].min
    value
  end
end
