class Discussion < ActiveRecord::Base
  include Moderatable
  include Searchable
  include Subscribable
  include Sectioned
  include Notifiable
  include BooleanCoercion

  include Discussion::Subscribing

  belongs_to :user, required: true
  belongs_to :board, required: true, counter_cache: true
  belongs_to :focus, polymorphic: true
  has_many :comments, dependent: :destroy
  has_one :latest_comment, ->{
    includes(CommentSerializer.includes)
      .select('distinct on(comments.discussion_id) comments.*')
      .reorder discussion_id: :asc, created_at: :desc
  }, class_name: 'Comment'

  validates :title, presence: true, length: { in: 3..140, unless: ->{ subject_default? } }
  validates :section, presence: true

  before_validation :set_section
  before_create :denormalize_attributes
  before_save :clear_sticky, unless: ->{ sticky? }
  before_save :set_sticky_position, if: ->{ sticky? && sticky_position.nil? }
  after_update :update_board_counters, if: ->{ board_id_changed? }

  moderatable_with :destroy, by: [:moderator, :admin]
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  moderatable_with :watch, by: [:moderator, :admin]

  def searchable?
    return @searchable if @searchable
    @searchable = board.searchable?
  end

  def searchable_update
    <<-SQL
      update searchable_discussions
      set content =
        setweight(to_tsvector(discussions.title), 'A')
      from discussions
      where searchable_discussions.searchable_id = #{ id } and
      discussions.id = #{ id }
    SQL
  end

  def count_users!
    self.users_count = Comment.where(discussion_id: id).select(:user_id).distinct.count
    save if changed?
  end

  def update_counters!
    count_users!
    board.count_users_and_comments!
  end

  protected

  def set_section
    self.section = board.section
  end

  def denormalize_attributes
    self.user_login = user.login
  end

  def update_board_counters
    comments.update_all board_id: board_id
    changes.fetch(:board_id, []).compact.each do |id|
      Board.find_by_id(id).try :count_users_and_comments!
    end
  end

  def clear_sticky
    self.sticky_position = nil
  end

  def set_sticky_position
    last_sticky = board.discussions.where(sticky: true).order(sticky_position: :desc).first
    self.sticky_position = (last_sticky.try(:sticky_position) || 0) + 1
  end
end
