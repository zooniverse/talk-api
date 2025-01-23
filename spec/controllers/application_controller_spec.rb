require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller authenticating', :root

  describe '#root' do
    context 'with json' do
      before(:each){ get :root, format: :json }

      it 'should render json' do
        expect(response.media_type).to eql 'application/json'
      end

      it 'should list resources' do
        expect(response.json).to include users: { href: '/users', type: 'users' }
      end
    end

    context 'with application/vnd.api+json' do
      before(:each){ get :root, format: :json_api }

      it 'should render json' do
        expect(response.media_type).to eql 'application/json'
      end

      it 'should list resources' do
        expect(response.json).to include users: { href: '/users', type: 'users' }
      end
    end

    context 'with html' do
      before(:each) do
        allow(FrontEnd).to receive(:zooniverse_talk).and_return 'http://talkhost'
        get :root
      end

      it 'should render html' do
        expect(response.media_type).to eql 'text/html'
      end

      it 'should redirect' do
        expect(response).to be_redirect
      end

      it 'should redirect to the talk host' do
        expect(response.location).to eql 'http://talkhost'
      end
    end
  end
end
