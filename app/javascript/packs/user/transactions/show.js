function like_callback() {
    $("#like_button").on(
        "ajax:complete",
        function(event) {
        var res = event.detail[0].response;
        $(".like_button").toggleClass("liked_button");
        if($(".liked_button").length == 1){
            like_count.textContent = parseFloat(like_count.textContent) + 1
          }else{
            like_count.textContent = parseFloat(like_count.textContent) - 1
          }
        }
    );
  
  }


$("#like_button")[0].addEventListener('ajax:success', function(event) {
  // 成功時の処理
  console.log(`liked_buttonクラスの数 = ${$(".liked_button").length}`)
  var res = event.detail[0];
  if($(".liked_button").length == 0){
    console.log("いいね")
    console.log(res["is_liked"]);
    notify_for_seconds("いいねしました。");
    //like_count.textContent = parseFloat(like_count.textContent) + 1
  }else{
    console.log("いいねを解除")
    console.log(res["is_liked"]);
    notify_for_seconds("いいねを解除しました。");
    //like_count.textContent = parseFloat(like_count.textContent) - 1
  }
  
});

$("#like_button")[0].addEventListener('ajax:error', function(event) {
  // 失敗時の処理
  console.log("いいねできませんでした。")
  var res = event.detail[0];
  console.log(res["is_liked"]);
  $(".like_button").toggleClass("liked_button");
  notify_for_seconds("いいねできませんでした。");
  like_count.textContent = parseFloat(like_count.textContent) - 1
});


window.like_callback = like_callback;
like_callback();