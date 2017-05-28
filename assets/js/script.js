$ = jQuery.noConflict();
$(document).ready(function() {
  //code when page is ready
  console.log('ready');

  // load options values for major-category
  OrderControllerExtension.getMajorCategories(function(result, event) {
    if (event.type == 'exception') {
      console.log(event.message);
    } else {
      console.log('result', result);
      $.each(result, function(label, value) {
        $(".major-category").append('<option value="' + value + '">' + label + '</option>');
      });
    }
  });

  // disable/enable minor-category based on major-category changes
  $(".major-category").change(function() {
    $(".minor-category").find('option').remove().end().append('<option value="novalue">-未选择-</option>').val('novalue');
    $(".brand").find('option').remove().end().append('<option value="novalue">-未选择-</option>').val('novalue');
    if ($(this).val() == 'novalue') {
      $(".minor-category").prop('disabled', true);
      $(".brand").prop('disabled', true);
    } else {
      $(".minor-category").prop('disabled', false);
      OrderControllerExtension.getMinorCategories($(this).val(), function(result, event) {
        if (event.type == 'exception') {
          console.log(event.message);
        } else {
          console.log('result', result);
          $.each(result, function(label, value) {
            $(".minor-category").append('<option value="' + value + '">' + label + '</option>');
          });
        }
      });
    }
  });

  // disable/enable brand based on major-category changes
  $(".minor-category").change(function() {
    $(".brand").find('option').remove().end().append('<option value="novalue">-未选择-</option>').val('novalue');
    if ($(this).val() == 'novalue') {
      $(".brand").prop('disabled', true);
    } else {
      $(".brand").prop('disabled', false);
      OrderControllerExtension.getBrands($(this).val(), function(result, event) {
        if (event.type == 'exception') {
          console.log(event.message);
        } else {
          console.log('result', result);
          $.each(result, function(label, value) {
            $(".brand").append('<option value="' + value + '">' + label + '</option>');
          });
        }
      });
    }
  });

});
