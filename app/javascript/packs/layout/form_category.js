var checkbox = document.getElementsByClassName("categoory_checkbox");
var category_checkbox_area = document.getElementsByClassName("category_checkbox_area");
var categories_field = document.getElementsByClassName("categories_field");
console.log("フォーム");
//チェックボックスが押された時、子カテゴリーと親カテゴリーのチェックを合わせる
for(let i=0; i<checkbox.length; i++){
    checkbox[i].addEventListener("change", function(){
        console.log("チェックボックス");
        changed_element = checkbox[i]; //変化したチェクボックス
        changed_category = changed_element.classList[0];
        form_count = category_checkbox_area.length //フォームの数
        checkbox_count_per_form = checkbox.length/form_count //チェックボックス数/1フォーム
        n_of_form = Math.floor(i/checkbox_count_per_form); //フォームの番号
        //親カテゴリーが押されたとき、子カテゴリーにもチェックを入れる
        parent_element = changed_element;
        child_caegories = gon.category_tree[changed_category];
        if(gon.parent_categories.includes(changed_category)){//押されたのが親カテゴリーである
            console.log(child_caegories)
            n_of_child_caegories = child_caegories.length;
            //子要素全てのチェックを親要素と同じにする
            for(let j=0; j<n_of_child_caegories; j++){
                child_category_name = child_caegories[j];
                child_element = document.getElementsByClassName(child_category_name)[n_of_form];
                child_element.checked = parent_element.checked;
            } 
        //子カテゴリーが外されたとき、親カテゴリーのチェックも外す
        }else{//押されたのが子カテゴリーである
            parent_category = gon.category_child_to_parent[changed_category];
            parent_element = document.getElementsByClassName(parent_category)[n_of_form];
            parent_element.checked = false; //子要素が変化した時、親要素のチェックは常に外す
        }
        n_of_first_checked_checkbox = (n_of_form)*checkbox_count_per_form;
        //categories_fieldにチェックされたカテゴリーのidを列挙
        categories = []
        for(let j=n_of_first_checked_checkbox; j<n_of_first_checked_checkbox+checkbox_count_per_form; j++){
            if(checkbox[j].checked){
                categories.push(gon.category_e_to_id[checkbox[j].id]);
            }
        }
        categories_field[n_of_form].value = categories;
    })

}