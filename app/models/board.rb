class Board < ActiveRecord::Base
  include Searchable
  include Sectioned
  include BooleanCoercion
  
  has_many :discussions, dependent: :restrict_with_error
  has_one :latest_discussion, ->{
    includes(DiscussionSerializer.includes)
      .select('distinct on(discussions.board_id) discussions.*')
      .reorder board_id: :asc, last_comment_created_at: :desc
  }, class_name: 'Discussion'
  has_many :comments
  has_many :sub_boards, class_name: 'Board', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Board'
  
  validates :title, presence: true
  validates :description, presence: true
  validates :section, presence: true
  
  after_update :cascade_searchable, if: :permissions_changed?
  
  def searchable?
    permissions['read'] == 'all'
  end
  
  def searchable_update
    <<-SQL
      update searchable_boards
      set content =
        setweight(to_tsvector(boards.title), 'A') ||
        setweight(to_tsvector(boards.description), 'A')
      from boards
      where searchable_boards.searchable_id = #{ id } and
      boards.id = #{ id }
    SQL
  end
  
  def count_users_and_comments!
    self.comments_count = Comment.where(board_id: id).count
    self.users_count = Comment.where(board_id: id).select(:user_id).distinct.count
    save if changed?
  end
  
  # This should be moved into a background worker
  def cascade_searchable
    # was public, but isn't now
    if permissions_was['read'] == 'all' && permissions['read'] != 'all'
      each_discussion_and_comment &:destroy_searchable
    # wasn't public, but is now
    elsif permissions_was['read'] != 'all' && permissions['read'] == 'all'
      each_discussion_and_comment &:update_searchable
    end
  end
  
  protected
  
  def each_discussion_and_comment
    discussions.find_each do |discussion|
      yield discussion
      discussion.comments.find_each do |comment|
        yield comment
      end
    end
  end
end
