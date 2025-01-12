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
    if (!data) {
      console.log("Received data or message is undefined:", data);
      return;
    }
    if(data.message){
      var message = data.message;
      var room_cell = $(`.${data.message.class_name}`).first();
      updateMessage({room_cell: room_cell, message: message});
      adjust_cell_size(data.message);
      mark_as_read([data.message.id]);
    }
    if(data.record_ids){
      data.record_ids.forEach(id => {
        document.querySelector(`.message_cell_${id} .is_read_status`).innerHTML = '既読';
      });
    }
    if(data.creating_state){
      if(data.creating_state.is_creating === true){
        document.querySelector(`.${data.creating_state.room_class_name} .creating_state`).style.display = 'block';
      };
      if(data.creating_state.is_creating === false){
        document.querySelector(`.${data.creating_state.room_class_name} .creating_state`).style.display = 'none';
      };
      $modalBody = $(`.${data.creating_state.room_class_name}`).find('.message_group');
      $modalBody.scrollTop($modalBody[0].scrollHeight);
    }
    // Called when there's incoming data on the websocket for this channel
  }
});
