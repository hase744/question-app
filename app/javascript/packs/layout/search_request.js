var search_max_price = document.querySelector(".search_max_price");
var search_mini_price = document.querySelector(".search_mini_price");
var search_term = document.querySelector(".search_term");
var search_deadline = document.querySelector(".search_deadline");
var search_request_input = document.getElementsByClassName("search_request_input");
var request_condition = {"mini_price": null, "max_price": null, "term": null,"deadline": null, "category": []};
(function(){
    search_request_json = document.getElementsByClassName("search_input");
})();
//チェックが入った場所を取得
function input_json(){
    var request_category = []
    for(let j=0; j<3; j++){
        if(checkbox[j].checked==true){
            console.log(checkbox[j].value);
            request_category.push(checkbox[j].value);
        }
    }
    return request_category;
}

//inputを検出してjsonとしてformに入力
for(let i=0; i<search_request_input.length; i++){
    search_request_input[i].addEventListener("change", function(){
        console.log("検索内容の変更");
        request_condition["max_price"] = search_max_price.value;
        request_condition["mini_price"] = search_mini_price.value;
        request_condition["term"] = search_term.value;
        request_condition["deadline"] = search_deadline.value;
        //request_condition["category"] = input_json();
        console.log(request_condition["category"]);
        console.log(request_condition);
        search_request_json[0].value = JSON.stringify(request_condition);
    })
}
//checkbox内の文字をjsonとしてformに入力
for(let i=0; i<checkbox.length; i++){
    checkbox[i].addEventListener("change", function(){
        console.log("依頼検索カテゴリーの変更");
        request_condition["category"] = input_json();
        console.log(request_condition["category"]);
        console.log(request_condition);
        search_request_json[0].value = JSON.stringify(request_condition);
    })
}