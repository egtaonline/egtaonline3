$(window).bind("load", function() {
  $('#toggle_editable_link').css("visibility", "visible");
});

$('#toggle_editable_link').click( function( event ) {
  event.preventDefault();
  event.stopPropagation();
  $('.hidden').toggle();
  if (Cookies.get('editable') == '1') {
    Cookies.set('editable', '0');
  }
  else {
    Cookies.set('editable', '1');  
  }
});

$(document).on('ready page:load', function() {
  if (Cookies.get('lastURL') != location.pathname) {
    Cookies.set('editable', '0');
    Cookies.set('scroll', 0);
  }
  if (Cookies.get('editable') == '1') {
    $('.hidden').toggle();
  }
  
  $(document).scrollTop(Cookies.get('scroll'));

  $(window).scroll( function() {
    Cookies.set('scroll', $(document).scrollTop());
  });

  Cookies.set('lastURL', location.pathname);
});
