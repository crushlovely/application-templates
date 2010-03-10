// rails auth token enabled in jquery
$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

// add javascript request type
jQuery.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")},
});

jQuery.fn.exists = function(){return jQuery(this).length>0;}

$(document).ready(function() {
  $(".clearable").focus(function() {
    var el = $(this);
    if (el.val() == el.attr('title')) {
      el.val('');
    }
  });

  $(".clearable").blur(function() {
    var el = $(this);
    if (el.val() === '') {
      el.val(el.attr('title'));
    }
  });

  $('input[type="hidden"]').css({ 'position' : 'absolute', 'top' : '0', 'left' : '-9999em' });

  $(".pagination a").live("click", function() {
    $(".pagination").html("Loading content...");
    $.get(this.href, null, null, "script");
    return false;
  });
});
