class BoardVisibilityWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: true, backtrace: true
  
  def perform(board_id, action)
    board = ::Board.find board_id
    board.each_discussion_and_comment &action.to_sym
  end
end
