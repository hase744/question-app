import consumer from "./consumer"

consumer.subscriptions.create("FileChannel", {
  connected() {
    console.log("connected！")
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log('received!')
    const firstMapping = data.img_mapping[0];
    const normalFileUrl = firstMapping.img_url;
    data.img_mapping.forEach(img => {
      console.log(img)
      var imgElements = document.querySelectorAll(`.${img.style_class}`);
      imgElements.forEach(element => {
        element.src = img.img_url;
        // 親が <a> タグの場合、href を最初のマッピングの URL に更新
        var parentAnchor = element.closest('a');
        if (parentAnchor) {
          parentAnchor.href = normalFileUrl;
        }
      });
    })
    if(data.img_mapping.length > 0){
      notify_for_seconds("画像のアップロードが完了しました");
    }
    // Called when there's incoming data on the websocket for this channel
  }
});
