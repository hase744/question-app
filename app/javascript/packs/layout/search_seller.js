var day_from_last = document.querySelector(".day_from_last");
var seles_record_number = document.querySelector(".seles_record_number");
var search_seller_input = document.getElementsByClassName("search_seller_inpu");
var search_request_json = document.getElementsByClassName("search_input");

var seller_condition = {"day_from_last": null,"seles_record_number": null,"category": []};
(function(){
    search_request_json = document.getElementsByClassName("search_input");
})();
function set_check(i,j){
    console.log(`チェックボックス${i,j}`);
        //親カテゴリーが押されたとき、子カテゴリーにもチェックを入れる
        
}

//チェックが入った場所を取得
function input_json_seller(){
    var seller_category = [];
    for(let j=checkbox.length/2; j<checkbox.length; j++){
        if(checkbox[j].checked==true){
            seller_category.push(checkbox[j].value);
        }
    }
    return seller_category;
}

//inout内の文字をjsonとしてformに入力
for(let i=0; i<search_seller_input.length; i++){
    search_seller_input[i].addEventListener("change", function(){
        console.log("出店検索内容の変更");
        seller_condition["day_from_last"] = day_from_last.value;
        seller_condition["seles_record_number"] = seles_record_number.value;
        //seller_condition["category"] = input_json_request();
        console.log(seller_condition);
        search_request_json[0].value = JSON.stringify(seller_condition);
    })
}
//checkbox内の文字をjsonとしてformに入力
for(let i=checkbox.length/2; i<checkbox.length; i++){
    //checkbox[i].addEventListener("change", function(){
    //    console.log("出店検索カテゴリーの変更");
    //    seller_condition["category"] = input_json_seller();
    //    console.log(seller_condition["category"]);
    //    console.log(seller_condition);
    //    search_request_json[0].value = JSON.stringify(seller_condition);
    //});
}
