class SubscriptionUniquenessValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:base, message_for(record)) if exists?(record)
  end
  
  def exists?(record)
    Subscription.where({
      user_id: record.user_id,
      source_id: record.source_id,
      source_type: record.source_type,
      category: category_of(record)
    }).exists?
  end
  
  def category_of(record)
    Subscription.categories.fetch record.category, record.category
  end
  
  def message_for(record)
    message = "You are already following that #{ record.source_type }"
  end
end
