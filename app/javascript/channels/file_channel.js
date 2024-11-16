import consumer from "./consumer"

consumer.subscriptions.create("FileChannel", {
  connected() {
    console.log("connected")
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log('received!')
    console.log(`.${data.img_mapping}`);
    data.img_mapping.forEach(img => {
      console.log(img)
      var imgElements = document.querySelectorAll(`.${img.style_class}`);
      imgElements.forEach(element => {
        element.src = img.img_url;
      });
    })
    if(data.img_mapping.length > 0){
      notify_for_seconds("画像を更新しました");
    }
    // Called when there's incoming data on the websocket for this channel
  }
});
