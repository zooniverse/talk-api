class SearchesController < ApplicationController
  before_action :permit_params
  rescue_from InvalidSearchTypeError, with: :unprocessable
  after_action :log_search, only: [:index]

  def index
    render json: {
      searches: paginated_search.serialize_search,
      meta: {
        searches: search_meta
      }
    }
  end

  protected

  def paginated_search
    @paginated_search ||= search.page(params[:page]).per params[:page_size]
  end

  def search
    @search ||= Search.of_type(models).in_section(section).with_content query
  end

  def search_meta
    {
      page: paginated_search.current_page,
      page_size: paginated_search.limit_value,
      count: search.count,
      include: [],
      page_count: paginated_search.total_pages,
      previous_page: paginated_search.prev_page,
      next_page: paginated_search.next_page,
      first_href: search_href(page: 1),
      previous_href: previous_href,
      next_href: next_href,
      last_href: search_href(page: paginated_search.total_pages)
    }
  end

  def next_href
    return unless paginated_search.next_page
    search_href page: paginated_search.next_page
  end

  def previous_href
    return unless paginated_search.prev_page
    search_href page: paginated_search.prev_page
  end

  def search_href(opts = { })
    permitted = params.slice :page, :page_size, :section, :query, :types
    query_opts = permitted.merge(opts).collect{ |k, v| "#{ k }=#{ v }" }.join '&'
    "/searches?#{ query_opts }"
  end

  def models
    types = params.fetch(:types, %w(boards collections comments discussions))
    types = types.split(',') if types.is_a?(String)
    types.collect(&:classify).collect(&:constantize).collect &:name
  rescue NameError => e
    raise InvalidSearchTypeError.new e.message
  end

  def section
    required_param :section
  end

  def query
    required_param :query
  end

  def required_param(name)
    raise ActionController::ParameterMissing.new(name) unless params[name]
    params[name]
  end

  def permit_params
    params.permit :page, :page_size, :section, :query, types: []
  end

  def log_search
    log_event! 'search', params.except(:controller, :action, :format)
  end
end
