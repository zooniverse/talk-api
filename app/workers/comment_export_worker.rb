class CommentExportWorker
  include Sidekiq::Worker
  attr_accessor :section, :name
  
  sidekiq_options retry: false, backtrace: true, congestion: {
    interval: 1.day,
    max_in_interval: 1,
    min_delay: 1.day,
    reject_with: :cancel
  }
  
  def perform(section)
    self.section = section
    self.name = "#{ section }-comments_#{ Time.now.utc.to_date.to_s }"
    data_file = write_data
    gzip_file = compress data_file
    ::File.unlink data_file
    # TO-DO:
    #   upload
    #   generate pre-signed key
    #   email link
    ::File.unlink gzip_file
  end
  
  def write_data
    ::File.open("#{ name }.json", 'w').tap do |file|
      file.write '['
      each_row do |row, index|
        file.write(',') unless index.zero?
        file.write row.to_json
      end
      file.write "]\n"
      file.close
    end
  end
  
  def each_row
    index = 0
    ::Board.where(section: section).find_each do |board|
      board.discussions.find_each do |discussion|
        discussion.comments.find_each do |comment|
          yield row_from(board, discussion, comment), index
          index += 1
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
  
  def compress(in_file)
    out_file = "/tmp/#{ name }.tar.gz"
    in_name = ::File.basename in_file.path
    in_path = ::File.dirname in_file.path
    `cd #{ in_path } && tar czf #{ out_file } #{ in_name }`
    ::File.new out_file
  end
end
