(function(){
    reload_page = function(){
        if( gon.is_loaded){
            console.log("gonをロードした")
            gon.is_loaded = false
            resize_contents();
          }else{
            console.log("gonをロードしてない")
            window.location.reload();
            resize_contents();
          }
    }
})()