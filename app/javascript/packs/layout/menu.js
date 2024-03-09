
console.log("メニュー");
//var head = document.getElementsByClassName('menu_head');
var open_search = document.getElementsByClassName('open_search');
var close_search = document.getElementsByClassName('close_search');
var opening_search = document.getElementsByClassName('opening_search');
var closing_search = document.getElementsByClassName('closing_search');
var search = document.getElementsByClassName('search');

var request_search_zone = document.getElementById('request_search_zone');
var seller_search_zone = document.getElementById('seller_search_zone');
var service_search_zone = document.getElementById('service_search_zone');
var category_menu_area = document.getElementById("category_menu_area");

var buttonClose = document.getElementsByClassName('modalClose')[0];
var selector = document.getElementById("form_select")
var menu_bar = document.getElementsByClassName("menu_bar")

var sidebar_menu_margin = document.getElementById("sidebar_menu_margin");
var sidebar_menu_zone = document.getElementById("sidebar_menu_zone");

var sidebar_notification_zone = document.getElementById("sidebar_notification_zone");
var notification_margin = document.getElementById("notification_margin");

var search_request_input = document.querySelector(".search-request-input");
var search_detail_margin = document.getElementById("search_detail_margin");

var price_field_area = document.getElementById("price_field_area");
var period_field_area = document.getElementById("period_field_area");
var suggestion_deadline_field_area = document.getElementById("suggestion_deadline_field_area");
var elapsed_days_field_area = document.getElementById("elapsed_days_field_area");
var sales_results_field_area = document.getElementById("sales_results_field_area");
var category_field_area = document.getElementById("category_field_area");
var menu_search_form = document.getElementsByClassName("menu_search_form");

//var form = document.getElementById("form")
//sidebar_menu_zoneの開閉、search_detail、windowの幅からコンテンツを適切な幅に変更
(function(){
    a = "global variable"

})();
(function(){
})();
(function(){
    
    search_detail = document.getElementsByClassName("search_detail");
    open_sidebar_menu_button = document.getElementsByClassName("open_sidebar_menu_button");
    menu_notification = document.getElementsByClassName("menu_notification");
    
    set_search_detail = function(){
        //検索するコンテンツの種類によって詳細検索タブが変更
        console.log("windowの幅が変更");
        $(".request_search_field").css("display","none");
        $(".service_search_field").css("display","none");
        $(".seller_search_field").css("display","none");
        $(".transaction_search_field").css("display","none");
        $(`.${selector.options[selector.selectedIndex].value}_search_field`).css("display","block");
        //検索が依頼 && 幅が1000px以下 && search_bar が閉じてる　時のみrequest_detailを閉じる
        if(window.innerWidth < 1000 && $(".closing_search").length > 0){
            console.log("幅が1000px以下 && search_barが閉じてる");
            request_search_zone.style.display = 'none';
            category_menu_area.style.display = 'none';
            seller_search_zone.style.display = 'none';
            service_search_zone.style.display = 'none';
            $(".menu_search_form").css("display","none")
        }
        console.log($(".opening_search").length)
        if(window.innerWidth < 1000 && $(".opening_search").length > 0){
            $(".menu_search_form").css("display","inline-block")
        }
        change_search_path();
    }
    open_search[0].addEventListener("click", function(){
        //検索バーを開く
        console.log("open");
        for(var i = 0; i < search.length; i++){
            search[i].classList.toggle('closing_search');
            search[i].classList.toggle('opening_search');
        }
        menu_bar[0].classList.toggle("closing_menu_bar")
        menu_bar[0].classList.toggle("opening_menu_bar")
        console.log(menu_bar[0])
        set_search_detail();
    });
    close_search[0].addEventListener("click", function(){
        //検索バーを閉じる
        console.log("close");
        for(var i = 0; i < search.length; i++){
            search[i].classList.toggle('closing_search');
            search[i].classList.toggle('opening_search');
        }
        menu_bar[0].classList.toggle("closing_menu_bar")
        menu_bar[0].classList.toggle("opening_menu_bar")
        set_search_detail();
    });
    //検索コンテンツの種類が変更されたとき
    selector.addEventListener('change', (event) => {
        console.log("検索内容変更")
        change_search_path();
        set_search_detail();
        //search_request_json[0].value = "";
    });
    
    //デフォルトの検索対象をpathごとに変更
    change_search_by_path = function(){
        if(location.pathname.indexOf("requests") >= 0){
            selector.options[1].selected = true
            //set_search_detail();
        }else if(location.pathname.indexOf("services") >= 0){
            selector.options[2].selected = true
            //set_search_detail();
        }else if(location.pathname.indexOf("accounts") >= 0){
            selector.options[3].selected = true
            //set_search_detail();
        }else if(location.pathname.indexOf("contacts") >= 0){
            selector.options[3].selected = true
            //set_search_detail();
        }else if(location.pathname.indexOf("transactions") >= 0){
            selector.options[0].selected = true
            //set_search_detail();
        }else{
            selector.options[3].selected = true
        }
        category_menu_area.style.display = 'none';
        request_search_zone.style.display = 'none';
        category_menu_area.style.display = 'none';
        seller_search_zone.style.display = 'none';
        service_search_zone.style.display = 'none';
    }

    change_search_path = function(){
        //検索先のurlを検索内容ごとに変更
        let action = menu_search_form[0].action
        action = action.substring(0, action.indexOf("user/")) + "user/" + selector.options[selector.selectedIndex].value + "s"
        if(selector.options[selector.selectedIndex].value == "seller"){
            action = action.substring(0, action.indexOf("user/")) + "user/" + "account" + "s"
        }
        menu_search_form[0].action = action
        console.log("検索先" + action)
    }
    
    change_search_by_path()
    console.log(location.pathname)

    //ログインしているかどうか
    if(open_sidebar_menu_button[0] != null){
    }
    change_search_path();
})();
