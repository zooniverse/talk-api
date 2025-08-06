# frozen_string_literal: true

class VotableTagExportWorker
  include ::DataExportWorker

  def perform(data_request_id)
    self.data_request = ::DataRequest.find data_request_id
    @view_name = "#{data_request.section.gsub(/-/, '_')}_votable_tags"
    create_view
    super
  end

  def find_each(&block)
    view_model.find_each batch_size:, &block
  end

  def row_count
    view_model.count
  end

  def row_from(row)
    row.as_json
  end

  def create_view
    view_model.connection.query <<-SQL
      select
        votable_tags.id as tag_id,
        votable_tags.name as tag_name,
        votable_tags.section as tag_section,
        votable_tags.taggable_id,
        votable_tags.taggable_type,
        votable_tags.vote_count as tag_vote_count,
        votable_tags.is_deleted as tag_deleted,
        tag_votes.id as vote_id,
        tag_votes.user_id,
        users.login as voter_login,
        votable_tags.created_by_user_id as tag_created_by_user_id,
        tag_creator.login as tag_creator_login,
        tag_votes.created_at as vote_created_at,
        votable_tags.created_at as tag_created_at
      from tag_votes
      join votable_tags on tag_votes.votable_tag_id = votable_tags.id
      join users on tag_votes.user_id = users.id
      join users as tag_creator on votable_tags.created_by_user_id = tag_creator.id
      where votable_tags.section = '#{data_request.section}';
    SQL
  end

  def view_model
    return @_view_model if @_view_model

    view_model_name = @view_name
    @_view_model = Class.new ::ActiveRecord::Base do
      self.table_name = view_model_name
      self.primary_key = :vote_id
    end
  end
end
