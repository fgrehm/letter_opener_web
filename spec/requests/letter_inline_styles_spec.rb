# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Letter inline styles', type: :request do
  let(:letters) { Pathname.new(Dir.mktmpdir) }
  let(:id) { '1111_1111' }
  let(:nonce_directives) { %w[script-src style-src] }
  let(:policy) do
    ActionDispatch::ContentSecurityPolicy.new do |p|
      p.default_src :self
      p.script_src :self
      p.style_src :self, 'https://fonts.example.com'
      p.img_src :self
      p.frame_ancestors :none
    end
  end

  before do
    FileUtils.mkdir_p(letters.join(id))
    File.write(letters.join(id, 'rich.html'), '<a href="plain.html">Plain</a><p style="color: red">Hi</p>')
    File.write(letters.join(id, 'plain.html'), '<a href="rich.html">Rich</a> Hi')
    LetterOpenerWeb.configure { |config| config.letters_location = letters }
    env = Rails.application.env_config.merge(
      'action_dispatch.content_security_policy' => policy,
      'action_dispatch.content_security_policy_nonce_generator' => ->(_request) { 'n0nce' },
      'action_dispatch.content_security_policy_nonce_directives' => nonce_directives
    )
    allow(Rails.application).to receive(:env_config).and_return(env)
  end

  after do
    FileUtils.rm_rf(letters)
    LetterOpenerWeb.reset!
  end

  def directive(name)
    response.headers['Content-Security-Policy'].split(';').map(&:strip).find { |part| part.start_with?("#{name} ") }
  end

  context 'with config.letter_inline_styles off (the default)' do
    it 'keeps the host policy' do
      get "/letter_opener_web/#{id}/rich"

      expect(directive('style-src')).to eq("style-src 'self' https://fonts.example.com 'nonce-n0nce'")
      expect(directive('img-src')).to eq("img-src 'self'")
    end
  end

  context 'with config.letter_inline_styles on' do
    before { LetterOpenerWeb.configure { |config| config.letter_inline_styles = true } }

    it 'keeps the host policy on the inbox' do
      get '/letter_opener_web'

      expect(directive('style-src')).to eq("style-src 'self' https://fonts.example.com 'nonce-n0nce'")
    end

    %w[rich plain].each do |style|
      it "keeps the host's sources and adds inline styles and https: images to the #{style} letter, and nothing else" do
        get "/letter_opener_web/#{id}/#{style}"

        expect(directive('style-src')).to eq("style-src 'self' https://fonts.example.com 'unsafe-inline'")
        expect(directive('img-src')).to eq("img-src 'self' https: data:")
        expect(directive('script-src')).to eq("script-src 'self' 'nonce-n0nce'")
        expect(directive('frame-ancestors')).to eq("frame-ancestors 'none'")
        expect(directive('default-src')).to eq("default-src 'self'")
      end
    end

    context 'when the host sets a nonce generator but no nonce directives (Rails then nonces both)' do
      let(:nonce_directives) { nil }

      it 'takes the style nonce off and keeps the script one' do
        get "/letter_opener_web/#{id}/rich"

        expect(directive('style-src')).to eq("style-src 'self' https://fonts.example.com 'unsafe-inline'")
        expect(directive('script-src')).to eq("script-src 'self' 'nonce-n0nce'")
      end
    end

    context 'when the host restricts styles and images through default-src, style-src-attr and hashes' do
      let(:policy) do
        ActionDispatch::ContentSecurityPolicy.new do |p|
          p.default_src :self
          p.script_src :self
          p.style_src_attr :none
          p.style_src_elem :self, "'sha256-abc='"
        end
      end

      it "opens each style directive to inline styles, without its hashes or 'none', and images from default-src" do
        get "/letter_opener_web/#{id}/rich"

        expect(directive('style-src')).to eq("style-src 'self' 'unsafe-inline'")
        expect(directive('style-src-attr')).to eq("style-src-attr 'unsafe-inline'")
        expect(directive('style-src-elem')).to eq("style-src-elem 'self' 'unsafe-inline'")
        expect(directive('img-src')).to eq("img-src 'self' https: data:")
      end
    end

    context "when the host's default-src is 'none'" do
      let(:policy) do
        ActionDispatch::ContentSecurityPolicy.new do |p|
          p.default_src :none
          p.script_src :self
        end
      end

      it "allows the letter's own attachments and drops 'none' from images and styles" do
        get "/letter_opener_web/#{id}/rich"

        expect(directive('img-src')).to eq("img-src 'self' https: data:")
        expect(directive('style-src')).to eq("style-src 'unsafe-inline'")
      end
    end

    context 'when the host already allows some of it, or writes a hash in uppercase' do
      let(:policy) do
        ActionDispatch::ContentSecurityPolicy.new do |p|
          p.script_src :self
          p.style_src :self, :unsafe_inline, "'SHA256-abc='"
          p.img_src :self, :data
        end
      end

      it 'adds each source once and drops the hash' do
        get "/letter_opener_web/#{id}/rich"

        expect(directive('style-src')).to eq("style-src 'self' 'unsafe-inline'")
        expect(directive('img-src')).to eq("img-src 'self' data: https:")
      end
    end

    it "leaves the app's own policy untouched for the next request" do
      get "/letter_opener_web/#{id}/rich"
      get '/letter_opener_web'

      expect(policy.directives['style-src']).to eq(["'self'", 'https://fonts.example.com'])
      expect(directive('style-src')).to eq("style-src 'self' https://fonts.example.com 'nonce-n0nce'")
    end

    it "keeps the host policy for a letter that doesn't exist" do
      get '/letter_opener_web/missing/rich'

      expect(response).to have_http_status(:not_found)
      expect(directive('style-src')).to eq("style-src 'self' https://fonts.example.com 'nonce-n0nce'")
    end

    it 'does nothing for a host app without a policy' do
      allow(Rails.application).to receive(:env_config).and_call_original
      get "/letter_opener_web/#{id}/rich"

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Security-Policy']).to be_nil
    end
  end
end
