function Update_San_Pham(id) {
  //Lấy product name và mô tả
    var ten = $("#product_name_" + id).val();
    console.log(ten);
var mota =  $("#description_" + id).val();
  console.log(mota);
  $.post("/product/updatesp", { MaSP: id,
  TenSP:ten ,
  MoTa: mota
}, function(result) {

});
};
