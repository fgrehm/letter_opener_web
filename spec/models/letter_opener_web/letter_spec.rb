require 'spec_helper'

describe LetterOpenerWeb::Letter do
  let(:location) { File.expand_path('../../../tmp', __FILE__) }

  def rich_text(mail_id)
    <<-MAIL
Rich text for #{mail_id}
<!DOCTYPE html>
<a href='a-link.html'>
  <img src='an-image.jpg'>
  Link text
</a>
<a href='fooo.html'>Bar</a>
<a href="example.html" class="blank"></a>
MAIL
  end

  before :each do
    described_class.stub(:letters_location).and_return(location)
    described_class.any_instance.stub(:letters_location).and_return(location)

    ['1111_1111', '2222_2222'].each do |folder|
      FileUtils.mkdir_p("#{location}/#{folder}")
      File.open("#{location}/#{folder}/plain.html", 'w') {|f| f.write("Plain text for #{folder}") }
      File.open("#{location}/#{folder}/rich.html", 'w')  {|f| f.write(rich_text(folder)) }
      FileUtils.mkdir_p("#{Rails.root.join('tmp', 'letter_opener')}/#{folder}")
      File.open("#{Rails.root.join('tmp', 'letter_opener')}/#{folder}/rich.html", 'w')  {|f| f.write("Rich text for #{folder}") }
    end
  end

  after :each do
    FileUtils.rm_rf(location)
  end

  describe 'rich text version' do
    let(:id) { '1111_1111' }
    subject { described_class.new(:id => id).rich_text }

    it { should =~ /Rich text for 1111_1111/ }

    it 'changes links to show up on a new window' do
      subject.should include("<a href='a-link.html' target='_blank'>\n  <img src='an-image.jpg'/>\n  Link text\n</a>")
    end

    it 'always rewrites links with a closing tag rather than making them selfclosing' do
      subject.should include("<a class='blank' href='example.html' target='_blank'></a>")
    end
  end

  describe 'plain text version' do
    let(:id) { '2222_2222' }
    subject { described_class.new(:id => id).plain_text }

    it { should =~ /Plain text for 2222_2222/ }
  end

  describe 'default style' do
    let(:id) { '2222_2222' }
    subject { described_class.new(:id => id) }

    it 'returns rich if rich text version is present' do
      subject.default_style.should == 'rich'
    end

    it 'returns plain if rich text version is not present' do
      File.stub(:exists? => false)
      subject.default_style.should == 'plain'
    end
  end

  describe 'attachments' do
    let(:file)            { 'an-image.csv' }
    let(:attachments_dir) { "#{location}/#{id}/attachments" }
    let(:id)              { '1111_1111' }

    subject { described_class.new(:id => id) }

    before do
      FileUtils.mkdir_p(attachments_dir)
      File.open("#{attachments_dir}/#{file}", 'w') { |f| f.puts 'csv,contents' }
    end

    it 'builds a hash with file name as key and full path as value' do
      subject.attachments.should == { file => "#{attachments_dir}/#{file}" }
    end
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

  describe '#delete' do
    let(:id) { '1111_1111' }
    subject { described_class.new(:id => id).delete }

    it'removes the letter with given id' do
      subject
      directories = Dir["#{location}/*"]
      directories.count.should eql(1)
      directories.first.should_not match(id)
    end
  end
end
