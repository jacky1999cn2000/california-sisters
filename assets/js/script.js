$ = jQuery.noConflict();
$(document).ready(function() {
  //code when page is ready
  console.log('ready');
  OrderControllerExtension.getMajorCategories(handler);

  // $(".createContact").click(function() {
  //
  //       });
});

function handler(result, event) {
  if (event.type == 'exception') {
    console.log(event.message);
  } else {
    console.log('A contact was created with the ID: ', result);
  }
}
