$ = jQuery.noConflict();
$(document).ready(function() {
  //code when page is ready
  console.log('page4 ready');

  // remove order line items (via calling apex:actionFunction "removeOrderLineItems")
  $(".select-btn").click(function() {
    console.log('selectedIdString ', selectedIdString);
    if (typeof selectedIdString == 'undefined' || selectedIdString.trim() == '') {
      toastr.error('请选择至少一个订单项', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
    } else {
      removeOrderLineItems(selectedIdString);
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
