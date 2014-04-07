$(function(){

  $('#parameters').on('ajax:success', function(data) {
    if (data != " ") { 
          var data_append = $(data);
      $('#container-offers').html(data);
    }
  });

})