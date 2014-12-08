require 'spec_helper'

RSpec.shared_examples_for 'a created message' do
  it 'should create a message' do
    expect(message).to be_a Message
  end
  
  it 'should assign the user' do
    expect(message.user).to eql user
  end
  
  it 'should assign the conversation' do
    expect(message.conversation).to eql conversation
  end
  
  it 'should assign the body' do
    expect(message.body).to eql 'A message'
  end
end
