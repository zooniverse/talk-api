require 'spec_helper'

RSpec.shared_examples_for 'a search proxy' do
  describe '.search' do
    it 'should parse the query' do
      expect(described_class).to receive(:_parse_query).with 'test query'
      described_class.search 'test query'
    end
    
    it 'should search with_content' do
      expect(described_class.searchable_klass).to receive(:with_content)
        .with 'test & query'
      
      described_class.search 'test query'
    end
  end
end

RSpec.shared_examples_for 'a search query parser' do
  describe '._parse_query' do
    def expect_parsed(query, parsed)
      expect(described_class._parse_query(query)).to eql parsed
    end
    
    context 'with unspaced booleans' do
      it 'should normalize spacing' do
        expect_parsed 'a &!b', 'a & ! b'
      end
    end
    
    context 'with natural language booleans' do
      it 'should replace booleans' do
        expect_parsed 'a and b or c and not d', 'a & b | c & ! d'
      end
    end
    
    context 'with unspecified logic' do
      it 'should default to ANDs' do
        expect_parsed 'foo bar', 'foo & bar'
      end
    end
    
    context 'with natural nots' do
      it 'should not replace them at the start of terms' do
        expect_parsed 'blah order', 'blah & order'
      end
      
      it 'should not replace them at the end of terms' do
        expect_parsed 'cannot login', 'cannot & login'
      end
      
      it 'should not replace them inside terms' do
        expect_parsed 'mordor gandalf', 'mordor & gandalf'
      end
      
      it 'should not replace them at the start of the query' do
        expect_parsed 'nothing here', 'nothing & here'
      end
      
      it 'should not replace them at the end of the query' do
        expect_parsed 'cellar door', 'cellar & door'
      end
    end
    
    context 'with invalid logic' do
      it 'should repair x & & y' do
        expect_parsed 'x & & y', 'x & y'
      end
      
      it 'should repair x & | y' do
        expect_parsed 'x & | y', 'x & y'
      end
      
      it 'should repair x | & y' do
        expect_parsed 'x | & y', 'x | y'
      end
      
      it 'should repair x | | y' do
        expect_parsed 'x | | y', 'x | y'
      end
      
      it 'should repair x ! & y' do
        expect_parsed 'x ! & y', 'x & ! y'
      end
      
      it 'should repair x ! | y' do
        expect_parsed 'x ! | y', 'x & ! y'
      end
      
      it 'should repair x ! ! y' do
        expect_parsed 'x ! ! y', 'x & ! y'
      end
      
      it 'should repair &&x' do
        expect_parsed '&&x', 'x'
      end
      
      it 'should repair |x' do
        expect_parsed '|x', 'x'
      end
      
      it 'should repair !!x' do
        expect_parsed '!!x', '! x'
      end
      
      it 'should repair |!x' do
        expect_parsed '|!x', '! x'
      end
      
      it 'should repair    & x' do
        expect_parsed '   & x', 'x'
      end
    end
    
    context 'with uncombined NOTs' do
      it 'should default to an ANDed NOT' do
        expect_parsed 'a & b !c', 'a & b & ! c'
      end
    end
  end
end

RSpec.shared_examples_for 'a searchable interface' do
  it_behaves_like 'a search proxy'
  it_behaves_like 'a search query parser'
end
