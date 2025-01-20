require 'spec_helper'

RSpec.describe DataRequest, type: :model do
  it_behaves_like 'a sectioned model'
  it_behaves_like 'a subscribable model'
  it_behaves_like 'a notifiable model'

  context 'validating' do
    it 'should require a user' do
      without_user = build :data_request, user: nil
      expect(without_user).to fail_validation
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
      duplicate = build :data_request, user_id: existing.user_id
      expect(duplicate).to fail_validation kind: 'has already been created'
    end
  end

  it_behaves_like 'an expirable model' do
    let!(:fresh){[
      create(:comments_data_request),
      create(:tags_data_request)
    ]}

    let!(:stale) do
      Timecop.travel(1.month.ago) do
        [
          create(:comments_data_request),
          create(:tags_data_request)
        ]
      end
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
      allow(TagExportWorker).to receive(:perform_async)
      data_request = build :tags_data_request
      data_request.save!
      expect(TagExportWorker).to have_received(:perform_async).with data_request.id
    end
  end

  describe '#notify_user' do
    let(:subscribed_user){ create :user }
    let(:unsubscribed_user){ create :user }
    let(:data_request){ create :data_request, user: user }

    before :each do
      unsubscribed_user.preference_for(:system).update enabled: false
    end

    context 'with a subscribed user' do
      let(:user){ subscribed_user }
      subject{ data_request.notify_user url: 'foo', message: 'bar' }

      it{ is_expected.to be_a Notification }
      its(:user){ is_expected.to eql user }
      its(:section){ is_expected.to eql data_request.section }
      its(:message){ is_expected.to eql 'bar' }
      its(:url){ is_expected.to eql 'foo' }
      its(:source){ is_expected.to eql data_request }

      context 'with a subscription' do
        subject{ data_request.notify_user(url: 'foo', message: 'bar').subscription }

        it{ is_expected.to be_system }
        its(:source){ is_expected.to eql data_request }
      end
    end

    context 'without a subscribed user' do
      let(:user){ unsubscribed_user }
      subject{ data_request.notify_user url: 'foo', message: 'bar' }
      it{ is_expected.to be nil }
    end
  end
end
