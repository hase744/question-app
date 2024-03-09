$(".price_field").change(function(){
    var  price_field_log = [gon.price_minimum_number]
    if($(".price_field").val() != null && $(".price_field").val() != ""){
        if($(".price_field").val() <= gon.price_max_number && $(".price_field").val() >= gon.price_minimum_number){
            price_field_log.push($(".price_field").val());
        }else{
            $(".price_field").val(price_field_log[price_field_log.length - 1]);
        }
    }else{
        $(".price_field").val(price_field_log[price_field_log.length - 1]);
    }
})

$(".delivery_days_field").change(function(){
    var  delivery_days_field_log = [gon.delivery_days_minimum_number]
    if($(".delivery_days_field").val() != null && $(".delivery_days_field").val() != ""){
        if($(".delivery_days_field").val() <= gon.delivery_days_max_number && $(".delivery_days_field").val() >= gon.delivery_days_minimum_number){
            delivery_days_field_log.push($(".delivery_days_field").val());
        }else{
            $(".delivery_days_field").val(delivery_days_field_log[delivery_days_field_log.length - 1]);
        }
    }else{
        $(".delivery_days_field").val(delivery_days_field_log[delivery_days_field_log.length - 1]);
    }
})

$(".stock_quantity_field").change(function(){
    var  stock_quantity_field_log = [gon.stock_quantity_minimum_number]
    if($(".stock_quantity_field").val() != null && $(".stock_quantity_field").val() != ""){
        if($(".stock_quantity_field").val() <= gon.stock_quantity_max_number && $(".stock_quantity_field").val() >= gon.stock_quantity_minimum_number){
            stock_quantity_field_log.push($(".stock_quantity_field").val());
        }else{
            console.log("aa")
            $(".stock_quantity_field").val(stock_quantity_field_log[stock_quantity_field_log.length - 1]);
        }
    }else{
        $(".stock_quantity_field").val(stock_quantity_field_log[stock_quantity_field_log.length - 1]);
    }
})


forms_array = ["text","image","video"]
function check_service_request_form(){//依頼形式によって表示される最大の長さのフォームが変化する
    $(".length_field_area").css("display","none")
    console.log("フィールド")
    console.log(forms_array[$("#service_request_form_id").val() -1])
    switch(forms_array[$("#service_request_form_id").val() -1]){
        case "text":
            console.log("文章")
            $(".text_field_area").css("display","block");
            $(".video_field_area").css("display","none");
            break;
        case "image":
            $(".text_field_area").css("display","block");
            $(".video_field_area").css("display","none");
            break;
        case "video":
            $(".text_field_area").css("display","block");
            $(".video_field_area").css("display","block");
            break;
        default:
    }
}

$('#service_request_form_id').change(function(){
    check_service_request_form();
});

check_service_request_form();

$('#service_request_form_id').change(function(){
    check_service_request_form();
});


//追加質問受付日数が0の時、＊追加質問を受付ないと表示させる
$(".transaction_message_days_field").change(function(){
    set_transaction_message_alert(this);
})
  
function set_transaction_message_alert(element){
    console.log(element.value);
    if(Number(element.value) == 0 || String(element.value) == "undefined"){
    console.log(element.value);
    $(".transaction_message_alert").css("display","block");
  }else{
    $(".transaction_message_alert").css("display","none");
  }
}

set_transaction_message_alert($(".transaction_message_days_field")[0]);