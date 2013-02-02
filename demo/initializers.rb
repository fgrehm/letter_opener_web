Footnotes.setup do |config|
  config.before do |controller, filter|
    controller.class.name =~ /LetterOpenerWeb/ ?
      filter.notes.clear :
      filter.notes
  end
end

Footnotes.run!
