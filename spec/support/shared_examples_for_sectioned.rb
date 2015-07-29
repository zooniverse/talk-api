require 'spec_helper'

RSpec.shared_examples_for 'a sectioned model' do
  let!(:project){ create :project }
  let(:instance){ build described_class }
  before(:each){ instance.project_id = nil }
  
  context 'with a project' do
    before :each do
      instance.section = "project-#{ project.id }"
      instance.set_project_id
    end
    
    it 'should set the project_id' do
      expect(instance.project_id).to eql project.id
    end
    
    it 'should belong to the project' do
      expect(instance.project).to eql project
    end
  end
  
  context 'without a project' do
    before :each do
      instance.section = 'zooniverse'
      instance.set_project_id
    end
    
    it 'should not have a project_id' do
      expect(instance.project_id).to be_nil
    end
    
    it 'should not have a project' do
      expect(instance.project).to be_nil
    end
  end
end
