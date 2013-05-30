//= require jquery-1.8.3.min
//= require jquery_ujs
//= require_tree .

jQuery(function($) {
  $('.letter-opener').on('click', 'tr', function() {
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
    });
  });
});
