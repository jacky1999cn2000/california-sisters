$ = jQuery.noConflict();
$(document).ready(function() {
  //code when page is ready
  console.log('page2 ready');

  // search for products (via calling apex:actionFunction "searchProducts")
  $(".test-btn").click(function() {
    testCall();

  });

});
