import * as $ from "jquery";
var user_profile = document.getElementById("user_profile")
console.log(user_profile.style.marginLeft)

var youtube_video_area = document.getElementById("youtube_video_area")
var youtube_video = document.getElementById("youtube_video")
var user_intro_area = document.getElementById("user_intro_area")
var user_description = document.getElementById("user_description")

function resize_youtube_video_area(){
    var width = user_intro_area.clientWidth
    if(window.innerWidth >= 1000){
        //youtube_video.style.height = youtube_video.clientWidth/16*9 + "px"
    }else{
        //console.log(width)
    }
    //user_intro_area.style.minHeight = youtube_video.clientHeight + 10 + "px"
}
function register_callback() {

  $("#request_ajax_update").on(
      "ajax:complete",
      function(event) {
        var res = event.detail[0].response
        $('#updated_by_ajax').html(res)
        console.log(res)
        console.log("register")
      }
  );

}
$("#request_ajax_update")[0].addEventListener('ajax:error', function(event) {
  // 失敗時の処理
  console.log("受信できません。")
  notify_for_seconds("受信できません。");
});


var user_intro_area = document.getElementById("user_intro_area");
var open_text = document.getElementById("open_text");
var description_text = document.getElementById("description_text");

var user_content_link = document.getElementsByClassName("user_content_link")
var user_content_links = Array.from(user_content_link)
var menu_element = document.getElementsByClassName('menu_element');
var user_detail = document.getElementsByClassName("user_detail")[0]
var menu_elements = Array.from(menu_element)
var paths = ["posts","requests","likes","purchases","sales","services","followees"]
var path_to_page = {"posts":5,"requests":5,"likes":10,"purchases":5,"sales":5,"services":20,"followees":5}
var path = "posts"
var former_response
var present_response
var page = 2 //スクロールする時に取得するページ（既に取得済みのページ数 + 1）
var loaded_pages  = []

document.getElementsByClassName("user_content_link")[0].style.color = "blue"
document.getElementsByClassName("menu_element")[0].style.borderBottom = "2px solid blue"

$(".search_detail").css("display","none")
console.log("params")

//自己紹介の詳細を表示させる
open_text.addEventListener('click', (event) => {
    open_text.classList.toggle("open_text");
    open_text.classList.toggle("close_text");
    
    description_text.classList.toggle("opening_text");
    description_text.classList.toggle("closing_text");
    console.log("description")
});

//横スクロールメニューの要素が押された時
user_content_links.forEach(element => element.addEventListener("click", ()=>{
    loaded_pages = []
    for(let i=0; i<user_content_link.length; i++){
        user_content_link[i].style.color = "gray"
        //押された要素の番号を取得
        if(element == user_content_link[i]){
            page = 2 //スクロールしたときに取得するページ
            path =  paths[i] //取得するパス
            var loaded_element_count = user_detail.childElementCount+1 //現在取得済みの要素数
            //繰り上げ（現在取得済みの要素数 / 取得するページの要素数）＋１
            page = Math.ceil(loaded_element_count/path_to_page[path]) + 1
            console.log(page)
        }
    }
    element.style.color = "blue"
    }
));

menu_elements.forEach(element => element.addEventListener("click", ()=>{
    for(let i=0; i<user_content_link.length; i++){
        menu_element[i].style.borderBottom = "none"
    }
    element.style.borderBottom = "2px solid blue"
    }
));

var insert_elements = function(response, scroll_element){
  scroll_element.insertAdjacentHTML('beforeend', response)
}

//スクロールをした判定
$(window).on('scroll', function(){
var user_detail = document.getElementsByClassName("user_detail")[0]
    let token = document.getElementsByName("csrf-token")[0].content;
    var docHeight = $(document).innerHeight(), //ドキュメントの高さ
        windowHeight = $(window).innerHeight(), //ウィンドウの高さ
        pageBottom = docHeight - windowHeight - 0.5; //ドキュメントの高さ - ウィンドウの高さ

        page = Math.ceil(user_detail.childElementCount/path_to_page[path])+1
        console.log("page : "+page)
        //ウィンドウの一番下までスクロールした時 && スクロール位置が変化した
    if(check_scroll() && !loaded_pages.includes(page)) {
        loaded_pages.unshift(page)
        scrollTo(0, pageBottom + 10);
        xml_request(`${path}/${gon.user_id}`, page, user_detail,  insert_elements, null);
    }
});



window.register_callback = register_callback;
window.addEventListener("resize", resize_youtube_video_area)

register_callback();
resize_youtube_video_area()


