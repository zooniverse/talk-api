FactoryGirl.define do
  factory :discussion do
    title 'A discussion'
    section 'test'
    board
    user
    
    factory :discussion_with_comments do
      transient do
        comment_count 2
        user_count 2
      end
      
      after :create do |discussion, evaluator|
        commenting_users = create_list :user, evaluator.user_count
        evaluator.comment_count.times do |i|
          create :comment, discussion: discussion, user: commenting_users[i % evaluator.user_count]
        end
      end
    end
  end
end
