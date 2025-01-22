namespace :data do
  desc 'sets focuses on discussions'
  task migrate_discussion_focuses: :environment do
    Discussion.where('focus_type' => nil).joins(:comments).where('comments.focus_type' => 'Subject').find_each do |discussion|
      first_comment = discussion.comments.order(created_at: :asc).first
      if first_comment.focus
        discussion.update focus_id: first_comment.focus_id, focus_type: first_comment.focus_type
      end
    end
  end
end
