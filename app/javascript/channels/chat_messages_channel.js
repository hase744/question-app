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
    var message = data.message;
    var room_cell = $(`.${data.message.class_name}`).first();
    updateMessage({room_cell: room_cell, message: message});
    // Called when there's incoming data on the websocket for this channel
  }
});
