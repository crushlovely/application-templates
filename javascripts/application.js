$.ajaxSetup({ 
  'beforeSend': function(xhr) { xhr.setRequestHeader("Accept", "text/javascript") }
});

$(document).ready(function() {

  $(".clearable").livequery('focus', function() {
    var el = $(this);
    if (el.val() == el.attr('title')) {
      el.val('');
    }
  });

  $(".clearable").livequery('blur', function() {
    var el = $(this);
    if (el.val() === '') {
      el.val(el.attr('title'));
    }
  });

});
