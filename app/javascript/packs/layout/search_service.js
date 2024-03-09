var search_max_price = document.querySelector(".search_max_price");
var search_mini_price = document.querySelector(".search_mini_price");
var search_term = document.querySelector(".search_term");
var search_deadline = document.querySelector(".search_deadline");
var search_product_input = document.getElementsByClassName("search_product_input");
var search_product_json = document.getElementsByClassName("search_input");
var product_condition = {"mini_price": null, "max_price": null, "term": null,"deadline": null, "category": []};
(function(){
    search_request_json = document.getElementsByClassName("search_input");
})();
//チェックが入った場所を取得
function input_json(){
    var product_category = [];
    for(let j=0; j<3; j++){
        if(checkbox[j].checked==true){
            console.log(checkbox[j].value);
            product_category.push(checkbox[j].value);
        }
    }
    return product_category;
}

//inputを検出してjsonとしてformに入力
for(let i=0; i<search_product_input.length; i++){
    search_product_input[i].addEventListener("change", function(){
        console.log("検索内容の変更");
        product_condition["max_price"] = search_max_price.value;
        product_condition["mini_price"] = search_mini_price.value;
        product_condition["term"] = search_term.value;
        product_condition["deadline"] = search_deadline.value;
        //product_condition["category"] = input_json();
        console.log(product_condition["category"]);
        console.log(product_condition);
        search_product_json[0].value = JSON.stringify(product_condition);
    })
}
//checkbox内の文字をjsonとしてformに入力
for(let i=0; i<checkbox.length; i++){
    checkbox[i].addEventListener("change", function(){
        console.log("依頼検索カテゴリーの変更");
        product_condition["category"] = input_json();
        console.log(product_condition["category"]);
        console.log(product_condition);
        search_product_json[0].value = JSON.stringify(product_condition);
    })
}