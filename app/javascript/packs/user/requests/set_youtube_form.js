(function(){
    //YouTubeにアップロードした動画を使うが選択されているか
    set_youtube_form = function(){
        var file_field_area = document.getElementById("file_field_area");
        var youtube_id_field_area = document.getElementById("youtube_id_field_area");
        console.log("youtubeチェックボックス" + youtube_check_box.checked);
              //youtube_check_boxがチェックされる、かつ依頼形式が動画
              console.log(gon.request_form)
              if(youtube_check_box.checked && gon.request_form == "video"){
                  file_field_area.style.display = "none";//ファイルに入力不可に
                  youtube_id_field_area.style.display = "block";//youtube_idを入力可能に
                  $("#youtube_video").css("display","block");//youtubeを表示
                  $("#video_display").css("display","none");
                  submit.disabled = false; //送信を可に
              }else if(gon.request_form == "video"){
                  file_field_area.style.display = "block";//ファイルに入力可能に
                  youtube_id_field_area.style.display = "none";//youtube_idを入力可能に
                  $("#youtube_video").css("display","none"); //youtubeを非表示
                  $("#video_display").css("display","block");
                  //submit.disabled = true; //送信を不可に
              }
              console.log("#youtube_video")
              console.log($("#youtube_video").css("display"));
              console.log($("#image_video_field_area").css("display"));
      }
})();