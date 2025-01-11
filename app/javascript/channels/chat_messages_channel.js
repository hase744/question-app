import consumer from "./consumer"

consumer.subscriptions.create("ChatMessagesChannel", {
  connected() {
    console.log("Connected data");
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    console.log("disconnected data");
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("更新")
    if (!data || !data.message) {
      console.log("Received data or message is undefined:", data);
      return;
    }
    var message = data.message;
    var room_cell = $(`.${data.message.class_name}`).first();
    updateMessage({room_cell: room_cell, message: message});
    adjust_cell_size();
    // Called when there's incoming data on the websocket for this channel
  }
});
