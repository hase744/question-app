console.log("contact")
function register_callback() {

  $("#contact_cell_area").on(
      "ajax:complete",
      function(event) {
        var res = event.detail[0].response
        $('#message_content_area').html(res)
        console.log("取得成功")
      }
  );

}
$("#contact_cell_area")[0].addEventListener('ajax:error', function(event) {
  // 失敗時の処理
  console.log("受信できません。")
  otify_for_secoundsew_secounds("受信できません。");
});

window.register_callback = register_callback;

register_callback();
