require 'spec_helper'

describe LetterOpenerWeb::Letter do
  let(:location) { File.expand_path('../../../tmp', __FILE__) }

  before(:each) do
    LetterOpener.stub(:letters_location).and_return(location)

    FileUtils.rm_rf(location)
    ['1111_1111', '2222_2222'].each do |folder|
      FileUtils.mkdir_p("#{location}/#{folder}")
      File.open("#{location}/#{folder}/plain.html", 'w') {|f| f.write("Plain text for #{folder}") }
      File.open("#{location}/#{folder}/rich.html", 'w')  {|f| f.write("Rich text for #{folder}") }
    end
  end

  it 'loads rich version' do
    described_class.new(id: '1111_1111').rich_text.should == 'Rich text for 1111_1111'
  end

  it 'loads plain text version' do
    described_class.new(id: '2222_2222').plain_text.should == 'Plain text for 2222_2222'
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
      first_letter.updated_at.should > last_letter.updated_at
    end
  end

  describe '.find' do
    let(:id)     { 'an-id' }
    let(:letter) { described_class.find(id) }

    it 'returns a letter with id set' do
      letter.id.should == id
    end
  end
end
