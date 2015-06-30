require 'spec_helper'

RSpec.describe TagsController, type: :controller do
  let(:resource){ Tag }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    destroy: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  describe '#popular' do
    let(:project){ create :project, name: 'tagged' }
    let(:section){ "project-#{ project.id }" }
    let(:tagged_subject){ create :subject }
    let(:tagged_collection){ create :collection }
    
    before :each do
      create_list :tag, 2, taggable_section: section, taggable: tagged_subject,    name: 'subject_least'
      create_list :tag, 4, taggable_section: section, taggable: tagged_subject,    name: 'subject_most'
      create_list :tag, 1, taggable_section: section, taggable: tagged_collection, name: 'collection_least'
      create_list :tag, 3, taggable_section: section, taggable: tagged_collection, name: 'collection_most'
    end
    
    RSpec.shared_context 'TagsController#popular' do
      let(:params){ { } }
      subject{ response }
      let(:tags){ response.json['tags'] }
      let(:tag_names){ tags.collect{ |h| h['name'] } }
      before(:each){ get :popular, params }
    end
    
    RSpec.shared_examples_for 'TagsController#popular_meta_for' do |expected_count: nil, expected_limit: nil|
      subject{ OpenStruct.new response.json['meta']['tags'] }
      its(:page){ is_expected.to eql 1 }
      its(:page_size){ is_expected.to eql expected_limit }
      its(:count){ is_expected.to eql expected_count }
      its(:include){ is_expected.to eql [] }
      its(:page_count){ is_expected.to eql 1 }
      its(:previous_page){ is_expected.to be_nil }
      its(:next_page){ is_expected.to be_nil }
      its(:first_href){ is_expected.to eql '/tags/popular' }
      its(:previous_href){ is_expected.to be_nil }
      its(:next_href){ is_expected.to be_nil }
      its(:last_href){ is_expected.to eql '/tags/popular' }
    end
    
    context 'without a section' do
      include_context 'TagsController#popular'
      it{ is_expected.to be_unprocessable }
      its(:json){ is_expected.to eql 'error' => 'param is missing or the value is empty: section' }
    end
    
    context 'with an empty section' do
      include_context 'TagsController#popular'
      it_behaves_like 'TagsController#popular_meta_for', expected_count: 0, expected_limit: 10
      let(:params){ { section: 'project-1' } }
      it{ is_expected.to be_successful }
      
      describe 'response' do
        subject{ tag_names }
        it{ is_expected.to eql [] }
      end
    end
    
    context 'with a section' do
      include_context 'TagsController#popular'
      it_behaves_like 'TagsController#popular_meta_for', expected_count: 4, expected_limit: 10
      let(:params){ { section: section } }
      it{ is_expected.to be_successful }
      
      describe 'response' do
        subject{ tag_names }
        it{ is_expected.to eql %w(subject_most collection_most subject_least collection_least) }
      end
    end
    
    context 'with a type' do
      include_context 'TagsController#popular'
      it_behaves_like 'TagsController#popular_meta_for', expected_count: 2, expected_limit: 10
      let(:params){ { section: section, type: 'subject' } }
      it{ is_expected.to be_successful }
      
      describe 'response' do
        subject{ tag_names }
        it{ is_expected.to eql %w(subject_most subject_least) }
      end
    end
    
    context 'with a limit' do
      include_context 'TagsController#popular'
      it_behaves_like 'TagsController#popular_meta_for', expected_count: 1, expected_limit: 1
      let(:params){ { section: section, type: 'subject', limit: 1 } }
      it{ is_expected.to be_successful }
      
      describe 'response' do
        subject{ tag_names }
        it{ is_expected.to eql %w(subject_most) }
      end
    end
  end
end
