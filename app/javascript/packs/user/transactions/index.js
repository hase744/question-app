var all_transaction_small_cell = document.getElementsByClassName("transaction_small_cell")
var transaction_small_cell =  document.getElementById("transaction_small_cell")
var file_area = document.getElementsByClassName("file_area")

var transaction_small_cell_style = window.getComputedStyle(transaction_small_cell);


console.log(parseInt(transaction_small_cell_style.height)/2)
transaction_small_cell.style.height = transaction_small_cell_style.width
resize_content_area()
window.onload = resize_content_area;
window.addEventListener('resize', resize_content_area);

function resize_content_area(){
    for(let i=0; i<all_transaction_small_cell.length; i++){
        //console.log(i)
        all_transaction_small_cell[i].style.height = parseInt(transaction_small_cell_style.width) + "px"
        file_area[i].style.height = parseInt(transaction_small_cell_style.width)/16*9 + "px"
    }
}
