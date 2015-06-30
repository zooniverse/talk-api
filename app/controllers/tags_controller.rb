class TagsController < ApplicationController
  include TalkResource
  
  def popular
    params.permit!
    raise ActionController::ParameterMissing.new(:section) unless params[:section]
    limit = clamp params.fetch(:limit, 10).to_i, (1..20)
    scoped = Tag.in_section params[:section]
    scoped = scoped.of_type(params[:type]) if params[:type]
    scoped = scoped.popular limit: limit
    render json: {
      tags: tags_from(scoped.keys),
      meta: popular_meta_for(scoped.count, limit)
    }
  end
  
  protected
  
  def popular_meta_for(count, limit)
    {
      tags: {
        page: 1,
        page_size: limit,
        count: count,
        include: [],
        page_count: 1,
        previous_page: nil,
        next_page: nil,
        first_href: '/tags/popular',
        previous_href: nil,
        next_href: nil,
        last_href: '/tags/popular'
      }
    }
  end
  
  def tags_from(names)
    names.collect{ |name| Tag.new(name: name, section: params[:section], taggable_type: params[:type]) }
  end
  
  def clamp(value, range)
    value = [value, range.min].max
    value = [value, range.max].min
    value
  end
end
