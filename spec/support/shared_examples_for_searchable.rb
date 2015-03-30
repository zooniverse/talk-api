require 'spec_helper'

RSpec.shared_examples_for 'a searchable model' do
  let(:search_klass_name){ "Searchable#{ described_class.name }" }
  let(:search_klass){ Object.const_get search_klass_name }
  
  context 'including Searchable' do
    subject{ described_class }
    
    it 'should define a search class' do
      expect(Object.const_defined?(search_klass_name)).to be true
    end
    
    its(:searchable_klass){ is_expected.to eql search_klass }
  end
  
  describe '._searchable_model' do
    subject{ described_class._searchable_model }
    
    it{ is_expected.to eql search_klass }
    its(:searchable_klass){ is_expected.to eql described_class }
  end
  
  describe '#searchable?' do
    context 'when searchable' do
      subject{ searchable }
      it{ is_expected.to be_searchable }
    end
    
    context 'when not searchable' do
      subject{ unsearchable }
      it{ is_expected.to_not be_searchable }
    end
  end
  
  describe '#create_searchable' do
    context 'when searchable' do
      it 'should be called' do
        expect(subject.searchable_klass).to receive(:create)
          .with(searchable: a_kind_of(described_class))
        searchable
      end
    end
    
    context 'when not searchable' do
      it 'should not be called' do
        expect(subject).to_not receive :create_searchable
        unsearchable
      end
    end
  end
  
  describe '#update_searchable' do
    context 'when searchable' do
      context 'when searchable exists' do
        it 'should update the searchable' do
          searchable
          expect(searchable.searchable).to receive(:set_content)
          searchable.update_searchable
        end
      end
      
      context 'when searchable does not exist' do
        it 'should create the searchable' do
          searchable.searchable.destroy
          searchable.reload
          expect(subject.searchable_klass).to receive(:create)
            .with(searchable: searchable)
          searchable.update_searchable
        end
      end
    end
    
    context 'when not searchable' do
      it 'should not be called' do
        expect(subject).to_not receive :update_searchable
        unsearchable
      end
    end
  end
  
  describe '#destroy_searchable' do
    context 'when becoming unsearchable' do
      it 'should remove the searchable' do
        expect(searchable.searchable).to receive :destroy
        def searchable.searchable?; false; end
        searchable.save
      end
    end
    
    context 'when searchable' do
      it 'should not be called' do
        expect(searchable.searchable).to_not receive :destroy
        searchable.updated_at = Time.now
        searchable.save
      end
    end
  end
  
  describe "Searchable#{ described_class.name }" do
    let(:searchable_model){ searchable.searchable }
    
    it 'should belong to a searchable model' do
      # yeah... in other words
      #   board.searchable should be a SearchableBoard
      #   board.searchable.searchable should be a board
      expect(searchable.searchable.searchable).to eql searchable
    end
    
    describe '.with_content' do
      it 'should query content' do
        sql = search_klass.with_content('testing').to_sql
        expect(sql).to match /WHERE \(content @@ to_tsquery\('testing'\)\)/
      end
    end
    
    describe '#set_content' do
      it 'should update the content' do
        expect(searchable_model.class.connection).to receive(:execute)
          .with(searchable.searchable_update)
        searchable_model.set_content
      end
    end
    
    describe '#_denormalize' do
      subject{ searchable_model }
      its(:searchable_type){ is_expected.to eql searchable.class.name }
      its(:section){ is_expected.to eql searchable.section }
    end
  end
end
