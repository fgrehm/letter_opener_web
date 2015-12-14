module LetterOpenerWeb
  module LettersHelper
    def subject(letter)
      text = email_text(letter)
      doc = Nokogiri::HTML(text)
      doc.search('title').text
    end

    private

    def email_text(letter)
      letter.send('rich_text').
        gsub(/"rich\.html"/, "\"#{letter_path(letter)}\"")
    end

    def letter_path(letter)
      LetterOpenerWeb.railtie_routes_url_helpers.letter_path(
        letter.id, style: 'rich')
    end
  end
end
