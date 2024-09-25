$(".menu_notification_cells_area").on('scroll', function(){
  var menu_notification_cells_area = document.getElementById("menu_notification_cells_area")
  var menu_notification_cells_flame = document.getElementById("menu_notification_cells_flame")
  var scroll_height = menu_notification_cells_area.scrollTop - menu_notification_cells_flame.scrollTop//スクロールした時の上からの高さ
  var notification_scroll_height = menu_notification_cells_area.clientHeight//要素がスクロールする部分の高さ
  var notification_element_area = menu_notification_cells_flame.scrollHeight//要素全体の高さ

  if(check_scroll(menu_notification_cells_area) && notification_element_area <= scroll_height + notification_scroll_height) {
    menu_notification_cells_area.scrollTop = scroll_height + 10
    page = Math.ceil(menu_notification_cells_flame.childElementCount/15)+1
    console.log("取得ページ:" + page)
    xml_request("/user/notifications/notification_cells", page, menu_notification_cells_flame, insert_nitification_elements, null)
  };

})

var insert_nitification_elements = function(response, scroll_element){
  scroll_element.insertAdjacentHTML('beforeend', response);  // 作成したHTMLをドキュメントに追加
}

var menu_notification = document.getElementsByClassName("menu_notification");
console.log(menu_notification)

function open_notification_sidebar(){
  $("#sidebar_notification_zone").css("display","block")
  $("#sidebar_menu_zone").css("display","none")
}
function close_notification_sidebar(){
  $("#sidebar_notification_zone").css("display","none")
}

//通知cellを開く時だけリンクを有効にする
var disable_notification_link = function(){
  console.log($("#sidebar_notification_zone").css("display") )
  if($("#sidebar_notification_zone").css("display") == "none"){
    $(".notification_image").prop("disabled", false);
  }else{
    $(".notification_image").prop("disabled", true);
  }
}
//メニュー通知が押された
if(gon.user_signed_in){//ログインしている
  $(".menu_notification").on('click', function() {
    $("#menu_notification_cells_area").height($(".body").height() - 50)
    $(".notification_margin").height($("body").height())
    disable_notification_link()
    if($("#sidebar_notification_zone").css("display") == "block"){//#sidebar_notification_zoneがないとき
      close_notification_sidebar()
    }else{
      open_notification_sidebar()
    }
    resize_contents();
  });
  $("#notification_margin").on('click', function() {
    close_notification_sidebar()
  });

}

