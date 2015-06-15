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
      before(:each){ get :popular, params }
    end
    
    context 'without a section' do
      include_context 'TagsController#popular'
      it{ is_expected.to be_unprocessable }
      its(:json){ is_expected.to eql 'error' => 'param is missing or the value is empty: section' }
    end
    
    context 'with an empty section' do
      include_context 'TagsController#popular'
      let(:params){ { section: 'project-1' } }
      it{ is_expected.to be_successful }
      its(:json){ is_expected.to eql 'tags' => [] }
    end
    
    context 'with a section' do
      include_context 'TagsController#popular'
      let(:params){ { section: section } }
      it{ is_expected.to be_successful }
      its(:json){ is_expected.to eql 'tags' => %w(subject_most collection_most subject_least collection_least) }
    end
    
    context 'with a type' do
      include_context 'TagsController#popular'
      let(:params){ { section: section, type: 'subject' } }
      it{ is_expected.to be_successful }
      its(:json){ is_expected.to eql 'tags' => %w(subject_most subject_least) }
    end
    
    context 'with a limit' do
      include_context 'TagsController#popular'
      let(:params){ { section: section, type: 'subject', limit: 1 } }
      it{ is_expected.to be_successful }
      its(:json){ is_expected.to eql 'tags' => %w(subject_most) }
    end
  end
end
