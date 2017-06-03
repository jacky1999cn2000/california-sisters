$ = jQuery.noConflict();
$(document).ready(function() {
  //code when page is ready
  console.log('page2 ready');

  // create order line items (via calling apex:actionFunction "createOLIs")
  $(".create-btn").click(function() {

    // populate productInfoList
    let productInfoList = [];

    $('tr[data-id]').each(function() {
      let productInfo = {
        productId: $(this).data('id')
      };

      $(this).find('input').each(function() {
        let value = $(this).val();
        if ($(this).hasClass('quantities')) {
          productInfo.quantities = value;
        } else if ($(this).hasClass('price')) {
          productInfo.price = value;
        } else {
          productInfo.cost = value;
        }
      });

      productInfoList.push(productInfo);
    });
    console.log('productInfoList', productInfoList);

    let error1 = false;
    let error2 = false;
    let error3 = false;
    let error4 = false;
    let error5 = false;

    $.each(productInfoList, function(index, productInfo) {
      console.log('productInfo ', productInfo);
      if (productInfo.quantities.trim() == '' || productInfo.price.trim() == '' || productInfo.cost.trim() == '') {
        error1 = true;
        return false;
      }
      if (!$.isNumeric(productInfo.quantities) || !$.isNumeric(productInfo.price) || !$.isNumeric(productInfo.cost)) {
        error2 = true;
        return false;
      }
      if (Math.floor(productInfo.quantities) != productInfo.quantities) {
        error3 = true;
        return false;
      }
      if (productInfo.quantities <= 0 || productInfo.price <= 0 || productInfo.cost <= 0) {
        error4 = true;
        return false;
      }
      console.log('productInfo.price ', productInfo.price);
      console.log('productInfo.cost ', productInfo.cost);
      if (productInfo.price <= productInfo.cost) {
        error5 = true;
        return false;
      }
    })

    // validation
    if (error1) {
      toastr.error('请确认每个产品都填写了数量、价格、成本', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
      return;
    }

    if (error2) {
      toastr.error('请确认数量、价格、成本均为数值', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
      return;
    }

    if (error3) {
      toastr.error('请确认数量为整数值', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
      return;
    }

    if (error4) {
      toastr.error('请确认数量、价格、成本均大于零', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
      return;
    }

    if (error5) {
      toastr.error('请确认价格大于成本', '错误', {
        positionClass: "toast-bottom-center",
        timeOut: 3000
      });
      return;
    }

    console.log('create order line items');
    createOLIs(JSON.stringify(productInfoList));
  });

});
