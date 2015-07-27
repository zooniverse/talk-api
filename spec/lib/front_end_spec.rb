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
    
    context "in other environemtns" do
      let(:is_production){ false }
      its(:host){ is_expected.to eql other_host }
    end
  end
  
  describe '.zooniverse_talk' do
    before(:each){ expect(subject).to receive(:host).and_return 'host' }
    its(:zooniverse_talk){ is_expected.to eql 'host/#/talk' }
  end
end
