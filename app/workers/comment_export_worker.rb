class CommentExportWorker
  include ::DataExportWorker

  def perform(data_request_id)
    self.data_request = ::DataRequest.find data_request_id
    @view_name = "#{ data_request.section.gsub /\-/, '_' }_comments"
    create_view
    super
  end

  def find_each(&block)
    view_model.find_each batch_size: batch_size, &block
  end

  def row_count
    view_model.count
  end

  def row_from(row)
    row.as_json
  end

  def create_view
    view_model.connection.query <<-SQL
      create or replace view #{ @view_name } as
      select
        boards.id as board_id,
        boards.title as board_title,
        boards.description as board_description,
        discussions.id as discussion_id,
        discussions.title as discussion_title,
        comments.id as comment_id,
        comments.body as comment_body,
        comments.focus_id as comment_focus_id,
        comments.focus_type as comment_focus_type,
        comments.user_id as comment_user_id,
        comments.user_login as comment_user_login,
        comments.created_at as comment_created_at
      from boards
      left join discussions on discussions.board_id = boards.id
      left join comments on comments.discussion_id = discussions.id
      where boards.section = '#{ data_request.section }' and discussions.id is not null;
    SQL
  end

  def view_model
    return @_view_model if @_view_model
    view_model_name = @view_name
    @_view_model = Class.new ::ActiveRecord::Base do
      self.table_name = view_model_name
      self.primary_key = :comment_id
    end
  end
end
