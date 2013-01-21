require 'spec_helper'

describe LetterOpenerWeb::Letter do
  let(:location) { File.expand_path('../../../tmp', __FILE__) }

  before :each do
    described_class.stub(:letters_location).and_return(location)
    described_class.any_instance.stub(:letters_location).and_return(location)

    ['1111_1111', '2222_2222'].each do |folder|
      FileUtils.mkdir_p("#{location}/#{folder}")
      File.open("#{location}/#{folder}/plain.html", 'w') {|f| f.write("Plain text for #{folder}") }
      File.open("#{location}/#{folder}/rich.html", 'w')  {|f| f.write("Rich text for #{folder} <!DOCTYPE html><a href='a-link.html'><img src='an-image.jpg'/>Link text</a><a href='fooo.html'>Bar</a>") }
      FileUtils.mkdir_p("#{Rails.root.join('tmp', 'letter_opener')}/#{folder}")
      File.open("#{Rails.root.join('tmp', 'letter_opener')}/#{folder}/rich.html", 'w')  {|f| f.write("Rich text for #{folder}") }
    end
  end

  after :each do
    FileUtils.rm_rf(location)
  end

  describe 'rich text version' do
    let(:id) { '1111_1111' }
    subject { described_class.new(id: id).rich_text }

    it { should =~ /Rich text for 1111_1111/ }

    it 'changes links to show up on a new window' do
      subject.should include("<a href='a-link.html' target='_blank'><img src='an-image.jpg'/>Link text</a>")
    end
  end

  describe 'plain text version' do
    let(:id) { '2222_2222' }
    subject { described_class.new(id: id).plain_text }

    it { should =~ /Plain text for 2222_2222/ }
  end

  describe '.search' do
    let(:search_results) { described_class.search }
    let(:first_letter)   { search_results.first }
    let(:last_letter)    { search_results.last }

    before do
      File.stub(:mtime).with("#{location}/1111_1111").and_return(Date.today - 1.day)
      File.stub(:mtime).with("#{location}/2222_2222").and_return(Date.today)
    end

    it 'returns a list of ordered letters' do
      first_letter.sent_at.should > last_letter.sent_at
    end
  end

  describe '.find' do
    let(:id)     { 'an-id' }
    let(:letter) { described_class.find(id) }

    it 'returns a letter with id set' do
      letter.id.should == id
    end
  end

  describe '.destroy_all' do
    it 'removes all letters' do
      described_class.destroy_all
      Dir["#{location}/**/*"].should be_empty
    end
  end
end
