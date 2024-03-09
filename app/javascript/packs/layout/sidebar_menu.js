function open_sidebar_menu(){
    $("#sidebar_menu_zone").css("display","block")
    $("#sidebar_notification_zone").css("display","none")
  }
function close_sidebar_menu(){
    $("#sidebar_menu_zone").css("display","none")
}

if(gon.user_signed_in){//ログインしている
    $(".sidebar_menu_margin").height($("body").height())
    $(".open_sidebar_menu_button").on('click', function() {
        if($("#sidebar_menu_zone").css("display") == "block"){
            close_sidebar_menu()
        }else{
            open_sidebar_menu()
        };
    });
    $(".sidebar_menu_margin").on('click', function() {
        close_sidebar_menu()
        resize_contents();
    });
}

