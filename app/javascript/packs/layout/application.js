const { toConstantDependencyWithWebpackRequire } = require("webpack/lib/ParserHelpers");
(function(){
//数秒間メッセージが表示状態にあるか。
const is_notice_appear = [false]

//inputタグの中が変化
$('input').change(function() {
  let ua = window.navigator.userAgent.toLowerCase(); //OS取得
  var extension = $(this).val().split('.').pop(); //拡張子取得
  if(extension == "heic"){
    alert("拡張子が「.heic」のファイルは保存できないことがあります。");
  }
});

//数秒間noticeにメッセージを表示させる。
const notice_few_secounds = function(message){
  notice_disappear() //通知を非表示
  console.log(is_notice_appear[0])
  function notice_appear(){
    if(is_notice_appear[0] == false){ //メッセージが表示済みの時
      $(".notice_zone").html(message); //メッセージ表示
      $(".notice_zone").toggleClass("notice_zone_appear");//メッセージ表示クラスをなくす
      console.log(`is_notice_appear[0] == ${is_notice_appear[0]}`);
      is_notice_appear[0] = true;
    }
  }
  function notice_disappear(){
    if(is_notice_appear[0] == true){
      $(".notice_zone").toggleClass("notice_zone_appear");
      console.log(`is_notice_appear[0] == ${is_notice_appear[0]}`)
      clearInterval(unnotify);
      is_notice_appear[0] = false
    }
  }
  if($(".notice_zone_appear").length != 0){
    $(".notice_zone").toggleClass("notice_zone_appear");
    console.log("notice_zone_appear")
  }
  
  if(is_notice_appear[0] == false){ //メッセージが表示されている
    notice_appear(); //メッセージを表示
    unnotify = setInterval(notice_disappear,3000);
  }else{//メッセージが表示されていない
    notice_disappear(); //メッセージをお非表示
    notify = setInterval(notice_appear,3000);
  }
}
window.notice_few_secounds = notice_few_secounds

resize_contents = function(){
  //フレームの高さを横幅の9/16にする
  //$(".window_height").height(window.innerHeight)
  $(".16_to_9").width("100%")
  $(".16_to_9").height($(".16_to_9").width()*9/16)

  }
})();

window.addEventListener('resize', resize_contents);
resize = new resize_contents();


//jsのgonが更新されてない時にリロードする処理
//if( gon.is_loaded){
//  console.log("gonをロードした")
//  gon.is_loaded = false
//  resize_contents();
//}else{
//  console.log("gonをロードしてない")
//  window.location.reload();
//  resize_contents();
//}