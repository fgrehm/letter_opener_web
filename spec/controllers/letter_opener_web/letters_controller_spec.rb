require 'spec_helper'

describe LetterOpenerWeb::LettersController do
  describe 'GET index' do
    before do
      LetterOpenerWeb::Letter.stub(:search => :all_letters)
      get :index
    end
    it 'should assign all letters to @letters' do
      assigns[:letters].should == :all_letters
    end
  end

  describe 'GET show' do
    let(:id)         { 'an-id' }
    # TODO: Move these to fixture files
    let(:rich_text)  { "rich text href=\"plain.html\"" }
    let(:plain_text) { "plain text href=\"rich.html\"" }
    let(:letter)     { mock(:letter, :rich_text => rich_text, :plain_text => plain_text, :id => id) }

    before do
      LetterOpenerWeb::Letter.stub(:find => letter)
    end

    context 'rich text version' do
      before { get :show, :id => id, :style => 'rich' }

      it "returns letter's rich text contents" do
        response.body.should =~ /^rich text/
      end

      it 'fixes plain text link' do
        response.body.should_not =~ /href="plain.html"/
        response.body.should =~ /href="#{Regexp.escape letter_path(:id => letter.id, :style => 'plain')}"/
      end
    end

    context 'plain text version' do
      before { get :show, :id => id, :style => 'plain' }

      it "returns letter's plain text contents" do
        response.body.should =~ /^plain text/
      end

      it 'fixes rich text link' do
        response.body.should_not =~ /href="rich.html"/
        response.body.should =~ /href="#{Regexp.escape letter_path(:id => letter.id, :style => 'rich')}"/
      end
    end
  end

  describe 'GET attachment' do
    let(:id)              { 'an-id' }
    let(:attachment_path) { "path/to/attachment" }
    let(:file_name)       { 'image.jpg' }
    let(:letter)          { mock(:letter, :attachments => { file_name => attachment_path}, :id => id) }

    before do
      LetterOpenerWeb::Letter.stub(:find => letter)
      controller.stub(:send_file) { controller.render :nothing => true }
    end

    it 'sends the file as an inline attachment' do
      controller.should_receive(:send_file).with(attachment_path, :filename => file_name, :disposition => 'inline')
      get :attachment, :id => id, :file => file_name.gsub(/\.\w+/, ''), :format => File.extname(file_name)[1..-1]
      response.status.should == 200
    end

    it "throws a 404 if attachment file can't be found" do
      get :attachment, :id => id, :file => 'unknown', :format => 'woot'
      response.status.should == 404
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
