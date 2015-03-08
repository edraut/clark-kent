// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
  $(document).on('change','[data-report-filter]',function(){
    tmp_obj = $('[data-reports-link]').data('form-data');
    if(!tmp_obj){ tmp_obj = {}}
    tmp_obj[$(this).attr('name')] = $(this).val();
    $('[data-reports-link]').data('form-data',tmp_obj)
  })
})
