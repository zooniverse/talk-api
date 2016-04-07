require 'spec_helper'

RSpec.describe CommentsController, type: :controller do
  let(:resource){ Comment }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error },
    upvote: { status: 401, response: :error },
    remove_upvote: { status: 401, response: :error }

  describe '#index' do
    context 'filtering by subject_default' do
      let!(:subject_default_board){ create :board, section: 'project-1', subject_default: true }
      let!(:subject_default_discussion){ create :discussion, board: subject_default_board }
      let!(:subject_default_comment){ create :comment, discussion: subject_default_discussion }
      let!(:comments){ create_list :comment, 2, section: 'project-1' }
      let!(:comment_ids){ comments.map(&:id).map &:to_s }
      let!(:board_ids){ comments.map(&:board_id).map &:to_s }

      let(:response_ids){ response.json['comments'].map{ |comment| comment['id'] } }
      let(:first_href){ response.json['meta']['comments']['first_href'] }
      let(:href_params){ CGI.parse URI.parse(first_href).query }

      context 'when false' do
        before(:each){ get :index, format: :json, section: 'project-1', subject_default: false }

        it 'should filter comments from subject default boards' do
          expect(response_ids).to match_array comment_ids
        end

        it 'should modify the link hrefs' do
          expect(href_params['sort']).to eql ['created_at']
          expect(href_params['board_id'].first.split(',')).to match_array board_ids
          expect(href_params['section']).to eql ['project-1']
        end
      end

      context 'when true' do
        before(:each){ get :index, format: :json, section: 'project-1', subject_default: true }

        it 'should filter comments from subject default boards' do
          expect(response_ids).to match_array [subject_default_comment.id.to_s]
        end

        it 'should modify the link hrefs' do
          expect(href_params['sort']).to eql ['created_at']
          expect(href_params['board_id']).to eql [subject_default_board.id.to_s]
          expect(href_params['section']).to eql ['project-1']
        end
      end
    end
  end

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error },
      upvote: { status: 401, response: :error },
      remove_upvote: { status: 401, response: :error }
  end

  context 'with an authorized user' do
    let(:record){ create :comment }
    let(:user){ record.user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :destroy
    it_behaves_like 'a controller restricting',
      upvote: { status: 401, response: :error },
      remove_upvote: { status: 401, response: :error }

    it_behaves_like 'a controller creating' do
      let(:request_params) do
        {
          comments: {
            body: 'works',
            discussion_id: create(:discussion).id.to_s
          }
        }
      end

      it 'should set the user ip' do
        post :create, request_params.merge(format: :json)
        id = response.json['comments'].first['id']
        comment = Comment.find id
        expect(comment.user_ip).to eql request.remote_ip
      end
    end

    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id.to_s,
          comments: {
            body: 'changed'
          }
        }
      end
    end
  end

  context 'with a non-author user' do
    let(:record){ create :comment }
    let(:user){ create :user }
    let(:send_request){ put upvote_method, id: record.id.to_s, format: :json }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller restricting',
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }

    shared_examples_for 'a CommentsController upvoting' do
      it 'should find the resource' do
        expect_any_instance_of(subject.service_class).to receive :find_resource
        send_request
      end

      it 'should authorize the action' do
        expect_any_instance_of(subject.service_class).to receive :authorize
        send_request
      end

      it 'should serialize the resource' do
        expect(subject.serializer_class).to receive(:resource).and_call_original
        send_request
      end

      context 'with a response' do
        before(:each){ send_request }

        it 'should set the correct status' do
          expect(response.status).to eql 200
        end

        it 'should be json' do
          expect(response.content_type).to eql 'application/json'
        end

        it 'should be an object' do
          expect(response.json).to be_a Hash
        end
      end
    end

    describe '#upvote' do
      let(:upvote_method){ :upvote }

      it_behaves_like 'a CommentsController upvoting' do
        it 'should update the record' do
          expect{
            send_request
          }.to change{
            record.reload.upvotes
          }.from({

          }).to user.login => kind_of(String)
        end
      end
    end

    describe '#remove_upvote' do
      let(:record){ create :comment, upvotes: { user.login => Time.now.to_i } }
      let(:upvote_method){ :remove_upvote }

      it_behaves_like 'a CommentsController upvoting' do
        it 'should update the record' do
          expect{
            send_request
          }.to change{
            record.reload.upvotes
          }.from({
            user.login => kind_of(String)
          }).to({ })
        end
      end
    end
  end
end
