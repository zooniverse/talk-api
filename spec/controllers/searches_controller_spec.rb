RSpec.describe SearchesController, type: :controller do
  let(:send_request){ get :index, request_params.merge(format: :json) }
  
  describe '#index' do
    context 'without a section param' do
      let(:request_params){ { } }
      subject{ response }
      before(:each){ send_request }
      
      its(:status){ is_expected.to eql 422 }
      its(:content_type){ is_expected.to eql 'application/json' }
      
      describe 'json' do
        subject{ response.json }
        
        it{ is_expected.to be_a Hash }
        its(['error']){ is_expected.to eql 'param is missing or the value is empty: section' }
      end
    end
    
    context 'without a query param' do
      let(:request_params){ { section: 'zooniverse' } }
      subject{ response }
      before(:each){ send_request }
      
      its(:status){ is_expected.to eql 422 }
      its(:content_type){ is_expected.to eql 'application/json' }
      
      describe 'json' do
        subject{ response.json }
        
        it{ is_expected.to be_a Hash }
        its(['error']){ is_expected.to eql 'param is missing or the value is empty: query' }
      end
    end
    
    context 'with an invalid type' do
      let(:request_params) do
        { section: 'zooniverse', query: 'testing', types: ['boards', 'foo'] }
      end
      
      subject{ response }
      before(:each){ send_request }
      
      its(:status){ is_expected.to eql 422 }
      its(:content_type){ is_expected.to eql 'application/json' }
      
      describe 'json' do
        subject{ response.json }
        
        it{ is_expected.to be_a Hash }
        its(['error']){ is_expected.to eql 'Foo is not a valid search type' }
      end
    end
    
    context 'with invalid types' do
      let(:request_params) do
        { section: 'zooniverse', query: 'testing', types: ['foo,bar'] }
      end
      
      subject{ response }
      before(:each){ send_request }
      
      its(:status){ is_expected.to eql 422 }
      its(:content_type){ is_expected.to eql 'application/json' }
      
      describe 'json' do
        subject{ response.json }
        
        it{ is_expected.to be_a Hash }
        its(['error']){ is_expected.to eql 'The property #/types contains an invalid search type' }
      end
    end
    
    context 'with a valid request' do
      let(:request_params) do
        { section: 'zooniverse', query: 'testing', types: ['boards', 'comments'] }
      end
      
      subject{ response }
      before(:each){ send_request }
      
      its(:status){ is_expected.to eql 200 }
      its(:content_type){ is_expected.to eql 'application/json' }
      
      describe 'json' do
        subject{ response.json }
        
        it{ is_expected.to be_a Hash }
        it{ is_expected.to_not have_key 'error' }
        it{ is_expected.to have_key 'searches' }
        it{ is_expected.to have_key 'meta' }
      end
    end
    
    describe 'querying' do
      let(:request_params) do
        {
          section: 'zooniverse',
          query: 'testing',
          types: ['boards'],
          page: '1',
          page_size: '2'
        }
      end
      
      it 'should scope to type' do
        expect(Search).to receive(:of_type).with(['Board']).and_call_original
        send_request
      end
      
      it 'should scope to section' do
        allow(Search).to receive(:of_type).and_return Search
        expect(Search).to receive(:in_section).with('zooniverse')
          .and_call_original
        send_request
      end
      
      it 'should search content' do
        allow(Search).to receive_message_chain('of_type.in_section')
          .and_return Search
        expect(Search).to receive(:with_content).with('testing')
          .and_call_original
        send_request
      end
      
      it 'should paginate results' do
        allow(Search).to receive_message_chain('of_type.in_section.with_content')
          .and_return Search
        expect(Search).to receive(:page).with('1').and_call_original
        send_request
      end
      
      it 'should serialize searchables' do
        expect(Search).to receive(:serialize_search).and_call_original
        send_request
      end
    end
    
    describe 'meta' do
      let!(:board){ create :board, title: 'Test board', section: 'zooniverse', permissions: { read: 'all' } }
      let!(:discussions){ discussions = create_list :discussion, 2, title: 'testing', board: board }
      let!(:comments){ discussions.each{ |d| create_list :comment, 2, discussion: d, body: 'tested' } }
      
      let(:page){ '2' }
      let(:request_params) do
        {
          section: 'zooniverse',
          query: 'testing',
          types: ['boards', 'comments'],
          page: page,
          page_size: '2'
        }
      end
      
      before(:each){ send_request }
      subject{ response.json['meta']['searches'] }
      
      def search_href_for(page:)
        "/searches?page=#{ page }&page_size=2&section=zooniverse" +
        '&query=testing&types=["boards", "comments"]'
      end
      
      its(['page']){ is_expected.to eql 2 }
      its(['page_size']){ is_expected.to eql 2 }
      its(['count']){ is_expected.to eql 5 } # 1 board, 4 comments
      its(['include']){ is_expected.to be_empty }
      its(['page_count']){ is_expected.to eql 3 }
      its(['previous_page']){ is_expected.to eql 1 }
      its(['next_page']){ is_expected.to eql 3 }
      its(['first_href']){ is_expected.to eql search_href_for(page: 1) }
      its(['previous_href']){ is_expected.to eql search_href_for(page: 1) }
      its(['next_href']){ is_expected.to eql search_href_for(page: 3) }
      its(['last_href']){ is_expected.to eql search_href_for(page: 3) }
      
      context 'with the first page' do
        let(:page){ '1' }
        its(['previous_page']){ is_expected.to be_nil }
        its(['previous_href']){ is_expected.to be_nil }
        its(['next_href']){ is_expected.to eql search_href_for(page: 2) }
      end
      
      context 'with the last page' do
        let(:page){ '3' }
        its(['next_page']){ is_expected.to be_nil }
        its(['previous_href']){ is_expected.to eql search_href_for(page: 2) }
        its(['next_href']){ is_expected.to be_nil }
      end
    end
  end
end
