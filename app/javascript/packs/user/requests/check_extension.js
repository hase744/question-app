(function(){
    check_extension = function(){//選択されたファイルの拡張子が依頼形式に沿っているか
        var file_form = document.getElementById("file_input");
        var file_form_alarm = document.getElementById("file_alarm");
        var submit = document.getElementById("submit");
        console.log("check_extension")
        if (window.File) {
            // 指定したファイルの情報を取得
            let inputed_file = file_form.files[0];
            let file_extension = null;
            if(inputed_file != null){
                console.log(inputed_file);
                file_extension = inputed_file.name.split('.').pop();
                console.log(file_extension);
                switch(gon.request_form){
                    //動画の拡張子である
                    case "video":
                        console.log("video");
                        if(!gon.video_extensions.includes(file_extension)){
                            console.log("※フォーマットがただしくありません");
                            file_form_alarm.innerHTML = "※フォーマットがただしくありません";
                            alert("フォーマットがただしくありません");
                            submit.disabled = true;
                        }else{
                            file_form_alarm.innerHTML = null;
                            submit.disabled = false;
                            console.log("submit.disabled = false;");
                        }
                        break;
                    //画像の拡張子である
                    case "image":
                        console.log("image");
                        if(!gon.image_extensions.includes(file_extension)){
                            console.log("※フォーマットがただしくありません");
                            file_form_alarm.innerHTML = "フォーマットがただしくありません";
                            alert("フォーマットがただしくありません");
                            submit.disabled = true;
                        }else{
                            file_form_alarm.innerHTML = null;
                            submit.disabled = false;
                        }
                        break;
                    default:
                        console.log("問題なし");
                        file_form_alarm.innerHTML = null;
                        submit.disabled = false;
                    }
            }
      }
  }
})();