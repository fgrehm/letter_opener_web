module LetterOpenerWeb
  class Letter
    attr_reader :id, :updated_at

    def self.search
      letters = Dir.glob("#{LetterOpener.letters_location}/*").map do |folder|
        new :id => File.basename(folder), :updated_at => File.mtime(folder)
      end
      letters.sort_by(&:updated_at).reverse
    end

    def self.find(id)
      new id: id
    end

    def self.destroy_all
      FileUtils.rm_rf(LetterOpener.letters_location)
    end

    def initialize(params)
      @id         = params.fetch(:id)
      @updated_at = params[:updated_at]
    end

    def plain_text
      @plain_text ||= read_file(:plain)
    end

    def rich_text
      @rich_text ||= read_file(:rich)
    end

    private

    def read_file(style)
      File.read("#{LetterOpener.letters_location}/#{id}/#{style}.html")
    end
  end
end
