module ModerationActions
  extend ActiveSupport::Concern

  def custom_attributes
    moderation = Moderation.new target: model
    moderation.section = model.section if model.respond_to?(:section)
    policy = ModerationPolicy.new current_user, moderation
    super.merge moderatable_actions: policy.available_actions
  end
end
