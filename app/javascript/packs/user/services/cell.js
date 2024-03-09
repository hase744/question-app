
var service_cell_area = document.getElementsByClassName("service_cell_area");
function resize_service_cell(){
    var ideal_width = 240;
    //幅をideal_widthで割ったあまりと商から適切な幅を算出
    var width = service_cell_area[0].parentNode.clientWidth;
    var remainder = width % ideal_width;
    var quotient = Math.floor(width / ideal_width);
    
    for(i=0; i< service_cell_area.length; i++){
        if(remainder >= ideal_width/2){
            service_cell_area[i].style.width = `calc(100% / ${quotient + 1})`;
        }else{
            service_cell_area[i].style.width = `calc(100% / ${quotient})`;
        }
    }
}
if(String(service_cell_area[0]) != "undefined"){
    window.addEventListener('resize', resize_service_cell);
    resize_service_cell();
}
