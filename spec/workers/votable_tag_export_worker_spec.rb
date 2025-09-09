require 'spec_helper'

RSpec.describe VotableTagExportWorker, type: :worker do
  describe 'a data export worker' do
    before(:each) do
      allow_any_instance_of(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter).to receive(:query)
    end

    it_behaves_like 'a data export worker'
  end

  def format_of(vote, created_by_user)
    {
      tag_id: vote.votable_tag.id,
      tag_name: vote.votable_tag.name,
      tag_section: vote.votable_tag.section,
      taggable_id: vote.votable_tag.taggable_id,
      taggable_type: vote.votable_tag.taggable_type,
      tag_vote_count: vote.votable_tag.vote_count,
      tag_deleted: vote.votable_tag.is_deleted,
      vote_id: vote.id,
      user_id: vote.user_id,
      voter_login: vote.user.login,
      tag_created_by_user_id: vote.votable_tag.created_by_user_id,
      tag_creator_login: created_by_user.login,
      vote_created_at: vote.created_at,
      tag_created_at: vote.votable_tag.created_at
    }
  end

  describe '#view_model' do
    before(:each) do
      subject.instance_variable_set :@view_name, 'project_1_votable_tags'
    end

    it 'should memoize the class' do
      expect(subject.view_model.object_id).to eql subject.view_model.object_id
    end

    it 'should set the view name' do
      expect(subject.view_model.table_name).to eql 'project_1_votable_tags'
    end

    it 'should set the primary key' do
      expect(subject.view_model.primary_key).to eql 'vote_id'
    end
  end

  describe '#create_view' do
    let(:user) { create :user }
    let(:data_request) { create :votable_tags_data_request }
    let!(:votable_tag) { create :votable_tag, section: data_request.section, created_by_user_id: user.id }
    let!(:tag_vote) { create :tag_vote, votable_tag_id: votable_tag.id }
    let(:data) { subject.view_model.all.collect(&:to_json) }
    before(:each) do
      subject.data_request = data_request
      subject.instance_variable_set :@view_name, 'project_1_votable_tags'
      subject.create_view
    end

    it 'generates the correct format' do
      expect(data).to match_array [
        format_of(tag_vote, user).to_json
      ]
    end
  end

  describe '#row_from' do
    it 'should call as_json' do
      row = double as_json: 'works'
      expect(subject.row_from(row)).to eql 'works'
    end
  end

  describe '#find_each' do
    let(:user) { create :user }
    let(:data_request) { create :votable_tags_data_request }
    let!(:votable_tag) { create :votable_tag, section: data_request.section, created_by_user_id: user.id }
    let!(:tag_vote) { create :tag_vote, votable_tag_id: votable_tag.id }

    before(:each) do
      subject.data_request = data_request
      subject.instance_variable_set :@view_name, "#{data_request.section.gsub('-', '_')}_votable_tags"
      subject.create_view
    end

    it 'should scope to the view model' do
      expect(subject).to receive(:view_model).at_least(:once).and_call_original
      subject.find_each {}
    end

    it 'should iterate the view model' do
      expect(subject.view_model).to receive(:find_each).and_call_original

      row = subject.view_model.new format_of(tag_vote, user)
      expect do |block|
        subject.find_each(&block)
      end.to yield_successive_args row
    end

    it 'should use the batch size' do
      expect(subject).to receive(:batch_size).and_return 123
      enumerator = double find_each: nil
      expect(subject).to receive(:view_model).and_return enumerator
      expect(enumerator).to receive(:find_each).with batch_size: 123
      subject.find_each {}
    end
  end

  describe '#perform' do
    let!(:data_request) { create :votable_tags_data_request }
    before(:each) do
      allow(subject).to receive :process_data
    end

    it 'should set the data request' do
      subject.perform data_request.id
      expect(subject.data_request).to eql data_request
    end

    it 'should set the view name' do
      subject.perform data_request.id
      view_name = subject.instance_variable_get :@view_name
      expect(view_name).to eql 'project_1_votable_tags'
    end

    it 'should create the view' do
      expect(subject).to receive :create_view
      subject.perform data_request.id
    end
  end

  describe '#row_count' do
    it 'should count section votable_tags' do
      expect(subject).to receive(:view_model).and_return double count: 5
      expect(subject.row_count).to eql 5
    end
  end
end
