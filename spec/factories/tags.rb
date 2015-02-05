FactoryGirl.define do
  factory :tag do
    name{ "tag#{ id }" }
    section 'test'
    user
    association :comment, factory: :comment, strategy: :build
    
    association :taggable, factory: :subject
    
    transient do
      taggable_section 'test'
    end
    
    before :create do |tag, evaluator|
      board = create :board, section: evaluator.taggable_section
      discussion = create :discussion, board: board
      tag.comment = create :comment, discussion: discussion, focus: tag.taggable
    end
  end
end
