class Board < ActiveRecord::Base
  include Searchable
  
  has_many :discussions, dependent: :restrict_with_error
  has_many :comments, through: :discussions
  has_many :users, through: :comments
  has_many :sub_boards, class_name: 'Board', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Board'
  
  validates :title, presence: true
  validates :description, presence: true
  validates :section, presence: true
  
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
    self.comments_count = comments.count
    self.users_count = users.select(:id).distinct.count
    save if changed?
  end
end
