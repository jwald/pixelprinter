$(document).ready(function(){

  // Dropdowns
  $(document).on('click', '[data-dropdown]', function(e){
    var selector = '.' + $(this).attr('class') + ' ' + $(this).attr('data-dropdown');
    $(selector).toggleClass('is-visible');
    e.preventDefault();
    e.stopPropagation();
  });
  $(document).on('click', function(){
    $('.dropdown.is-visible').removeClass('is-visible');
  });
  $(document).on('click', '.dropdown', function(e){
    e.stopPropagation();
  });
  
  // Modals
  $(document).on('click', '[data-modal]', function(e){
    var selector = $(this).attr('data-modal');
    $(selector).removeClass('hidden').addClass('visible');
    e.preventDefault();
    e.stopPropagation();
  });
  $(document).on('click', '.close-modal, .modal-bg', function(){
    $('.modal-bg').removeClass('visible').addClass('hidden');
  });
  
  // Flash Messages
  if($('#global-notification > .notification-message').length) {
    $('#global-notification').addClass('is-visible');
    setTimeout(function(){
      $('#global-notification').removeClass('is-visible');
    }, 3000);
  }
  $(document).on('click', '.close-notification', function(){
    $('#global-notification').removeClass('is-visible');
  });
  
  // Tooltips
  $(document).on('mouseenter', '[data-tooltip]',  function(){
    var width = $(this).outerWidth(),
        text = $(this).attr('data-tooltip');
    $(this).addClass('tooltip is-active').append('<span class="container"><span class="label">' + text + '</span></span>');
  }).on('mouseleave', '[data-tooltip]', function() {
    $(this).removeClass('is-active');
  });
  
  // Dirty forms
  $(document).on('change', '[data-formchange]', function() {
    var selector = $(this).attr('data-formchange');
    $(selector).addClass('primary');
  });
  
  // Select All Tables
  $(document).on('change', 'thead input[type="checkbox"]', function(e) {
    var parent = $(this).parents('table');
    if($(this).prop("checked")) {
      parent.find('input[type="checkbox"]').prop({ checked : true });
    } else {
      parent.find('input[type="checkbox"]').prop({ checked : false });
    }
    e.preventDefault();
  });
  $(document).on('change', 'tbody input[type="checkbox"]', function(e) {
    var parent = $(this).parents('table'),
        checkall = parent.find('thead input[type="checkbox"]');
    if(checkall.length) {
      if(checkall.prop("checked")) {
        checkall.prop({ checked : false });
      } else {
        checkall.prop({ checked : false });
      }
    }
    e.preventDefault();
  });
});