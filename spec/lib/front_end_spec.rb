require 'spec_helper'

RSpec.describe FrontEnd, type: :lib do
  subject{ FrontEnd }
  let(:production_host){ 'https://www.zooniverse.org' }
  let(:other_host){ 'http://demo.zooniverse.org/panoptes-front-end' }
  
  describe '.host' do
    before(:each){ allow(Rails.env).to receive(:production?).and_return is_production }
    
    context 'in production' do
      let(:is_production){ true }
      its(:host){ is_expected.to eql production_host }
    end
    
    context 'in other environments' do
      let(:is_production){ false }
      its(:host){ is_expected.to eql other_host }
    end
  end
  
  describe '.zooniverse_talk' do
    before(:each){ expect(subject).to receive(:host).and_return 'host' }
    its(:zooniverse_talk){ is_expected.to eql 'host/#/talk' }
  end
  
  describe '.project_talk' do
    let(:project){ create :project, slug: 'foo/bar' }
    before(:each){ expect(subject).to receive(:host).and_return 'host' }
    
    it 'should link to the project talk' do
      expect(subject.project_talk(project)).to eql 'host/#/projects/foo/bar/talk'
    end
  end
  
  describe '.talk_root_for' do
    let(:project){ create :project, slug: 'foo/bar' }
    before(:each){ expect(subject).to receive(:host).and_return 'host' }
    
    context 'with a project' do
      let(:board){ create :board, section: "project-#{ project.id }" }
      
      it 'should link to the project talk' do
        expect(subject.talk_root_for(board)).to eql 'host/#/projects/foo/bar/talk'
      end
    end
    
    context 'without a project' do
      let(:board){ create :board, section: 'zooniverse' }
      
      it 'should link to the zooniverse talk' do
        expect(subject.talk_root_for(board)).to eql 'host/#/talk'
      end
    end
  end
  
  describe '.link_to' do
    RSpec.shared_examples_for 'FrontEnd.link_to' do |klass, expected|
      context "with a #{ klass }" do
        before(:each){ expect(subject).to receive(:host).and_return 'host' }
        
        it "should link to the #{ klass } path" do
          expect(FrontEnd.link_to(object)).to eql expected
        end
      end
    end
    
    it_behaves_like 'FrontEnd.link_to', Board, 'host/#/talk/123' do
      let(:object){ create :board, id: 123 }
    end
    
    it_behaves_like 'FrontEnd.link_to', Comment, 'host/#/talk/1/2?comment=3' do
      let(:board){ create :board, id: 1 }
      let(:discussion){ create :discussion, id: 2, board: board }
      let(:object){ create :comment, id: 3, discussion: discussion }
    end
    
    it_behaves_like 'FrontEnd.link_to', Conversation, 'host/#/inbox/123' do
      let(:object){ create :conversation, id: 123 }
    end
    
    it_behaves_like 'FrontEnd.link_to', Discussion, 'host/#/talk/1/2' do
      let(:board){ create :board, id: 1 }
      let(:object){ create :discussion, id: 2, board: board }
    end
    
    it_behaves_like 'FrontEnd.link_to', Message, 'host/#/inbox/123' do
      let(:conversation){ create :conversation_with_messages, id: 123 }
      let(:object){ create :message, conversation: conversation }
    end
    
    it_behaves_like 'FrontEnd.link_to', User, 'host/#/talk/moderations' do
      let(:object){ create :moderation }
    end
    
    it_behaves_like 'FrontEnd.link_to', Project, 'host/#/projects/foo/bar' do
      let(:object){ create :project, slug: 'foo/bar' }
    end
    
    it_behaves_like 'FrontEnd.link_to', User, 'host/#/users/Foo' do
      let(:object){ create :user, login: 'Foo' }
    end
    
    it_behaves_like 'FrontEnd.link_to', UserConversation, 'host/#/inbox/123' do
      let(:conversation){ create :conversation_with_messages, id: 123 }
      let(:object){ create :user_conversation, conversation: conversation }
    end
  end
end
