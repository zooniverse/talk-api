class MessageSerializer
  include TalkSerializer
  all_attributes
  attributes :sender, :recipient
  can_include :conversation
  
  def sender
    UserSerializer.as_json model.sender
  end
  
  def recipient
    UserSerializer.as_json model.recipient
  end
end
