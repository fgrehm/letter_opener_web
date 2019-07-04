# frozen_string_literal: true

require 'rails_helper'

describe LetterOpenerWeb::LettersController do
  routes { LetterOpenerWeb::Engine.routes }

  after(:each) { LetterOpenerWeb.reset! }

  describe 'GET index' do
    before do
      allow(LetterOpenerWeb::Letter).to receive(:search)
      get :index
    end

    it 'searches for all letters' do
      expect(LetterOpenerWeb::Letter).to have_received(:search)
    end

    it 'returns an HTML 200 response' do
      expect(response.status).to eq(200)
      expect(response.content_type).to eq('text/html')
    end
  end

  describe 'GET show' do
    let(:id)         { 'an-id' }
    let(:rich_text)  { 'rich text href="plain.html"' }
    let(:plain_text) { 'plain text href="rich.html"' }
    let(:letter)     { double(:letter, rich_text: rich_text, plain_text: plain_text, id: id) }

    shared_examples 'found letter examples' do |letter_style|
      before(:each) do
        expect(LetterOpenerWeb::Letter).to receive(:find).with(id).and_return(letter)
        expect(letter).to receive(:exists?).and_return(true)
        get :show, params: { id: id, style: letter_style }
      end

      it 'renders an HTML 200 response' do
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('text/html')
      end
    end

    context 'rich text version' do
      include_examples 'found letter examples', 'rich'

      it 'renders the rich text contents' do
        expect(response.body).to match(/^rich text/)
      end

      it 'fixes plain text link' do
        expect(response.body).not_to match(/href="plain.html"/)
        expect(response.body).to match(/href="#{Regexp.escape letter_path(id: id, style: 'plain')}"/)
      end
    end

    context 'plain text version' do
      include_examples 'found letter examples', 'plain'

      it 'renders the plain text contents' do
        expect(response.body).to match(/^plain text/)
      end

      it 'fixes rich text link' do
        expect(response.body).not_to match(/href="rich.html"/)
        expect(response.body).to match(/href="#{Regexp.escape letter_path(id: id, style: 'rich')}"/)
      end
    end

    context 'with wrong parameters' do
      it 'should return 404 when invalid id given' do
        get :show, params: { id: id, style: 'rich' }
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'GET attachment' do
    let(:id)              { 'an-id' }
    let(:attachment_path) { 'path/to/attachment' }
    let(:file_name)       { 'image.jpg' }
    let(:letter)          { double(:letter, attachments: { file_name => attachment_path }, id: id) }

    before do
      allow(LetterOpenerWeb::Letter).to receive(:find).with(id).and_return(letter)
      allow(letter).to receive(:exists?).and_return(true)
    end

    it 'sends the file as an inline attachment' do
      allow(controller).to receive(:send_file) { controller.head :ok }
      get :attachment, params: { id: id, file: file_name.gsub(/\.\w+/, ''), format: File.extname(file_name)[1..-1] }

      expect(response.status).to eq(200)
      expect(controller).to have_received(:send_file)
        .with(attachment_path, filename: file_name, disposition: 'inline')
    end

    it "throws a 404 if attachment file can't be found" do
      get :attachment, params: { id: id, file: 'unknown', format: 'woot' }
      expect(response.status).to eq(404)
    end
  end

  describe 'DELETE clear' do
    it 'removes all letters' do
      expect(LetterOpenerWeb::Letter).to receive(:destroy_all)
      delete :clear
    end

    it 'redirects back to index' do
      delete :clear
      expect(response).to redirect_to(letters_path)
    end
  end

  describe 'DELETE destroy' do
    let(:id) { 'an-id' }

    it 'removes the selected letter' do
      allow_any_instance_of(LetterOpenerWeb::Letter).to receive(:exists?).and_return(true)
      expect_any_instance_of(LetterOpenerWeb::Letter).to receive(:delete)
      delete :destroy, params: { id: id }
    end
  end
end
