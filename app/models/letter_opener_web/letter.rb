module LetterOpenerWeb
  class Letter
    cattr_accessor :letters_location do
      Rails.root.join("tmp", "letter_opener")
    end

    attr_reader :id, :sent_at

    def self.search
      letters = Dir.glob("#{letters_location}/*").map do |folder|
        new :id => File.basename(folder), :sent_at => File.mtime(folder)
      end
      letters.sort_by(&:sent_at).reverse
    end

    def self.find(id)
      new id: id
    end

    def self.destroy_all
      FileUtils.rm_rf(letters_location)
    end

    def initialize(params)
      @id      = params.fetch(:id)
      @sent_at = params[:sent_at]
    end

    def plain_text
      @plain_text ||= read_file(:plain)
    end

    def rich_text
      @rich_text ||= read_file(:rich)
    end

    def to_param
      id
    end

    private

    def read_file(style)
      contents = File.read("#{letters_location}/#{id}/#{style}.html")

      # We cannot feed the whole file to an XML parser as some mails are
      # "complete" (as in they have the whole <html> structure) and letter_opener
      # prepends some information about the mail being sent, making REXML
      # complain about it
      contents.scan(/<a[^>]+>.+<\/a>/).each do |link|
        xml = REXML::Document.new(link).root
        unless xml.attributes['href'] =~ /(plain|rich).html/
          xml.attributes['target'] = '_blank'
          contents.gsub!(link, xml.to_s)
        end
      end

      contents
    end
  end
end
