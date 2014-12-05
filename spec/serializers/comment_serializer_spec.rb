require 'spec_helper'

RSpec.describe CommentSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:focus]
  
  it 'should specify the focus type in links' do
    subject = create :subject
    comment = create :comment_for_focus, focus: subject
    json = CommentSerializer.resource id: comment.id
    comment_json = json[:comments].first
    expect(comment_json[:links]).to eql focus: subject.id.to_s, focus_type: 'Subject'
  end
end
