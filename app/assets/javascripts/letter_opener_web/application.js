//= require letter_opener_web/jquery-1.8.3.min
//= require letter_opener_web/jquery_ujs
//= require letter_opener_web/favcount

function update_favicon(favicon) {
  favicon.set($('.letter-opener tbody tr').length);
}

jQuery(function($) {
  var favicon = new Favcount($('link[rel="icon"]').attr('href'));
  update_favicon(favicon);

  $('.letter-opener').on('click', 'tbody > tr', function() {
    var $this = $(this);
    $('iframe').attr('src', $this.find('a').attr('href'));
    $this.parent().find('.active').removeClass('active');
    $this.addClass('active');
  });

  $('.refresh').click(function(e) {
    e.preventDefault();

    var table = $('.letter-opener');
    table.find('tbody').empty().append('<tr><td colspan="2">Loading...</td></tr>');
    table.load(table.data('letters-path') + ' .letter-opener', function() {
      $('iframe').attr('src', $('.letter-opener tbody a:first-child()').attr('href'));
      update_favicon(favicon);
    });
  });
});
