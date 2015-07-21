require 'spec_helper'

RSpec.describe DataRequest, type: :model do
  it_behaves_like 'a subscribable model'
  
  context 'validating' do
    it 'should require a user' do
      without_user = build :data_request, user: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
    
    it 'should require a section' do
      without_section = build :data_request, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
    
    it 'should require a kind' do
      without_kind = build :data_request, kind: nil
      expect(without_kind).to fail_validation kind: "can't be blank"
    end
    
    it 'should require a kind to be valid' do
      invalid_kind = build :data_request, kind: 'foo'
      expect(invalid_kind).to fail_validation kind: 'must be "tags" or "comments"'
    end
    
    it 'should be unique to a section and kind' do
      existing = create :data_request
      duplicate = build :data_request
      expect(duplicate).to fail_validation kind: 'has already been created'
    end
  end
  
  describe '.kinds' do
    subject{ DataRequest.kinds }
    it{ is_expected.to eql tags: TagExportWorker, comments: CommentExportWorker }
  end
  
  describe '#worker' do
    it 'should find CommentExportWorker' do
      data_request = create :comments_data_request
      expect(data_request.worker).to eql CommentExportWorker
    end
    
    it 'should find TagExportWorker' do
      data_request = create :tags_data_request
      expect(data_request.worker).to eql TagExportWorker
    end
  end
  
  describe '#set_expiration' do
    it 'should set expires_at' do
      data_request = create :tags_data_request
      expect(data_request.expires_at).to be_within(1.second).of 1.day.from_now.utc
    end
  end
  
  describe '#spawn_worker' do
    it 'should run the worker' do
      data_request = create :tags_data_request
      expect(TagExportWorker).to receive(:perform_async).with data_request.id
      data_request.run_callbacks :commit
    end
  end
end
