(function(){
    var now = new Date();
    var year = now.getFullYear();
    var month = now.getMonth();
    var date = now.getDate();
    var hour = now.getHours();
    var min = now.getMinutes();
    var sec = now.getSeconds();
    var datetime = `${year}${month}${date}${hour}${min}${sec}`
    //video_displayから画像を取得、canvasに画像を描画、canvasから画像のblobを取得、blobをthumbnailにinput
	var video_display = document.getElementById("video_display")
    var thumbnail = document.getElementById('thumbnail')
	set_video_image = function(){
		var canvas = document.querySelector("#canvas");
	  	var context = canvas.getContext("2d");
	  	context.drawImage(video_display, 0, 0);
	  	var img = new Image();
	  	img.src = canvas.toDataURL("image/jpeg" , 0.8);

      canvas.toBlob(function(blob) {
      var newImg = document.createElement("img"),
          url = URL.createObjectURL(blob);
      
      newImg.onload = function() {
        URL.revokeObjectURL(url);
      };
      
      newImg.src = url;
      //document.body.appendChild(newImg);
    });
      canvas.toBlob(function (blob) {
        blob_original = blob;  //変換されたBlobが渡されるので、blob_originalへセット
        console.log(blob)
        console.log(datetime)
        const pngFile = new File([blob], `${datetime}.png`, {type: "image/png"});
        const dt = new DataTransfer();
        dt.items.add(pngFile);
        thumbnail.files = dt.files;

    }, "image/png", 0.95)
  	}
})()