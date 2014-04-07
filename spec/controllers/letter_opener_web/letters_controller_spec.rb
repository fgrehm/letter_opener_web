require 'spec_helper'

describe LetterOpenerWeb::LettersController do
  describe 'GET index' do
    before do
      LetterOpenerWeb::Letter.stub(:search => :all_letters)
      get :index
    end
    it 'should assign all letters to @letters' do
      expect(assigns[:letters]).to eq(:all_letters)
    end
  end

  describe 'GET show' do
    let(:id)         { 'an-id' }
    # TODO: Move these to fixture files
    let(:rich_text)  { "rich text href=\"plain.html\"" }
    let(:plain_text) { "plain text href=\"rich.html\"" }
    let(:letter)     { double(:letter, :rich_text => rich_text, :plain_text => plain_text, :id => id) }

    before do
      LetterOpenerWeb::Letter.stub(:find => letter)
    end

    context 'rich text version' do
      before { get :show, :id => id, :style => 'rich' }

      it "returns letter's rich text contents" do
        expect(response.body).to match(/^rich text/)
      end

      it 'fixes plain text link' do
        expect(response.body).not_to match(/href="plain.html"/)
        expect(response.body).to match(/href="#{Regexp.escape letter_path(:id => letter.id, :style => 'plain')}"/)
      end
    end

    context 'plain text version' do
      before { get :show, :id => id, :style => 'plain' }

      it "returns letter's plain text contents" do
        expect(response.body).to match(/^plain text/)
      end

      it 'fixes rich text link' do
        expect(response.body).not_to match(/href="rich.html"/)
        expect(response.body).to match(/href="#{Regexp.escape letter_path(:id => letter.id, :style => 'rich')}"/)
      end
    end
  end

  describe 'GET attachment' do
    let(:id)              { 'an-id' }
    let(:attachment_path) { "path/to/attachment" }
    let(:file_name)       { 'image.jpg' }
    let(:letter)          { double(:letter, :attachments => { file_name => attachment_path}, :id => id) }

    before do
      LetterOpenerWeb::Letter.stub(:find => letter)
      allow(controller).to receive(:send_file) { controller.render :nothing => true }
    end

    it 'sends the file as an inline attachment' do
      expect(controller).to receive(:send_file).with(attachment_path, :filename => file_name, :disposition => 'inline')
      get :attachment, :id => id, :file => file_name.gsub(/\.\w+/, ''), :format => File.extname(file_name)[1..-1]
      expect(response.status).to eq(200)
    end

    it "throws a 404 if attachment file can't be found" do
      get :attachment, :id => id, :file => 'unknown', :format => 'woot'
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
      expect_any_instance_of(LetterOpenerWeb::Letter).to receive(:delete)
      delete :destroy, :id => id, :use_route => :letter_opener_web
    end
  end
end
