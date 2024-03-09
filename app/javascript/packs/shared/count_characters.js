$(function() {
    function display_total_characters(element){
        $(".total_characters").text(`（${element.value.length}/${gon.text_max_length}字）`);
        if(gon.text_max_length == undefined){
            //window.location.reload();
        }
        if(element.value.length <= gon.text_max_length/2){
            $(".total_characters").css("color","dimgray");
        }else if(element.value.length <= gon.text_max_length){
            $(".total_characters").css("color","rgb(150, 150, 0)");
        }else{
            $(".total_characters").css("color","red");
        }
    };
    $(".text_area").change(function(){
        display_total_characters(this);
    })
    $(".text_area").keyup(function(event) {
        display_total_characters(this);
    });
    $(".text_area").each(function(index, element){
        display_total_characters(this);
    });
});