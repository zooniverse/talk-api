require 'spec_helper'

RSpec.describe DiscussionSchema, type: :schema do
  shared_examples_for 'a discussion schema format' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['discussions'] }
    
    with 'properties .discussions' do
      its(:type){ is_expected.to eql 'object' }
      
      with 'properties .title' do
        its(:type){ is_expected.to eql 'string' }
        its(:minLength){ is_expected.to eql 3 }
        its(:maxLength){ is_expected.to eql 140 }
      end
    end
  end
  
  shared_examples_for 'a discussion schema' do
    let(:schema_method){ :create }
    let(:record){ create :discussion, section: 'test' }
    let(:user){ create :user }
    let(:schema_context){ { policy: CommentPolicy.new(user, record) } }
    
    context 'without privilege' do
      include_examples 'a discussion schema format'
      
      with 'properties .discussions' do
        its(:required){ is_expected.to eql %w(title) }
        
        with :properties do
          its(:sticky){ is_expected.to be nil }
          its(:locked){ is_expected.to be nil }
        end
      end
    end
    
    context 'with privilege' do
      include_examples 'a discussion schema format'
      let(:user){ create :user, roles: { test: ['moderator'] } }
      
      with 'properties .discussions' do
        its(:required){ is_expected.to eql %w(title board_id) }
        
        with :properties do
          its(:sticky){ is_expected.to eql type: 'boolean' }
          its(:locked){ is_expected.to eql type: 'boolean' }
        end
      end
    end
  end
  
  describe '#create' do
    it_behaves_like 'a discussion schema'
    let(:schema_method){ :create }
  end
  
  describe '#update' do
    it_behaves_like 'a discussion schema'
    let(:schema_method){ :update }
  end
end
