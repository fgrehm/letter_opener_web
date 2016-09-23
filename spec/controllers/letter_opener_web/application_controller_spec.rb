require 'spec_helper'

describe LetterOpenerWeb::ApplicationController do
  controller do
    def index
      render text: :ok
    end
  end

  describe 'authenticate!' do
    let(:user) { 'user' }
    let(:pass) { 'pass' }

    context 'authentication enabled' do
      before do
        LetterOpenerWeb.config do |config|
          config.authentication_enabled = true
          config.authentication_options = { user: user, pass: pass }
        end

        @request.env ||= {}
        @request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Basic.encode_credentials(auth_user, auth_pass)

        get :index
      end

      after do
        LetterOpenerWeb.config do |config|
          config.authentication_enabled = false
          config.authentication_options = nil
        end
      end

      context 'valid auth' do
        let(:auth_user) { user }
        let(:auth_pass) { pass }

        it 'returns ok response' do
          expect(response.body).to match(/ok/)
        end
      end

      context 'invalid auth' do
        let(:auth_user) { 'invalid_user' }
        let(:auth_pass) { 'invalid_pass' }

        it 'fails to get a success response' do
          expect(response.body).to match(/HTTP Basic: Access denied/)
        end
      end
    end

    context 'authentication disabled' do
      before do
        get :index
      end

      it 'returns ok response' do
        expect(response.body).to match(/ok/)
      end
    end
  end
end
