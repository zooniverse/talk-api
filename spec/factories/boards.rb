FactoryGirl.define do
  factory :board do
    title 'A board'
    description 'Some board'
    section 'test'
    
    factory :board_with_discussions do
      transient do
        discussion_count 2
      end
      
      after :create do |board, evaluator|
        create_list :discussion, evaluator.discussion_count, board: board
      end
    end
    
    factory :board_with_subboards do
      transient do
        subboard_count 2
      end
      
      after :create do |board, evaluator|
        create_list :board, evaluator.subboard_count, board: board
      end
    end
  end
end
