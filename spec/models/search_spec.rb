require 'spec_helper'

RSpec.describe Search, type: :model do
  it_behaves_like 'a search query parser'
  before(:each){ Collection.refresh! }
  
  it 'should set the default page size' do
    expect(Search.default_per_page).to eql 10
  end
  
  it 'should set the max page size' do
    expect(Search.max_per_page).to eql 100
  end
  
  describe '.of_type' do
    it 'should query a type' do
      sql = Search.of_type('foo').to_sql
      expect(sql).to match /"searchable_type" = 'foo'/
    end
    
    it 'should query multiple types' do
      sql = Search.of_type(['foo', 'bar']).to_sql
      expect(sql).to match /"searchable_type" IN \('foo', 'bar'\)/
    end
  end
  
  describe '.in_section' do
    it 'should query a section' do
      sql = Search.in_section('foo').to_sql
      expect(sql).to match /"section" = 'foo'/
    end
  end
  
  describe '.with_content' do
    it 'should parse the query' do
      expect(Search).to receive(:_parse_query).with 'foo'
      Search.with_content 'foo'
    end
    
    it 'should query content' do
      sql = Search.with_content('foo').to_sql
      expect(sql).to match /content @@ to_tsquery\('foo'\)/
    end
    
    it 'should order by search rank' do
      sql = Search.with_content('foo').to_sql
      expect(sql).to match /ORDER BY ts_rank\(content, 'foo'\) desc/
    end
  end
  
  describe '.serialize_search' do
    it 'should preload searchables' do
      expect(Search).to receive(:preload).with(:searchable).and_call_original
      Search.with_content('foo').serialize_search
    end
    
    it 'should return serialized searchables' do
      board = create :board
      expect_any_instance_of(Search).to receive(:serialize)
      Search.serialize_search
    end
  end
  
  describe '#serialize' do
    let(:board){ create :board }
    let(:search){ Search.where(searchable_id: board.id, searchable_type: 'Board').first }
    
    it 'should use the serializer' do
      expect(BoardSerializer).to receive(:as_json).with an_instance_of(Board)
      search.serialize
    end
    
    it 'should memoize the serializer class' do
      search.serialize
      expect(Search.serializers['Board']).to eql BoardSerializer
    end
  end
end
