$(function() {
	$("[list='1']").click(function(){
		console.log("clicked");
		var id = this.id;

		console.log(id);

		$.post("/customer/favoritelist", {auction_id: id}, function(result){
			if (result == "1")
			{
				alert("Đã thêm vào danh sách yêu thích");
			}
			if (result == "0")
			{
				alert("Không thêm được vào danh sách yêu thích");
			}
			if (result == "2")
			{
				alert("Xin đăng nhập");
			}
		});
	});
});