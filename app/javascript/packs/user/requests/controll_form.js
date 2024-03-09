
$(function(){
	var video_display = document.getElementById("video_display")
  var thumbnail = document.getElementById('thumbnail')
  video_display.onloadedmetadata = function(){
    var canvas = document.querySelector("#canvas");
    canvas.width = video_display.videoWidth;
    canvas.height = video_display.videoHeight;
  };
  video_display.onseeked = function(){
    set_video_image();
  };
  video_display.onloadeddata = function(){
      this.currentTime = 0;
    };
  $("#file_input").change(function(){
    video_display.src = (URL).createObjectURL(this.files[0]);
  });
    //video_displayに再生時間をinput
    video_display.addEventListener('loadeddata', function() {
      $("#file_duration").val(Math.floor(this.duration))
    });
});


var file_form = document.getElementById("file_input");
var file_form_alarm = document.getElementById("file_alarm");
var submit = document.getElementById("submit");
var file_discription = document.getElementById("file_discription");
var youtube_check_box = document.getElementById("youtube_check_box");
var youtube_area = document.getElementById("youtube_area");
var file_field_area = document.getElementById("file_field_area");
var youtube_id_field_area = document.getElementById("youtube_id_field_area");
var youtube_id_field =  document.getElementById("youtube_id_field");
var youtube_video = document.getElementById("youtube_video");
var request_form_field = document.getElementById("request_request_form_id");//なぜかIDがrequest_request_formになる

//youtubeのIDによってuse_youtubeのチェックボックスのチェックを反映させる
youtube_check_box.checked = $("#youtube_id_field").val() != "" && $("#youtube_id_field").val() != null
set_file_form();
set_youtube_form();

//完全に新しい依頼を作成
$("#request_request_form_id").change(function(){
  gon.request_form = ["text","image","video"][this.value - 1];
  console.log(this.value);
  set_file_form();
  check_extension();
  set_youtube_form();
})

//ファイルが変更されたら拡張子を判定
file_form.addEventListener("change", (e) => {check_extension()})
 //submit.disabled = true;
  
youtube_check_box.addEventListener("change", (e) => {
  set_youtube_form();
  });
  
youtube_id_field.onchange = function(){//YouTubeのidのフィールドが変更された場合
  youtube_video.src = `https://www.youtube.com/embed/${youtube_id_field.value}`;
  console.log($("#youtube_video").css("display"));
}

//募集期間をが変更されたら表示させる日時を変更させる
$('.delivery_days_field').change(function() {
  //募集期間を日数から日時に変換
  date = new Date();
  date.setDate(date.getDate() + Number($(this).val()));
  var hour = convert_double_digit(date.getHours());
  var minute = convert_double_digit(date.getMinutes());
  var year = date.getFullYear();
  var month = convert_double_digit(date.getMonth()+1);
  var date = convert_double_digit(date.getDate());
  
  var delivery_date = `${year}/${month}/${date}/ ${hour}:${minute}まで募集`;
  $(".delivery_date").html(delivery_date);
});
