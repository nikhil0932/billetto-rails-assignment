require 'rails_helper'

RSpec.describe ClerkAuth, type: :middleware do
  let(:app) { ->(env) { [200, {}, ['OK']] } }
  let(:middleware) { described_class.new(app) }

  describe '#call' do
    it 'calls next middleware without auth' do
      env = Rack::MockRequest.env_for('/')
      status, _, _ = middleware.call(env)
      expect(status).to eq(200)
      expect(env['current_user']).to be_nil
    end

    it 'extracts Bearer token from Authorization header' do
      env = Rack::MockRequest.env_for('/', 'HTTP_AUTHORIZATION' => 'Bearer token')
      status, _, _ = middleware.call(env)
      expect(status).to eq(200)
    end

    it 'extracts session from __session cookie' do
      env = Rack::MockRequest.env_for('/', 'HTTP_COOKIE' => '__session=token')
      status, _, _ = middleware.call(env)
      expect(status).to eq(200)
    end

    it 'calls the next middleware' do
      called = false
      test_app = ->(env) { called = true; [200, {}, ['OK']] }
      test_middleware = described_class.new(test_app)
      env = Rack::MockRequest.env_for('/')
      
      test_middleware.call(env)
      expect(called).to be true
    end
  end
end

    context 'with token verification error' do
      it 'logs error and continues without authentication' do
        allow(Clerk::SDK).to receive(:new).and_raise(StandardError.new('API error'))
        status, headers, body = middleware.call(env)
        expect(status).to eq(200)
        expect(env['current_user']).to be_nil
      end
    end
  end

  describe '#extract_session_token' do
    it 'extracts token from Bearer Authorization header' do
      env = Rack::MockRequest.env_for(
        '/',
        'HTTP_AUTHORIZATION' => 'Bearer my_token_123'
      )
      request = Rack::Request.new(env)
      middleware_instance = described_class.new(app)

      token = middleware_instance.send(:extract_session_token, request)
      expect(token).to eq('my_token_123')
    end

    it 'extracts token from __session cookie' do
      env = Rack::MockRequest.env_for(
        '/',
        'HTTP_COOKIE' => '__session=cookie_token_456'
      )
      request = Rack::Request.new(env)
      middleware_instance = described_class.new(app)

      token = middleware_instance.send(:extract_session_token, request)
      expect(token).to eq('cookie_token_456')
    end

    it 'returns nil when no token present' do
      env = Rack::MockRequest.env_for('/')
      request = Rack::Request.new(env)
      middleware_instance = described_class.new(app)

      token = middleware_instance.send(:extract_session_token, request)
      expect(token).to be_nil
    end

    it 'prefers Authorization header over cookie' do
      env = Rack::MockRequest.env_for(
        '/',
        'HTTP_AUTHORIZATION' => 'Bearer header_token',
        'HTTP_COOKIE' => '__session=cookie_token'
      )
      request = Rack::Request.new(env)
      middleware_instance = described_class.new(app)

      token = middleware_instance.send(:extract_session_token, request)
      expect(token).to eq('header_token')
    end
  end
end
