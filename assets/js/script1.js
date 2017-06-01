$ = jQuery.noConflict();
$(document).ready(function() {
  //code when page is ready
  console.log('page1 ready');

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

  // search for products (via calling apex:actionFunction "searchProducts")
  $(".search-btn").click(function() {
    toastr.success('已经按照指定条件搜索并呈现结果', '通知', {
      positionClass: "toast-bottom-center",
      timeOut: 3000
    });
    let name = $(".product-name").val();
    let major = $(".major-category").val();
    let minor = $(".minor-category").val();
    let brand = $(".brand").val();
    searchProducts(name, major, minor, brand);
    clearSelection();
  });

  // search for products (via calling apex:actionFunction "searchProducts")
  $(".select-btn").click(function() {
    console.log('selectedIdString ', selectedIdString);
    if (typeof selectedIdString == 'undefined' || selectedIdString.trim() == '') {
      toastr.error('请选择至少一个产品', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
    } else {
      selectProducts(selectedIdString);
      clearSelection();
    }
  });
});

//// pagination scripts ////

/*
  selectedIdArray: array to store all selected product Ids
  selectedIdString: product id string converted from selectedIdArray and delimited by comma
  checkedNumber: the number of selected checkboxes on current page
*/
var selectedIdArray = [],
  selectedIdString, checkedNumber;

/*
  count how many checkboxes on the current page (exclude the "select all" checkbox)
*/
function availableCheckboxes() {
  return document.querySelectorAll("input[type='checkbox']").length - 1;
}

/*
  count how many checkboxes were checked on current page (exclude the "select all" checkbox)
*/
function countSelection() {
  checkedNumber = 0;
  document.querySelectorAll("input[type='checkbox']").forEach(function(element) {
    if (element.id != 'selectallsightingscheckbox' && element.checked) {
      checkedNumber++;
    }
  });
}

/*
  toggle all checkboxes on current page when the "select all" checkbox was clicked
*/
function selectAll() {
  countSelection();
  if (checkedNumber == availableCheckboxes()) {
    document.querySelectorAll("input[type='checkbox']").forEach(function(element) {
      element.checked = false;
    });
  } else {
    document.querySelectorAll("input[type='checkbox']").forEach(function(element) {
      element.checked = true;
    });
  }
  saveSelection();
}

/*
  sync selectedIdArray and selectedIdString with checkboxes on the current page
*/
function saveSelection() {
  selectedIdString = selectedIdArray.join(',');

  document.querySelectorAll("input[type='checkbox']").forEach(function(element) {
    if (element.checked) {
      if (element.id != 'selectallsightingscheckbox' && selectedIdString.indexOf(element.id) == -1) {
        selectedIdArray.push(element.id);
        selectedIdString = selectedIdArray.join(',');
      }
    } else {
      // as long as there were unchecked checkbox, uncheck the "select all" checkbox
      document.getElementById('selectallsightingscheckbox').checked = false;

      if (selectedIdString.indexOf(element.id) != -1) {
        for (i = 0; i < selectedIdArray.length; i++) {
          if (selectedIdArray[i] == element.id) {
            selectedIdArray.splice(i, 1);
            selectedIdString = selectedIdArray.join(',');
          }
        }
      }
    }
  });

  // if all checkboxes checked on the page, then check "select all" checkbox
  countSelection();
  if (checkedNumber == availableCheckboxes()) {
    document.getElementById('selectallsightingscheckbox').checked = true;
  }

  console.log('selectedIdArray ', selectedIdArray);
  console.log('selectedIdString ', selectedIdString);
}

/*
  restore checked checkboxes based on selectedIdArray
*/
function restoreSelection() {
  selectedIdString = selectedIdArray.join(',');

  document.querySelectorAll("input[type='checkbox']").forEach(function(element) {
    if (selectedIdString.indexOf(element.id) != -1) {
      element.checked = true;
    }
  });

  // if all checkboxes checked on the page, then check "select all" checkbox
  countSelection();
  if (checkedNumber == availableCheckboxes()) {
    document.getElementById('selectallsightingscheckbox').checked = true;
  }
}

/*
  clear all selections after clicking search button
*/
function clearSelection() {
  selectedIdArray = [];
  selectedIdString = '';
}
