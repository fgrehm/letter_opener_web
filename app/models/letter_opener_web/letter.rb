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
      File.read("#{letters_location}/#{id}/#{style}.html")
    end
  end
end
