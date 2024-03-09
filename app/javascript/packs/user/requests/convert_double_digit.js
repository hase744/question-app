(function(){
//一桁の数字を二桁に変換 例）1 → 01
    convert_double_digit = function(int){
    if(String(int).length <= 1){
      return `0${int}`;
    }else{
      return int;
    }
  }
})();