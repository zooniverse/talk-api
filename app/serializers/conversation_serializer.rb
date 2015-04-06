class ConversationSerializer
  include TalkSerializer
  include ModerationActions
  
  all_attributes
  can_include :messages
  can_sort_by :updated_at
  self.default_sort = 'updated_at'
  
  def custom_attributes
    super.tap do |attrs|
      # All users able to view a conversation are able to report it
      attrs[:moderatable_actions] << :report
    end
  end
end
