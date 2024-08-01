require 'spec_helper'

RSpec.describe CommentExportWorker, type: :worker do
  it_behaves_like 'a data export worker'

  def format_of(comment)
    {
      board_id: comment.discussion.board.id,
      board_title: comment.discussion.board.title,
      board_description: comment.discussion.board.description,
      discussion_id: comment.discussion.id,
      discussion_title: comment.discussion.title,
      comment_id: comment.id,
      comment_body: comment.body,
      comment_focus_id: comment.focus_id,
      comment_focus_type: comment.focus_type,
      comment_user_id: comment.user_id,
      comment_user_login: comment.user_login,
      comment_created_at: comment.created_at
    }
  end

  describe '#view_model' do
    before(:each) do
      subject.instance_variable_set :@view_name, 'project_1_comments'
    end

    it 'should memoize the class' do
      expect(subject.view_model.object_id).to eql subject.view_model.object_id
    end

    it 'should set the table name' do
      expect(subject.view_model.table_name).to eql 'project_1_comments'
    end

    it 'should set the primary key' do
      expect(subject.view_model.primary_key).to eql 'comment_id'
    end
  end

  describe '#create_view' do
    let(:data_request){ create :comments_data_request }
    let!(:comment1){ create :comment, section: data_request.section }
    let!(:comment2){ create :comment, section: data_request.section }
    let!(:board_without_discussion) { create :board, section: data_request.section }
    let(:data){ subject.view_model.all.collect(&:to_json) }
    before(:each) do
      subject.data_request = data_request
      subject.instance_variable_set :@view_name, 'project_1_comments'
      subject.create_view
    end

    it 'generate the correct format' do
      expect(data).to match_array [
        format_of(comment1).to_json,
        format_of(comment2).to_json
      ]
    end

    it 'should not include empty boards' do
      data_board_ids = subject.view_model.all.pluck(:board_id)
      expect(data_board_ids).not_to include(board_without_discussion.id)
    end
  end

  describe '#row_from' do
    it 'should call as_json' do
      row = double as_json: 'works'
      expect(subject.row_from(row)).to eql 'works'
    end
  end

  describe '#find_each' do
    let(:data_request){ create :comments_data_request }
    let!(:comment){ create :comment, section: data_request.section }

    before(:each) do
      subject.data_request = data_request
      subject.instance_variable_set :@view_name, "#{ data_request.section.gsub('-', '_') }_comments"
      subject.create_view
    end

    it 'should scope to the view model' do
      expect(subject).to receive(:view_model).at_least(:once).and_call_original
      subject.find_each{ }
    end

    it 'should iterate the view model' do
      expect(subject.view_model).to receive(:find_each).and_call_original

      row = subject.view_model.new format_of comment
      expect do |block|
        subject.find_each &block
      end.to yield_successive_args row
    end

    it 'should use the batch size' do
      expect(subject).to receive(:batch_size).and_return 123
      enumerator = double find_each: nil
      expect(subject).to receive(:view_model).and_return enumerator
      expect(enumerator).to receive(:find_each).with batch_size: 123
      subject.find_each{ }
    end
  end

  describe '#perform' do
    let(:data_request){ create :comments_data_request }
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
      expect(view_name).to eql 'project_1_comments'
    end

    it 'should create the view' do
      expect(subject).to receive :create_view
      subject.perform data_request.id
    end
  end

  describe '#row_count' do
    it 'should count section comments' do
      expect(subject).to receive(:view_model).and_return double count: 5
      expect(subject.row_count).to eql 5
    end
  end
end
