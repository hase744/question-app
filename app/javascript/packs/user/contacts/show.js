(function(){
var submit_button = document.getElementsByClassName("submit_button");
var text_field = document.getElementsByClassName("text_field");
var message_show_flame = document.getElementsByClassName("message_show_flame");
var message_area = document.getElementsByClassName("message_area");
//var message_area = document.getElementById("message_area")
var page = 2;
console.log("高さ")



//content.options[0].selected = false;
//content.options[3].selected = true;
$(".search_detail").css("display","none")
submit_button[0].addEventListener("click",function(){
    console.log(text_field.value);
})





document.getElementById("message_show_flame").scrollTop = document.getElementById("message_show_flame").scrollHeight;


message_show_flame[0].onscroll = function(){
    if(document.getElementById("message_show_flame").scrollTop == 0) {

        page = Math.ceil(message_show_flame[0].childElementCount/15)+1
        console.log("取得ページ:" + page)
        xml_request("/user/messages/<%=@contact.room_id%>", page, message_show_flame[0], insert_elements, null)
     
        //let token = document.getElementsByName("csrf-token")[0].content;
        ////ウィンドウの一番上までスクロールした時に実行
        ////let url = document.getElementsByClassName("user_posts_link")[0].getAttribute("action") + ".json";  // 末尾に[.json]を追加してレスポンスデータのフォーマットをjson形式に指定
        //let hashData = {  // 送信するデータをハッシュ形式で指定
        //note: {body: "inputText"}  // 入力テキストを送信
        //// authenticity_token: token  // セキュリティトークンの送信（ここから送信することも可能）
        //};
        //let data = JSON.stringify(hashData); // 送信用のjson形式に変換
        //// Ajax通信を実行
        //let xmlHR = new XMLHttpRequest();  // XMLHttpRequestオブジェクトの作成
        //xmlHR.open("GET", "/user/messages/<%=@contact.room_id%>?page=" + String(page), true);  // open(HTTPメソッド, URL, 非同期通信[true:default]か同期通信[false]か）
        //xmlHR.responseType = "html";  // レスポンスデータをjson形式と指定
        //xmlHR.setRequestHeader("Content-Type", "application/json");  // リクエストヘッダーを追加(HTTP通信でJSONを送る際のルール)
        //xmlHR.setRequestHeader("X-CSRF-Token", token);  // リクエストヘッダーを追加（セキュリティトークンの追加）
        //xmlHR.send(data);  // sendメソッドでサーバに送信
//
        //xmlHR.onreadystatechange = function() {
        //    if (xmlHR.readyState === 4) {  // readyStateが4になればデータの読込み完了
        //        if(xmlHR.status === 200){  // statusが200の場合はリクエストが成功
        //            let response = xmlHR.response;  // 受信したjsonデータを変数responseに格納
        //            let json_response = JSON.parse(response);
//
        //            let scroll_height = message_show_flame[0].scrollHeight;
        //            insert_elements(json_response);
//
        //            //スクロール高さを操作
        //            let new_scroll_height = message_show_flame[0].scrollHeight;
        //            message_show_flame[0].scrollTop  = new_scroll_height - scroll_height;
//
//
        //            if(response != []){
        //              page +=1;
        //            }
//
        //        } else {  // statusが200以外の場合はリクエストが適切でなかったとしてエラー表示
        //          console.log("error");
        //        }  
        //    }
        //};

    }
};

var insert_elements = function(json_response, scroll_element){
    let scroll_height = scroll_element.scrollHeight;//スクロールする要素の高さを取得
    for(i=0; i<json_response.length; i++){//respond_jsonの中を一つずつ追加
        if(json_response[i].sender_id == "<%=current_user.id%>"){
            message_show_flame[0].insertAdjacentHTML('afterbegin', create_sender_html(json_response[i]));  // 作成したHTMLをドキュメントに追加
        }else{
            message_show_flame[0].insertAdjacentHTML('afterbegin', create_receiver_html(json_response[i]));  // 作成したHTMLをドキュメントに追加
        }
        //console.log(json_response[i].sender_id);
    }
    let new_scroll_height = scroll_element.scrollHeight;//要素追加後のスクロールする要素の高さを取得
    scroll_element.scrollTop  = new_scroll_height - scroll_height; //適切なスクロール位置に移動
}

function create_sender_html(content) {
    let kidoku = ""
    if(content.is_read ){
        kidoku = "既読・"
    }
    let strHtml =   '<div class="my_contact_show_zone">'+
                        '<div class="my_message_area">'+
                            '<div class="my_message_text">'+ content.body +
                            '</div>'+
                        '</div>'+
                        '<div class="send_time_area">'+
                            '<span class="send_time">'+ kidoku + content.from_now + '</span>'+
                        '</div>'+
                    '</div>';
    return strHtml;  // 子要素を返す（必要なDOMノードが戻り値となる）
};
function create_receiver_html(content) {
    if(content.image.url == null ){
        content.image.url = "/profile.jpg"
    }
    let strHtml =   '<div class="destination_message_area">'+
                        '<div class="image_area">'+
                            '<img class="user_image" src=' + content.image.url +' />'+
                        '</div>'+
                        '<div class="message_text_area">'+
                            '<div class="message_text">'+content.body+'</div>'+
                            '<div class="send_time">'+
                                content.from_now +
                            '</div>'+
                        '</div>'+
                    '</div>';
    return strHtml;  // 子要素を返す（必要なDOMノードが戻り値となる）
};

})();