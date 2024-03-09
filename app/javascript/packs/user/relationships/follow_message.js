console.log("フォロー")
function follow_callback() {
  console.log("フォローバック")
    $("#follow_button_flame").on(
        "ajax:complete",
        function(event) {
        var res = event.detail[0].response;
        $(".follow_button").toggleClass("unfollowed_button");
        
        }
    );
  
  }

  console.log("undefinded")
console.log($("#follow_button_flame").length)
if($("#follow_button_flame").length != 0){
  $("#follow_button_flame")[0].addEventListener('ajax:success', function(event) {
    // 成功時の処理
    console.log(`unfollowed_buttonクラスの数 = ${$(".unfollowed_button").length}`)
    var res = event.detail[0];
    if($(".unfollowed_button").length == 0){
      console.log("フォロー")
      console.log(res["is_followed"]);
      notify_for_seconds("フォローしました。");
    }else{
      console.log("フォローを解除")
      console.log(res["is_followed"]);
      notify_for_seconds("フォローを解除しました。");
    }
  });
  $("#follow_button_flame")[0].addEventListener('ajax:error', function(event) {
    // 失敗時の処理
    console.log("フォローできませんでした。")
    var res = event.detail[0];
    console.log(res["is_followed"]);
    $(".follow_button").toggleClass("unfollowed_button");
    if($(".unfollowed_button").length == 0){
      notify_for_seconds("フォロー解除できませんでした。");
    }else{
      notify_for_seconds("フォローできませんでした。");
    }
  });
}


window.follow_callback = follow_callback;
follow_callback();
console.log($("#follow_button_flame")[0])
