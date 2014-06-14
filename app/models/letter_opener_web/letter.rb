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
      new :id => id
    end

    def self.destroy_all
      FileUtils.rm_rf(letters_location)
    end

    def initialize(params)
      @id      = params.fetch(:id)
      @sent_at = params[:sent_at]
    end

    def plain_text
      @plain_text ||= adjust_link_targets read_file(:plain)
    end

    def rich_text
      @rich_text ||= adjust_link_targets read_file(:rich)
    end

    def to_param
      id
    end

    def default_style
      style_exists?('rich') ?
        'rich' :
        'plain'
    end

    def attachments
      @attachments ||= Dir["#{base_dir}/attachments/*"].each_with_object({}) do |file, hash|
        hash[File.basename(file)] = File.expand_path(file)
      end
    end

    def delete
      FileUtils.rm_rf("#{letters_location}/#{self.id}")
    end

    def exists?
      File.exists?(base_dir)
    end

    private

    def base_dir
      "#{letters_location}/#{id}"
    end

    def read_file(style)
      File.read("#{base_dir}/#{style}.html")
    end

    def style_exists?(style)
      File.exists?("#{base_dir}/#{style}.html")
    end

    def adjust_link_targets(contents)
      # We cannot feed the whole file to an XML parser as some mails are
      # "complete" (as in they have the whole <html> structure) and letter_opener
      # prepends some information about the mail being sent, making REXML
      # complain about it
      contents.scan(/<a\s[^>]+>(?:.|\s)*?<\/a>/).each do |link|
        fixed_link = fix_link_html(link)
        xml        = REXML::Document.new(fixed_link).root
        unless xml.attributes['href'] =~ /(plain|rich).html/
          xml.attributes['target'] = '_blank'
          xml.add_text('') unless xml.text
          contents.gsub!(link, xml.to_s)
        end
      end
      contents
    end

    def fix_link_html(link_html)
      # REFACTOR: we need a better way of fixing the link inner html
      link_html.dup.tap do |fixed_link|
        fixed_link.gsub!('<br>', '<br/>')
        fixed_link.scan(/<img(?:[^>]+?)>/).each do |img|
          fixed_img = img.dup
          fixed_img.gsub!(/>$/, '/>') unless img =~ /\/>$/
          fixed_link.gsub!(img, fixed_img)
        end
      end
    end
  end
end
