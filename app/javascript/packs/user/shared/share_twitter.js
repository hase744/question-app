var text = gon.tweet_text
console.log(text)
var count = count_text(text)


console.log((count + 22) + "/280")
var share_text = ""
var add_text = "...続きはこちら"
console.log(count_text(add_text))
var count = 22
var to_280_text = ""//280文字目までの文字列

for(var i=0; i<text.length; i++) {
    var character = text.charAt(i)
    
    if(isCJK(character)){
      count +=2;
    } else {
      count++;
    }
    //280より多い
    if(count > 280){
        share_text = to_280_text + add_text
    //280〜280
    }else if(count> (280 - count_text(add_text))){
        share_text += text.charAt(i)
    //280以下
    }else{
        to_280_text += text.charAt(i)
        share_text += text.charAt(i)
    }
}

var shareUrl  = 'https://twitter.com/intent/tweet';
shareUrl += '?text='+encodeURIComponent(share_text);
shareUrl += '&url='+encodeURIComponent(location.href);
console.log(location.href.length)

var shareArea = document.getElementById('twitter_share_area');
var shareLink = `<a href="javascript:void(0);" onclick="window.open('${shareUrl}', 'mywindow4', 'width=400, height=300, menubar=no, toolbar=no, scrollbars=yes');" target="_blank" class="twitter_share"><i class="fab fa-twitter" aria-hidden="true">ツイート</i></a>`;
shareArea.innerHTML = shareLink;

//特定の文字がunicord形式で何文字分なのかを取得
function isCJK(c){ // c: character to check
    var unicode = c.charCodeAt(0);
    if ( (unicode>=0x3000 && unicode<=0x303f)   || // Japanese-style punctuation
         (unicode>=0x3040 && unicode<=0x309f)   || // Hiragana
         (unicode>=0x30a0 && unicode<=0x30ff)   || // Katakana
         (unicode>=0x4e00  && unicode<=0x9fcf)  || // CJK integrated kanji
         (unicode>=0x3400  && unicode<=0x4dbf)  || // CJK integrated kanji ext A
         (unicode>=0xff00 && unicode<=0xff9f)   || // Full-width roman characters and half-width katakana
         (unicode>=0x20000 && unicode<=0x2a6df) || // CJK integrated kanji ext B
         (unicode>=0xf900  && unicode<=0xfadf)  || // CJK compatible kanji
         (unicode>=0x2f800 && unicode<=0x2fa1f) || // CJK compatible kanji
         (unicode>=0xffa0 && unicode<=0xffdc) || // Hangul Half
         (unicode>=0x3131 && unicode<=0xd79d)    // Hangul Full
       )
         return true;

    return false;
  }

//特定の文字列のtwitter形式も文字数を取得
function count_text(text){
    var count = 0
    var length = text.length;
    for(var i=0; i<length; i++) {
        var character = text.charAt(i)
        if(isCJK(character)){
          count +=2;
        } else {
          count++;
        }
    }
    return count
}