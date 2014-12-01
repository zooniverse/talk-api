shared_examples 'a created message' do
  it 'should create a message' do
    expect(message).to be_a Message
  end
  
  it 'should assign the sender' do
    expect(message.sender).to eql sender
  end
  
  it 'should assign the recipient' do
    expect(message.recipient).to eql recipient
  end
  
  it 'should assign the conversation' do
    expect(message.conversation).to eql conversation
  end
  
  it 'should assign the body' do
    expect(message.body).to eql 'A message'
  end
end
