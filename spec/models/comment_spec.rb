require 'spec_helper'

RSpec.describe Comment, type: :model do
  it_behaves_like 'a notifiable model'
  it_behaves_like 'a sectioned model'
  it_behaves_like 'moderatable'
  it_behaves_like 'a searchable interface'
  it_behaves_like 'a searchable model' do
    let(:searchable_board){ create :board }
    let(:searchable_discussion){ create :discussion, board: searchable_board }
    let(:searchable){ create :comment, discussion: searchable_discussion }

    let(:unsearchable_board){ create :board, permissions: { read: 'admin' } }
    let(:unsearchable_discussion){ create :discussion, board: unsearchable_board }
    let(:unsearchable){ create :comment, discussion: unsearchable_discussion }
  end

  context 'validating' do
    it 'should require a body' do
      without_body = build :comment, body: nil
      expect(without_body).to fail_validation body: "can't be blank"
    end

    it 'should require a user' do
      without_user = build :comment, user_id: nil
      expect(without_user).to fail_validation
    end

    it 'should require a section' do
      without_section = build :comment, section: nil
      allow(without_section).to receive :set_section
      expect(without_section).to fail_validation section: "can't be blank"
    end

    context 'requiring a focus_type' do
      context 'when focus_id is blank' do
        it 'should permit a blank focus_type' do
          without_focus_type = build :comment, focus_id: nil, focus_type: nil
          expect(without_focus_type).to be_valid
        end
      end

      context 'when focus_id is present' do
        it 'should not permit a blank focus_type' do
          without_focus_type = build :comment, focus_id: create(:subject).id, focus_type: nil
          expect(without_focus_type).to fail_validation focus_type: 'must be "Subject"'
        end
      end
    end
  end

  context 'creating' do
    it 'should set default attributes' do
      comment = create :comment
      expect(comment.tagging).to eql({ })
      expect(comment.is_deleted).to be false
    end

    it 'should set the section' do
      comment = build :comment, section: nil
      expect{
        comment.validate
      }.to change{
        comment.section
      }.to comment.discussion.section
    end

    it 'should denormalize the user login' do
      comment = create :comment
      expect(comment.user_login).to eql comment.user.login
    end

    it 'should denormalize the focus type for focuses' do
      subject_comment = create :comment, focus: build(:subject)
      expect(subject_comment.focus_type).to eql 'Subject'
    end

    it 'should denormalize the board id' do
      comment = create :comment
      expect(comment.board_id).to eql comment.discussion.board.id
    end

    it 'should update the discussion comment count' do
      discussion = create :discussion
      expect {
        create :comment, discussion: discussion
      }.to change {
        discussion.reload.comments_count
      }.by 1
    end

    it 'should update the discussion last_comment_created_at at timestamp' do
      discussion = create :discussion
      first_comment = create :comment, discussion: discussion
      expect(discussion.reload.last_comment_created_at).to be_within(1.second).of first_comment.created_at
      second_comment = create :comment, discussion: discussion
      expect(discussion.reload.last_comment_created_at).to be_within(1.second).of second_comment.created_at
    end

    it 'should update the board last_comment_created_at at timestamp' do
      discussion = create :discussion
      first_comment = create :comment, discussion: discussion
      expect(discussion.board.reload.last_comment_created_at).to be_within(1.second).of first_comment.created_at
      second_comment = create :comment, discussion: discussion
      expect(discussion.board.reload.last_comment_created_at).to be_within(1.second).of second_comment.created_at
    end

    it 'should update the discussion updated_at timestamp' do
      discussion = create :discussion
      expect {
        create :comment, discussion: discussion
      }.to change {
        discussion.reload.updated_at
      }
    end

    it 'should update the discussion user count' do
      discussion = create :discussion
      expect {
        comment = create :comment, discussion: discussion
        create_list :comment, 2, discussion: discussion
        create :comment, discussion: discussion, user: comment.user
      }.to change {
        discussion.reload.users_count
      }.by 3
    end

    context 'updating board counts' do
      let(:board) do
        discussion1 = create :discussion_with_comments, comment_count: 3, user_count: 2
        board = discussion1.board
        discussion2 = create :discussion_with_comments, board: board, comment_count: 3, user_count: 2
        board
      end

      it 'should update the comment count' do
        expect(board.comments_count).to eql 6
      end

      it 'should update the user count' do
        expect(board.users_count).to eql 4
      end
    end

    context 'with a focused discussion' do
      let(:focus){ create :subject }
      let(:discussion){ create :discussion, focus: focus }
      subject{ create :comment, discussion: discussion }
      its(:focus){ is_expected.to eql focus }
    end
  end

  context 'destroying' do
    let(:subject){ create :subject }
    let(:comment){ create :comment, body: "#tag, ^S#{ subject.id }, @admins" }

    it 'should destroy tags' do
      tag = comment.tags.first
      comment.destroy
      expect{ tag.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should destroy mentions' do
      mention = comment.mentions.first
      comment.destroy
      expect{ mention.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should destroy group mentions' do
      group_mention = comment.group_mentions.first
      comment.destroy
      expect{ group_mention.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should remove reply references' do
      reply = create :comment, reply: comment
      expect{
        comment.destroy
      }.to change{
        reply.reload.reply
      }.from(comment).to nil
    end

    it 'should update the discussion last_comment_created_at at timestamp' do
      discussion = create :discussion
      first_comment = create :comment, discussion: discussion
      second_comment = create :comment, discussion: discussion
      second_comment.destroy
      expect(discussion.reload.last_comment_created_at).to be_within(1.second).of first_comment.created_at
    end

    it 'should update the board last_comment_created_at at timestamp' do
      discussion = create :discussion
      first_comment = create :comment, discussion: discussion
      second_comment = create :comment, discussion: discussion
      second_comment.destroy
      expect(discussion.board.reload.last_comment_created_at).to be_within(1.second).of first_comment.created_at
    end
  end

  describe '#soft_destroy' do
    let(:subject){ create :subject }
    let(:comment){ create :comment, body: "#tag, ^S#{ subject.id }, @admins" }
    let!(:other){ create :comment, discussion: comment.discussion }

    it 'should destroy tags' do
      tag = comment.tags.first
      comment.soft_destroy
      expect{ tag.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should destroy mentions' do
      mention = comment.mentions.first
      comment.soft_destroy
      expect{ mention.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should destroy group mentions' do
      group_mention = comment.group_mentions.first
      comment.soft_destroy
      expect{ group_mention.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should not destroy the comment' do
      comment.soft_destroy
      expect{ comment.reload }.to_not raise_error
    end

    it 'should mark the comment as destroyed' do
      comment.soft_destroy
      expect(comment.is_deleted?).to be true
    end

    it 'should close the moderation' do
      expect(comment).to receive :close_moderation
      comment.soft_destroy
    end

    it 'should clear the comment body' do
      comment.soft_destroy
      expect(comment.body).to eql 'This comment has been deleted'
    end

    it 'should destroy discussions when empty' do
      other.soft_destroy
      comment.soft_destroy
      expect{ comment.discussion.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'via a moderation' do
      let!(:discussion){ create :discussion }
      let!(:comment){ create :comment, discussion: discussion }
      let!(:moderation){ create :moderation, target: comment }
      let(:action){ { user_id: create(:user).id, message: 'deleting', action: 'destroy' } }

      before :each do
        discussion.comments.where('id <> ?', comment.id).destroy_all
        moderation.actions << action
      end

      it 'should use soft destroy' do
        allow(moderation).to receive(:target).and_return comment
        expect(comment).to receive :soft_destroy
        moderation.save
      end

      it 'should destroy the discussion' do
        moderation.save
        expect{ discussion.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'should destroy the comment' do
        moderation.save
        expect{ comment.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  context 'when moving discussions' do
    let!(:source){ create :discussion }
    let!(:destination){ create :discussion }
    let!(:comment){ create :comment, discussion: source }

    def move_comment
      Comment.find(comment.id).update! discussion_id: destination.id
    end

    it 'should update the source users_count' do
      expect{ move_comment }.to change{ source.reload.users_count }.by -1
    end

    it 'should update the source comments_count' do
      expect{ move_comment }.to change{ source.reload.comments_count }.from(1).to 0
    end

    it 'should update the source board comments_counts' do
      expect{ move_comment }.to change{ source.board.reload.comments_count }.from(1).to 0
    end

    it 'should update the source board users_counts' do
      expect{ move_comment }.to change{ source.board.reload.users_count }.from(1).to 0
    end

    it 'should update the destination users_count' do
      expect{ move_comment }.to change{ destination.reload.users_count }.from(0).to 1
    end

    it 'should update the destination comments_count' do
      expect{ move_comment }.to change{ destination.reload.comments_count }.from(0).to 1
    end

    it 'should update the destination board comments_counts' do
      expect{ move_comment }.to change{ destination.board.reload.comments_count }.from(0).to 1
    end

    it 'should update the destination board users_counts' do
      expect{ move_comment }.to change{ destination.board.reload.users_count }.from(0).to 1
    end
  end

  describe '#parse_mentions' do
    let(:subject){ create :subject }
    let(:subject_mention){ "^S#{ subject.id }" }

    let(:user){ create :user }
    let(:user_mention){ "@#{ user.login }" }
    let(:group_mention){ "@admins" }
    let(:admin_user){ create :admin, section: 'zooniverse' }

    let(:board){ create :board }
    let(:discussion){ create :discussion, board: board }

    let(:body){ "#{ subject_mention } should be added. right @#{ user.login } and @admins?" }
    let(:comment){ create :comment, discussion: discussion, body: body }

    it 'should match subjects' do
      expect(comment.mentioning).to include subject_mention => {
        'id' => subject.id, 'type' => 'Subject'
      }
    end

    it 'should match users' do
      expect(comment.mentioning).to include user_mention => {
        'id' => user.id, 'type' => 'User'
      }
    end

    it 'should match groups' do
      expect(comment.group_mentioning).to include 'admins' => '@admins'
    end

    it 'should create mentions for subjects' do
      expect(comment.mentions.where(mentionable: subject).exists?).to be true
    end

    it 'should create mentions for users' do
      expect(comment.mentions.where(mentionable: user).exists?).to be true
    end

    it 'should create group mentions' do
      expect(comment.group_mentions.where(name: 'admins').exists?).to be true
    end

    context 'when the comment is not accessible by the mentioned user' do
      let(:body){ "Hey @#{ user.login } and @#{ admin_user.login }" }
      let(:board){ create :board, permissions: { read: 'team', write: 'team' } }

      it 'should not create mentions for users without access' do
        expect(comment.mentions.where(mentionable: user).exists?).to be false
      end

      it 'should create mentions for users with access' do
        expect(comment.mentions.where(mentionable: admin_user).exists?).to be true
      end
    end
  end

  describe '#update_mentions' do
    def mention(subject)
      "^S#{subject.id}"
    end

    let(:subject1){ create :subject }
    let(:subject2){ create :subject }
    let(:comment){ create :comment, body: "#{ mention(subject1) } #{ mention(subject2) } " }

    context 'when removing' do
      before(:each){ comment.update! body: mention(subject1) }
      it 'should destroy removed mentions on update' do
        expect(comment.reload.mentions.where(mentionable: subject2).exists?).to be false
      end

      it 'should keep non-removed mentions' do
        expect(comment.reload.mentions.where(mentionable: subject1).exists?).to be true
      end
    end

    context 'when adding' do
      let(:subject3){ create :subject }
      before(:each){ comment.update! body: "#{ mention(subject1) } and #{ mention(subject3) }" }

      it 'should create added mentions on update' do
        expect(comment.reload.mentions.where(mentionable: subject3).exists?).to be true
      end

      it 'should keep non-removed mentions' do
        expect(comment.reload.mentions.where(mentionable: subject1).exists?).to be true
      end

      it 'should destroy removed mentions' do
        expect(comment.mentions.where(mentionable: subject2).exists?).to be false
      end
    end
  end

  describe '#update_group_mentions' do
    let(:comment){ create :comment, body: '@admins' }

    it 'should remove mentions on update' do
      comment.update! body: '@moderators'
      expect(comment.group_mentions.where(name: 'admins').exists?).to be false
    end

    it 'should add mentions on update' do
      comment.update! body: "#{ comment.body } @researchers"
      expect(comment.group_mentions.where(name: 'researchers').exists?).to be true
    end

    it 'should add mentions on update' do
      comment.update! body: "#{ comment.body } @scientists"
      expect(comment.group_mentions.where(name: 'scientists').exists?).to be true
    end
  end

  describe '#parse_tags' do
    let(:comment){ create :comment, body: '#tag1 not#atag #Tag' }

    it 'should match tags' do
      expect(comment.tagging).to eql '#tag1' => 'tag1', '#tag' => 'tag'
    end

    it 'should create tags' do
      expect(comment.tags.where(name: 'tag1').exists?).to be true
      expect(comment.tags.where(name: 'tag').exists?).to be true
      expect(comment.tags.count).to eql 2
    end

    context 'with mixed case tags' do
      let(:comment){ create :comment, body: '#TAG #tag' }

      it 'should only create one tag' do
        expect(comment.tags.count).to eql 1
      end
    end

    context 'with url anchors' do
      let(:comment){ create :comment, body: '#test sentence #tag and url: http://docs.panoptes.apiary.io/#reference/user/users-collection/list-all-users' }

      it 'should not parse anchors as tags' do
        expect(comment.tags.map(&:name)).to match_array ['test', 'tag']
      end
    end
  end

  describe '#update_tags' do
    let(:comment){ create :comment, body: '#tag1 not#atag #Tag' }
    before(:each){ comment.update body: '#TAG1' }

    it 'should maintain case' do
      expect(comment.reload.tags.first.name).to eql 'tag1'
    end

    context 'when removing' do
      before(:each){ comment.update body: '#tag1' }

      it 'should destroy removed tags on update' do
        expect(comment.reload.tags.where(name: 'tag').exists?).to be false
      end

      it 'should keep non-removed tags' do
        expect(comment.reload.tags.where(name: 'tag1').exists?).to be true
      end
    end

    context 'when adding' do
      let(:subject2){ create :subject }
      before(:each){ comment.update body: '#tag #newtag' }

      it 'should create added tags on update' do
        expect(comment.reload.tags.where(name: 'newtag').exists?).to be true
      end

      it 'should keep non-removed tags' do
        expect(comment.reload.tags.where(name: 'tag').exists?).to be true
      end

      it 'should destroy removed tags' do
        expect(comment.reload.tags.where(name: 'tag1').exists?).to be false
      end
    end
  end

  describe '#upvote!' do
    let(:comment){ create :comment, upvotes: { somebody: 1234 } }
    let(:voter){ create :user }

    it 'should add the user login' do
      expect {
        comment.upvote! voter
      }.to change {
        comment.reload.upvotes.keys
      }.from(['somebody']).to match_array ['somebody', voter.login]
    end
  end

  describe '#remove_upvote!' do
    let(:comment){ create :comment, upvotes: { somebody: 1234, somebody_else: 4567 } }
    let(:voter){ create :user, login: 'somebody' }

    it 'should remove the user login' do
      expect {
        comment.remove_upvote! voter
      }.to change {
        comment.reload.upvotes.keys
      }.from(['somebody', 'somebody_else']).to match_array ['somebody_else']
    end
  end

  describe '#subscribe_user' do
    let(:commenting_user){ create :user }
    let(:discussion){ create :discussion }
    let(:subscriber){ create :subscription, source: discussion, category: :participating_discussions }
    let(:subscription){ commenting_user.subscriptions.participating_discussions.where source: discussion }
    let(:comment){ create :comment, discussion: discussion, user: commenting_user }

    it 'should subscribe commenting users' do
      comment
      expect(subscription.exists?).to be true
    end

    context 'when preference is disabled' do
      before(:each) do
        commenting_user.preference_for(:participating_discussions).update enabled: false
      end

      it 'should not subscribe the user' do
        comment
        expect(subscription.exists?).to be false
      end
    end
  end

  describe '#notify_subscribers_later' do
    let(:comment){ create :comment }

    it 'should queue the notification' do
      allow(CommentSubscriptionWorker).to receive(:perform_async)
      expect(CommentSubscriptionWorker).to have_received(:perform_async).with comment.id
    end
  end

  describe '#notify_subscribers' do
    let(:participating_users){ create_list :user, 2 }
    let(:following_user){ create :user }
    let(:users){ participating_users + [following_user] }
    let(:notified_users){ Notification.all.collect &:user }
    let(:unsubscribed_user){ create :user }
    let(:discussion){ create :discussion }

    before(:each) do
      participating_users.each{ |user| user.subscribe_to discussion, :participating_discussions }
      following_user.subscribe_to discussion, :followed_discussions
      unsubscribed_user.preference_for(:participating_discussions).update enabled: false
    end

    it 'should create notifications for subscribed users' do
      comment = create :comment, discussion: discussion
      comment.notify_subscribers
      expect(notified_users).to match_array users
    end

    it 'should not create notifications for unsubscribed users' do
      comment = create :comment, discussion: discussion
      comment.notify_subscribers
      expect(notified_users).to_not include unsubscribed_user
    end

    it 'should not create a notification for the commenting user' do
      user = users.first
      comment = create :comment, discussion: discussion, user: user
      comment.notify_subscribers
      expect(user.notifications).to be_empty
    end
  end

  describe '#subscriptions_to_notify' do
    let(:discussion){ create :discussion }
    let(:comment){ create :comment, discussion: discussion, user: user1 }
    let(:user1){ create :user }
    let(:user2){ create :user }
    let(:user3){ create :user }
    let!(:participating1){ create :subscription, category: :participating_discussions, source: discussion, user: user1, enabled: true }
    let!(:participating2){ create :subscription, category: :participating_discussions, source: discussion, user: user2, enabled: false }
    let!(:participating3){ create :subscription, category: :participating_discussions, source: discussion, user: user3, enabled: false }
    let!(:following1){ create :subscription, category: :followed_discussions, source: discussion, user: user1, enabled: true }
    let!(:following2){ create :subscription, category: :followed_discussions, source: discussion, user: user2, enabled: true }
    let!(:following3){ create :subscription, category: :followed_discussions, source: discussion, user: user3, enabled: false }
    subject{ comment.subscriptions_to_notify }
    its(:length){ is_expected.to eql 1 }
    its('first.user_id'){ is_expected.to eql user2.id }
  end

  describe '#searchable?' do
    subject{ create :comment }

    context 'when the discussion is searchable' do
      before(:each){ allow(subject.discussion).to receive(:searchable?).and_return true }

      context 'when the comment is not deleted' do
        before(:each){ subject.is_deleted = false }
        it{ is_expected.to be_searchable }
      end

      context 'when the comment is deleted' do
        before(:each){ subject.is_deleted = true }
        it{ is_expected.to_not be_searchable }
      end
    end

    context 'when the discussion is not searchable' do
      before(:each){ allow(subject.discussion).to receive(:searchable?).and_return false }

      context 'when the comment is not deleted' do
        before(:each){ subject.is_deleted = false }
        it{ is_expected.to_not be_searchable }
      end

      context 'when the comment is deleted' do
        before(:each){ subject.is_deleted = true }
        it{ is_expected.to_not be_searchable }
      end
    end
  end

  describe Comment::Publishing do
    let(:comment){ create :comment }

    describe '#publish_to_event_stream_later' do
      it 'should be triggered after a commit' do
        new_comment = build(:comment)
        expect(new_comment).to receive :publish_to_event_stream_later
        new_comment.save!
      end

      it 'should enqueue the publish worker' do
        expect(CommentPublishWorker).to receive(:perform_async).with comment.id
        comment.publish_to_event_stream_later
      end

      context 'when not searchable' do
        before(:each) do
          allow(comment).to receive(:searchable?).and_return false
        end

        it 'should not be triggered' do
          expect(comment).to_not receive :publish_to_event_stream_later
          comment.run_callbacks :commit
        end
      end
    end

    describe 'event stream publishing' do
      let(:project) { double(slug: "user1/project-1") }

      describe '#publish_to_event_stream' do
        it 'should publish' do
          allow(comment).to receive(:project).and_return(project)
          expect(ZooStream).to receive(:publish).with event: 'comment',
            data: comment.to_event_stream,
            shard_by: comment.discussion_id
          comment.publish_to_event_stream
        end

        it 'should not raise error if not linked to a project' do
          # not being able to set the model data...
          # one of the reasons why i dislike model callbacks that change state
          allow(comment).to receive(:section).and_return("zooniverse")
          expect { comment.publish_to_event_stream }.not_to raise_error
        end
      end

      describe '#to_event_stream' do
        let(:payload) { comment.to_event_stream }
        let(:comment_suffix) { "#{comment.board_id}/#{comment.discussion_id}?comment=#{comment.id}" }
        let(:url) { "#{FrontEnd.project_talk(comment.project)}/#{comment_suffix}" }

        it "should have the correct payload", :aggregate_failures do
          allow(comment).to receive(:project).and_return(project)
          expect(payload[:id]).to eql comment.id
          expect(payload[:board_id]).to eql comment.board_id
          expect(payload[:discussion_id]).to eql comment.discussion_id
          expect(payload[:focus_id]).to eql comment.focus_id
          expect(payload[:focus_type]).to eql comment.focus_type
          expect(payload[:project_id]).to eql comment.project_id
          expect(payload[:section]).to eql comment.section
          expect(payload[:body]).to eql comment.body
          expect(payload[:created_at]).to eql comment.created_at.as_json
          expect(payload[:user_id]).to be_a(String)
          expect(payload[:user_ip]).to eql comment.user_ip.to_s
          expect(payload[:url]).to eql url
        end

        context "when the comment doesn't belong to a project" do
          let(:comment) { build(:comment, section: "zooniverse") }

          it "should have an zoo wide talk url" do
            url = "#{FrontEnd.zooniverse_talk}/#{comment_suffix}"
            expect(payload[:url]).to eql url
          end
        end
      end
    end
  end
end
