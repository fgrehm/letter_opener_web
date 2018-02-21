# frozen_string_literal: true

module LetterOpenerWeb
  class Letter
    attr_reader :id

    def self.letters_location
      @letters_location ||= LetterOpenerWeb.config.letters_location
    end

    def self.letters_location=(directory)
      LetterOpenerWeb.configure { |config| config.letters_location = directory }
      @letters_location = nil
    end

    def self.search
      letters = Dir.glob("#{LetterOpenerWeb.config.letters_location}/*").map do |folder|
        new(id: File.basename(folder))
      end
      letters.sort_by(&:sent_at).reverse
    end

    def self.find(id)
      new(id: id)
    end

    def sent_at
      @sent_at ||= begin
        if LetterOpenerWeb.config.letters_in_time_zone && mtime.respond_to?(:in_time_zone)
          mtime.in_time_zone(Rails.configuration.time_zone)
        else
          mtime
        end
      end
    end

    def self.destroy_all
      FileUtils.rm_rf(LetterOpenerWeb.config.letters_location)
    end

    def initialize(params)
      @id      = params.fetch(:id)
    end

    def plain_text
      @plain_text ||= adjust_contents(read_file(:plain))
    end

    def rich_text
      @rich_text ||= adjust_contents(read_file(:rich))
    end

    def to_param
      id
    end

    def default_style
      style_exists?('rich') ? 'rich' : 'plain'
    end

    def attachments
      @attachments ||= Dir["#{base_dir}/attachments/*"].each_with_object({}) do |file, hash|
        hash[File.basename(file)] = File.expand_path(file)
      end
    end

    def delete
      FileUtils.rm_rf("#{LetterOpenerWeb.config.letters_location}/#{id}")
    end

    def exists?
      File.exist?(base_dir)
    end

    private

    def base_dir
      "#{LetterOpenerWeb.config.letters_location}/#{id}"
    end

    def mtime
      @mtime ||= File.mtime(base_dir) if exists?
    end

    def read_file(style)
      File.read("#{base_dir}/#{style}.html")
    end

    def style_exists?(style)
      File.exist?("#{base_dir}/#{style}.html")
    end

    def adjust_contents(contents)
      adjust_link_targets(adjust_date(contents))
    end

    def adjust_link_targets(contents)
      # We cannot feed the whole file to an XML parser as some mails are
      # "complete" (as in they have the whole <html> structure) and letter_opener
      # prepends some information about the mail being sent, making REXML
      # complain about it
      contents.scan(%r{<a\s[^>]+>(?:.|\s)*?</a>}).each do |link|
        fixed_link = fix_link_html(link)
        xml        = REXML::Document.new(fixed_link).root
        next if xml.attributes['href'] =~ /(plain|rich).html/
        xml.attributes['target'] = '_blank'
        xml.add_text('') unless xml.text
        contents.gsub!(link, xml.to_s)
      end
      contents
    end

    def fix_link_html(link_html)
      # REFACTOR: we need a better way of fixing the link inner html
      link_html.dup.tap do |fixed_link|
        fixed_link.gsub!('<br>', '<br/>')
        fixed_link.scan(/<img(?:[^>]+?)>/).each do |img|
          fixed_img = img.dup
          fixed_img.gsub!(/>$/, '/>') unless img =~ %r{/>$}
          fixed_link.gsub!(img, fixed_img)
        end
      end
    end

    def adjust_date(contents)
      message_headers = contents.scan(%r{<div\sid="message_headers">(?:.|\s)*?</div>}).first
      if message_headers.present?
        xml = REXML::Document.new(message_headers).root
        if xml.elements["dl/dd[4]"].present?
          contents.gsub!(xml.elements["dl/dd[4]"].to_s, "<dd>#{sent_at}</dd>")
        end
      end
      contents
    end
  end
end
