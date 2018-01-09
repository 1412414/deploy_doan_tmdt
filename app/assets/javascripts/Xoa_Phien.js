function Xoa_Phien_DauGia(id){
  console.log(id);
    $.post("/auction/delete", { MaPhien: id
  }, function(result) {
  });
};
