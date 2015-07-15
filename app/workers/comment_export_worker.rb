class CommentExportWorker
  include ::DataExportWorker
  self.name = 'comments'
  
  def find_each(&block)
    ::Board.where(section: section).find_each do |board|
      board.discussions.find_each do |discussion|
        discussion.comments.find_each do |comment|
          yield board, discussion, comment
        end
      end
    end
  end
  
  def row_from(board, discussion, comment)
    {
      board_id: board.id,
      board_title: board.title,
      board_description: board.description,
      discussion_id: discussion.id,
      discussion_title: discussion.title,
      comment_id: comment.id,
      comment_body: comment.body,
      comment_focus_id: comment.focus_id,
      comment_focus_type: comment.focus_type,
      comment_user_id: comment.user_id,
      comment_user_login: comment.user_login,
      comment_created_at: comment.created_at
    }
  end
end
