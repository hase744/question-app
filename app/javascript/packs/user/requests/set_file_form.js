(function(){
set_file_form = function(){ //依頼形式によって表示するフィールドを変更させる  console.log("check_request_form")
    var file_field_area = document.getElementById("file_field_area");
    console.log(gon.request_form)
        switch(gon.request_form){
            //動画の拡張子である
            case "video":
              console.log("youtube")
                file_discription.innerHTML = "フォーマットはMOV, mov, wmv, mp4のみです。";
                $("#image_video_field_area").css("display","block");
                $("#image_video_field_area").css("display","block");
                $("#youtube_area").css("display","block");
                $("#video_display").css("display","block");
                //$("#youtube_video").css("display","none");
                break;
            //画像の拡張子である
            case "image":
                file_discription.innerHTML = "フォーマットはjpg,jpeg,pngのみです。";
                console.log("フォーマットはjpg,jpeg,pngのみです。");
                $("#image_video_field_area").css("display","block");
                $("#youtube_area").css("display","none");
                //$("#youtube_video").css("display","none");
                $("#video_display").css("display","none");
                file_field_area.style.display = "block"
                if(youtube_check_box != null){
                  youtube_check_box.checked = false
                }
                break;
            case "text":
                $("#image_video_field_area").css("display","none");
                $("#youtube_area").css("display","none");
                $("#video_display").css("display","none");
                //$("#youtube_video").css("display","none");
                submit.disabled = false;
                if(youtube_check_box != null){
                  youtube_check_box.checked = false
                }
                break;
            default:
            break;
        }
      if(gon.service_exist){
        file_discription.innerHTML = gon.request_file;
        submit.disabled = false;
    }
    set_youtube_form()
}
})()