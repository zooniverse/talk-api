# frozen_string_literal: true

class TagVoteSerializer
  include TalkSerializer

  all_attributes
  attributes :votable_tag
  can_filter_by :project_id, :taggable_id, :taggable_type, :section

  def self.page(params = {}, scope = nil, context = {})
    page_with_options CustomScopeFilterOptions.new(self, params, scope, context)
  end

  def votable_tag
    VotableTagSerializer.as_json(model.votable_tag, current_user: current_user)
  end

  class CustomScopeFilterOptions < RestPack::Serializer::Options
    CUSTOM_SCOPE_FILTERS = %i[section project_id taggable_type taggable_id section].freeze

    def scope_with_filters
      non_custom_filters = @filters.except(*CUSTOM_SCOPE_FILTERS)
      custom_filters = @filters.except(:user_id, :votable_tag_id)
      return @scope.where(non_custom_filters) if custom_filters.empty?

      @scope.joins(:votable_tag).where(non_custom_filters).where(votable_tag: custom_filters)
    end
  end
end
