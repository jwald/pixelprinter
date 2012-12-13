$(document).ready(function(){

  // Dropdowns
  $('[data-dropdown]').live('click', function(e){
    var selector = '.' + $(this).attr('class') + ' ' + $(this).attr('data-dropdown');
    $(selector).toggleClass('is-visible');
    e.preventDefault();
    e.stopPropagation();
  });
  $(document).live('click', function(){
    $('.dropdown.is-visible').removeClass('is-visible');
  });
  $('.dropdown').live('click', function(e){
    e.stopPropagation();
  });
  
  // Modals
  $('[data-modal]').live('click', function(e){
    var selector = $(this).attr('data-modal');
    $(selector).removeClass('hidden').addClass('visible');
    e.preventDefault();
    e.stopPropagation();
  });
  $('.close-modal, .modal-bg').live('click', function(){
    $('.modal-bg').removeClass('visible').addClass('hidden');
  });
  
  // Flash Messages
  if($('#global-notification > .notification-message').length) {
    $('#global-notification').addClass('is-visible');
    setTimeout(function(){
      $('#global-notification').removeClass('is-visible');
    }, 3000);
  }
  $('.close-notification').live('click', function(){
    $('#global-notification').removeClass('is-visible');
  });
  
  // Tooltips
  $('[data-tooltip]').bind('mouseenter', function(){
    var width = $(this).outerWidth(),
        text = $(this).attr('data-tooltip');
    $(this).addClass('tooltip is-active').append('<span class="container"><span class="label">' + text + '</span></span>');
  }).bind('mouseleave', function() {
    $(this).removeClass('is-active');
  });
  
  // Dirty forms
  $('[data-formchange]').bind('change keyup', function() {
    var selector = $(this).attr('data-formchange');
    $(selector).addClass('primary');
  });
});