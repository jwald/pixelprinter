$(document).ready(function(){

  // Dropdowns
  $('[data-dropdown]').on('click', function(e){
    var selector = '.' + $(this).attr('class') + ' ' + $(this).attr('data-dropdown');
    $(selector).toggleClass('is-visible');
    e.stopPropagation();
  });
  $(document).on('click', function(){
    $('.dropdown.is-visible').removeClass('is-visible');
  });
  $('.dropdown').on('click', function(e){
    e.stopPropagation();
  });

});