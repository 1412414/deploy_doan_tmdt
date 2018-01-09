function Huy_DauGia(id){
  console.log(id);
  var auction_id = $("#auctionid_" + id).val();
  console.log(auction_id);
    $.post("/auction_detail/huydaugia", { MaDetail: id,
      Auction_ID: auction_id
  }, function(result) {
  });
};
