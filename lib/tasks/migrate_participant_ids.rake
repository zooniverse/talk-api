namespace :data do
  desc 'sets participant ids on conversations'
  task migrate_participant_ids: :environment do
    Conversation.find_each do |conversation|
      conversation.update_attribute 'participant_ids', conversation.user_ids
    end
  end
end
