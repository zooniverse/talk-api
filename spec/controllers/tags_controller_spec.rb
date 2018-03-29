require 'spec_helper'

RSpec.describe TagsController, type: :controller do
  let(:resource){ Tag }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 405, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 405, response: :error }

  describe '#popular' do
    let(:project){ create :project, display_name: 'tagged' }
    let(:section){ "project-#{ project.id }" }
    let(:tagged_subject){ create :subject }

    before :each do
      create_list :tag, 2, taggable_section: section, taggable: tagged_subject,    name: 'subject_least'
      create_list :tag, 4, taggable_section: section, taggable: tagged_subject,    name: 'subject_most'
    end

    RSpec.shared_examples 'TagsController#popular' do |serializer: nil|
      let(:tag_serializer){ serializer }
      let(:params){ { } }
      subject{ response }
      let(:tags){ response.json['popular'] }
      let(:tag_names){ tags.collect{ |h| h['name'] } }
      before(:each) do
        if serializer
          allow(serializer).to receive(:resource).and_call_original
        end
        get :popular, params
      end

      it 'should use the correct serializer' do
        if serializer
          expect(serializer).to have_received :resource
        end
      end
    end

    context 'without a section' do
      it_behaves_like 'TagsController#popular' do
        it{ is_expected.to be_unprocessable }

        describe 'response' do
          subject{ response.json['error'] }
          it{ is_expected.to eql 'param is missing or the value is empty: section' }
        end
      end
    end

    context 'with an empty section' do
      it_behaves_like 'TagsController#popular', serializer: PopularSectionTagSerializer do
        let(:params){ { section: 'project-1' } }
        it{ is_expected.to be_successful }

        describe 'response' do
          subject{ tag_names }
          it{ is_expected.to eql [] }
        end
      end
    end

    context 'with a section' do
      it_behaves_like 'TagsController#popular', serializer: PopularSectionTagSerializer do
        let(:params){ { section: section } }
        it{ is_expected.to be_successful }

        describe 'response' do
          subject{ tag_names }
          it{ is_expected.to eql %w(subject_most subject_least) }
        end
      end
    end

    context 'with a type' do
      it_behaves_like 'TagsController#popular', serializer: PopularFocusTagSerializer do
        let(:params){ { section: section, taggable_type: 'Subject' } }
        it{ is_expected.to be_successful }

        describe 'response' do
          subject{ tag_names }
          it{ is_expected.to eql %w(subject_most subject_least) }
        end
      end
    end

    context 'with a tag name' do
      it_behaves_like 'TagsController#popular', serializer: PopularFocusTagSerializer do
        let(:params){ { section: section, taggable_type: 'Subject', name: 'subject_most' } }
        it{ is_expected.to be_successful }

        describe 'response' do
          subject{ tag_names }
          it{ is_expected.to eql ['subject_most'] }
        end
      end
    end

    context 'with a mixed case tag name' do
      it_behaves_like 'TagsController#popular', serializer: PopularFocusTagSerializer do
        let(:params){ { section: section, taggable_type: 'Subject', name: 'SUBJECT_Most' } }
        it{ is_expected.to be_successful }

        describe 'response' do
          subject{ tag_names }
          it{ is_expected.to eql ['subject_most'] }
        end
      end
    end

    context 'with a specific focus' do
      it_behaves_like 'TagsController#popular', serializer: PopularFocusTagSerializer do
        let(:params){ { section: section, taggable_type: 'Subject', taggable_id: tagged_subject.id } }
        it{ is_expected.to be_successful }

        describe 'response' do
          subject{ tag_names }
          it{ is_expected.to eql ['subject_most', 'subject_least'] }
        end
      end
    end
  end

  describe '#autocomplete' do
    let!(:tag){ create :tag, name: 'foo' }
    let(:params){ { } }
    subject{ response }
    before(:each){ get :autocomplete, params }

    context 'without a search' do
      let(:params){ { search: 'f' } }
      it{ is_expected.to be_unprocessable }
    end

    context 'without a section' do
      let(:params){ { section: 'f' } }
      it{ is_expected.to be_unprocessable }
    end

    context 'with valid params' do
      let(:params){ { section: 'project-1', search: 'f' } }
      it{ is_expected.to be_successful }

      it 'should return the tags' do
        expect(response.json[:tags]).to match_array [{ 'name' => 'foo' }]
      end

      it 'should use the completer' do
        completer = double results: []
        expect(TagCompletion).to receive(:new).with('f', 'project-1', limit: 5).and_return completer
        expect(completer).to receive :results
        get :autocomplete, params
      end
    end
  end
end
