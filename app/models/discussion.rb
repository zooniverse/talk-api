class Discussion < ActiveRecord::Base
  include Moderatable
  include Searchable
  include Subscribable
  
  belongs_to :user, required: true
  belongs_to :board, required: true, counter_cache: true
  has_many :comments, dependent: :destroy
  
  validates :title, presence: true, length: { in: 3..140, unless: ->{ subject_default? } }
  validates :section, presence: true
  
  before_validation :set_section
  before_create :denormalize_attributes
  before_save :clear_sticky, unless: ->{ sticky? }
  after_update :update_board_counters
  
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
    self.users_count = comments.reload.select(:user_id).distinct.count
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
    changes.fetch(:board_id, []).compact.each do |id|
      Board.find_by_id(id).try :count_users_and_comments!
    end
  end
  
  def clear_sticky
    self.sticky_position = nil
  end
end
