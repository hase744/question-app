(function(){
    xml_request = function(path, page, scroll_element, success_function, parameter){
        let token = document.getElementsByName("csrf-token")[0].content;
        //ウィンドウの一番上までスクロールした時に実行
        //let path = document.getElementsByClassName("user_posts_link")[0].getAttribute("action") + ".json";  // 末尾に[.json]を追加してレスポンスデータのフォーマットをjson形式に指定
        let hashData = {  // 送信するデータをハッシュ形式で指定
        note: {body: "inputText"}  // 入力テキストを送信
        // authenticity_token: token  // セキュリティトークンの送信（ここから送信することも可能）
        };
        let data = JSON.stringify(hashData); // 送信用のjson形式に変換
        // Ajax通信を実行
        let xmlHR = new XMLHttpRequest();  // XMLHttpRequestオブジェクトの作成
        xmlHR.open("GET", `${path}?page=${String(page)}&${parameter}`, true);  // open(HTTPメソッド, URL, 非同期通信[true:default]か同期通信[false]か）
        //xmlHR.responseType = "json";  // レスポンスデータをjson形式と指定
        xmlHR.setRequestHeader("Content-Type", "application/json");  // リクエストヘッダーを追加(HTTP通信でJSONを送る際のルール)
        xmlHR.setRequestHeader("X-CSRF-Token", token);  // リクエストヘッダーを追加（セキュリティトークンの追加）
        xmlHR.send(data);  // sendメソッドでサーバに送信
        xmlHR.onreadystatechange = function() {
            if (xmlHR.readyState === 4) {  // readyStateが4になればデータの読込み完了
                if(xmlHR.status === 200){  // statusが200の場合はリクエストが成功
                    let response = xmlHR.response;  // 受信したjsonデータを変数responseに格納
                    success_function(response, scroll_element);//通信成功後の関数
                } else {  // statusが200以外の場合はリクエストが適切でなかったとしてエラー表示
                  console.log("error");
                }  
            }
        };
    }
})();
