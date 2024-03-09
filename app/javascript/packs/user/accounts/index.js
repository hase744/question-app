window.addEventListener('resize', set_search_detail);
window.addEventListener("resize", function() {
    // searched_user_area要素を取得
    var searchedUserArea = document.getElementById("searched_user_area");
  // ウィンドウの幅を取得
  var width = searchedUserArea.clientWidth;

  // クラス名をリセット
  searchedUserArea.className = "";
  if (width == undefined ){
    window.location.reload();
  }

  // ウィンドウの幅に応じてクラス名を設定
  console.log(width)
  if (width >= 1200) {
    console.log("from1200");
    searchedUserArea.classList.add("from1200");
  } else if (width >= 1000 && width < 1200) {
    searchedUserArea.classList.add("from1000to1200");
    console.log("from1000to1200")
  } else if (width >= 720 && width < 1000) {
    searchedUserArea.classList.add("from720to1000");
    console.log("from720to1000")
  } else if (width >= 500 && width < 720) {
    searchedUserArea.classList.add("from500to720");
    console.log("from500to720")
  } else if (width < 500){
    searchedUserArea.classList.add("to500");
    console.log("to500")
  }
  if (width >= 500) {
    searchedUserArea.classList.add("from500");
}
});

// ページ読み込み時にもリサイズイベントを発火させる
window.dispatchEvent(new Event("resize"));