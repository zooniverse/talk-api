require 'spec_helper'

RSpec.shared_examples_for 'a rendered action' do
  it_behaves_like 'a controller action'
end

RSpec.shared_examples_for 'a controller rendering' do |*actions|
  let(:record){ create resource.name.tableize.singularize.to_sym }

  if :index.in? actions
    describe '#index' do
      it_behaves_like 'a rendered action' do
        let(:verb){ :get }
        let(:action){ :index }
        let(:params){ { } }
        let(:authorizable){ resource }
        let(:status){ 200 }
      end

      it 'should paginate the serializer' do
        expect(subject.serializer_class).to receive(:page).and_call_original
        get :index
      end
    end
  end

  if :show.in? actions
    describe '#show' do
      it_behaves_like 'a rendered action' do
        let(:verb){ :get }
        let(:action){ :show }
        let(:params){ { id: record.id } }
        let(:authorizable){ resource.where(id: record.id) }
        let(:status){ 200 }
      end

      it 'should serialize the resource' do
        expect(subject.serializer_class).to receive(:resource).and_call_original
        get :show, params: { id: record.id }
      end
    end
  end

  if :destroy.in? actions
    describe '#destroy' do
      it_behaves_like 'a rendered action' do
        let(:verb){ :delete }
        let(:action){ :destroy }
        let(:params){ { id: record.id } }
        let(:authorizable){ record }
        let(:status){ 204 }
      end
    end
  end
end
