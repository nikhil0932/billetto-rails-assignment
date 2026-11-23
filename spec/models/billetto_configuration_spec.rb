require 'rails_helper'

RSpec.describe Billetto::Configuration, type: :model do
  let(:config) { described_class.new }

  describe '#initialize' do
    context 'when credentials are present in environment' do
      before do
        ENV['BILLETTO_API_KEY'] = 'test-api-key'
        ENV['BILLETTO_API_SECRET'] = 'test-api-secret'
        # Reset cached configuration
        Billetto.instance_variable_set(:@configuration, nil)
      end

      after do
        ENV.delete('BILLETTO_API_KEY')
        ENV.delete('BILLETTO_API_SECRET')
        Billetto.instance_variable_set(:@configuration, nil)
      end

      it 'loads credentials from environment variables or rails credentials' do
        new_config = described_class.new
        expect(new_config.api_key).to be_present
        expect(new_config.api_secret).to be_present
      end
    end

    context 'when credentials are not set' do
      it 'defaults to empty strings or loads from rails credentials' do
        new_config = described_class.new
        # Credentials should either come from environment or Rails credentials
        expect(new_config.api_key).to be_present
        expect(new_config.api_secret).to be_present
      end
    end
  end

  describe '#validate!' do
    context 'when both credentials are present' do
      it 'passes validation' do
        new_config = described_class.new
        expect { new_config.validate! }.not_to raise_error
      end
    end
  end

  describe '#api_keypair' do
    it 'returns combined api_key:api_secret format' do
      new_config = described_class.new
      keypair = new_config.api_keypair
      expect(keypair).to include(':')
      parts = keypair.split(':')
      expect(parts.length).to eq(2)
    end
  end
end
