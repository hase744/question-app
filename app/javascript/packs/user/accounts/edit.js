
var categories = "";
var category_field = document.getElementById("category_field");
var category_display = document.getElementById("category_display");
var category_checkboxes = document.getElementsByClassName("category_checkbox");
var categry_drag_list = document.getElementById("categry_drag_list");

translate = gon.category_e_to_j

document.querySelectorAll('.category_drag_list li').forEach (element => {
	element.ondragstart = function () {
    //ドラッグ操作の drag data に指定したデータと型を設定
		event.dataTransfer.setData('text/plain', event.target.id);
    //データ型は、例えば text/plain 普通のテキストファイル
	};
	element.ondragover = function () {
		event.preventDefault();
		this.style.borderTop = '2px solid blue';
	};
  //ドラッグできる要素に重なったときにボーダートップのCSSを3pxに
	element.ondragleave = function () {
		this.style.borderTop = '';
	};
	element.ondrop = function () {
		event.preventDefault();
		let id = event.dataTransfer.getData('text/plain');
		let element_drag = document.getElementById(id);
		this.parentNode.insertBefore(element_drag, this);
		this.style.borderTop = '';
    sort_category();
	};
});

// 全てチェックボックスを選択した際のイベント取得
for (let i = 0; i < category_checkboxes.length; i++) {
  category_checkboxes[i].addEventListener('change', function() {
    //console.log(category_checkboxes[i].outerHTML + "がチェンジされました");
    sort_category();
  });
}

//入力されたカテゴリーを表示させフォームに入れる
var sort_category = function(){
  //console.log(document.querySelectorAll('.category_drag_list li'))
  categories = []
  category_display.innerHTML = ""
  for (let i = 0; i < category_checkboxes.length; i++) {
      if(category_checkboxes[i].checked){
        //console.log(category_checkboxes[i]);
        //console.log(category_checkboxes[i].id);
        if(categories == ""){
          category_display.innerHTML += translate[category_checkboxes[i].id]
        }else{
          category_display.innerHTML += `, ${translate[category_checkboxes[i].id]}`
        }
        categories.unshift(category_checkboxes[i].id);
      }
  }
  category_field.value = `${categories}`;
}
sort_category();

