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
      expect(sql).to match /sections @> array\['foo'\]::varchar\[\]/
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
    let!(:comment){ create :comment }
    let!(:board){ create :board }
    let!(:discussion){ create :discussion }
    let!(:collection){ create :collection }
    let(:scope){ Search.order('searchable_id desc') }
    let(:list){ scope.all.to_a.collect{ |s| "#{ s.searchable_type }-#{ s.searchable_id }" } }
    let(:serialized){ scope.serialize_search.collect{ |h| "#{ h[:type] }-#{ h[:id] }" } }
    before(:each){ Collection.refresh! }
    
    it 'find all results' do
      expect(serialized).to eql list
    end
  end
end
