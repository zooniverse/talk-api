class SubscriptionUniquenessValidator < ActiveModel::Validator
  def validate(record)
    query = case record.category
    when 'participating_discussions'
      for_source_and_user(record).and with_category(:followed_discussions).or with_category(record.category)
    when 'followed_discussions'
      for_source_and_user(record).and with_category(:participating_discussions).or with_category(record.category)
    else
      for_source_and_user(record).and with_category record.category
    end
    
    record.errors.add(:base, message_for(record)) if Subscription.where(query).exists?
  end
  
  def for_source_and_user(record)
    subscriptions[:user_id].eq(record.user_id)
      .and(subscriptions[:source_id].eq(record.source_id))
      .and subscriptions[:source_type].eq(record.source_type)
  end
  
  def message_for(record)
    message = "You are already following that #{ record.source_type }"
  end
  
  def with_category(category)
    subscriptions[:category].eq Subscription.categories[category]
  end
  
  def subscriptions
    @subscriptions ||= Subscription.arel_table
  end
end
