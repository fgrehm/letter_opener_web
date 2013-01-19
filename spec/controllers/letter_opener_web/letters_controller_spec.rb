require 'spec_helper'

describe LetterOpenerWeb::LettersController do
  describe 'GET index' do
    before do
      LetterOpenerWeb::Letter.stub(search: :all_letters)
      get :index
    end
    it { should assign_to(:letters).with(:all_letters) }
  end

  describe 'GET show' do
    let(:id)         { 'an-id' }
    # TODO: Move these to fixture files
    let(:rich_text)  { "rich text href=\"plain.html\" <!DOCTYPE html><a href=\"a-link.html\">Link text</a>" }
    let(:plain_text) { "plain text href=\"rich.html\"" }
    let(:letter)     { mock(:letter, rich_text: rich_text, plain_text: plain_text, id: id) }

    before do
      LetterOpenerWeb::Letter.stub(find: letter)
    end

    context 'rich text version' do
      before { get :show, id: id, style: 'rich' }

      it "returns letter's rich text contents" do
        response.body.should =~ /^rich text/
      end

      # FIXME: Move to letter specs
      it 'fixes plain text link' do
        response.body.should_not =~ /href="plain.html"/
        response.body.should =~ /href="#{Regexp.escape letter_path(id: letter.id, style: 'plain')}"/
      end

      it 'changes links to show up on a new window' do
        response.body.should include("<a href='a-link.html' target='_blank'>Link text</a>")
      end
    end

    context 'plain text version' do
      before { get :show, id: id, style: 'plain' }

      it "returns letter's plain text contents" do
        response.body.should =~ /^plain text/
      end

      # FIXME: Move to letter specs
      it 'fixes rich text link' do
        response.body.should_not =~ /href="rich.html"/
        response.body.should =~ /href="#{Regexp.escape letter_path(id: letter.id, style: 'rich')}"/
      end
    end
  end

  describe 'DELETE clear' do
    it 'removes all letters' do
      LetterOpenerWeb::Letter.should_receive(:destroy_all)
      delete :clear
    end

    it 'redirects back to index' do
      delete :clear
      response.should redirect_to(letters_path)
    end
  end
end
