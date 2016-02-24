require 'spec_helper'

RSpec.describe Sugar, type: :lib do
  subject{ Sugar }

  before(:each){ reset_config }
  after(:each){ reset_config }

  def reset_config
    ENV['SUGAR_HOST'] = 'http://sugar.localhost'
    ENV['SUGAR_USERNAME'] = 'talk'
    ENV['SUGAR_PASSWORD'] = 'password'
    clear_config
  end

  def clear_config
    %w(SUGAR_HOST SUGAR_USERNAME SUGAR_PASSWORD).each{ |key| ENV.delete key }
    Sugar.instance_variable_set :@config, nil
  end

  describe '.config' do
    before(:each){ clear_config }
    let(:yaml_config) do
      {
        'host' => 'yaml_host',
        'username' => 'yaml_username',
        'password' => 'yaml_password'
      }
    end

    def stub_config_file(exists: true)
      double.tap do |stubbed|
        expect(Rails.root).to receive(:join).with('config/sugar.yml').and_return stubbed
        expect(stubbed).to receive(:exist?).and_return exists
      end
    end

    def stub_yaml_config(config_file)
      expect(config_file).to receive :read
      expect(YAML).to receive(:load).and_return 'test' => yaml_config
    end

    def stub_missing_config(config_file)
      expect(config_file).to_not receive :read
      expect(YAML).to_not receive :load
    end

    context 'with YAML configuration' do
      it 'should load config/sugar.yml' do
        stub_yaml_config stub_config_file
        expect(Sugar.config).to eql yaml_config.symbolize_keys
      end
    end

    context 'with ENV configuration' do
      before(:each){ ENV['SUGAR_HOST'] = 'some_host' }

      it 'should not load missing config' do
        stub_missing_config stub_config_file exists: false
        expect(Sugar.config[:host]).to eql 'some_host'
      end

      it 'should prioritize ENV over YAML' do
        stub_yaml_config stub_config_file
        expect(Sugar.config[:host]).to eql 'some_host'
      end
    end

    context 'with no configuration' do
      it 'should not set the host' do
        stub_missing_config stub_config_file exists: false
        expect(Sugar.config[:host]).to be nil
      end
    end
  end

  shared_examples_for 'a sugar request' do
    let(:base_url) do
      "http://#{ Sugar.config[:username] }:#{ Sugar.config[:password] }@sugar.localhost"
    end

    let!(:stubbed_request) do
      stub_request(:post, "#{ base_url }/#{ method }")
        .with body: body.to_json, headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
    end

    it 'should set request headers' do
      Sugar.send method, object
      expect(stubbed_request).to have_been_requested.once
    end
  end

  describe '.notify' do
    it_behaves_like 'a sugar request' do
      let(:method){ :notify }
      let(:object){ create :notification }
      let(:body){ { notifications: [object] } }
    end
  end

  describe '.announce' do
    it_behaves_like 'a sugar request' do
      let(:method){ :announce }
      let(:object){ create :announcement }
      let(:body){ { announcements: [object] } }
    end
  end
end
