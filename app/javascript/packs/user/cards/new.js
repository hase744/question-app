$(function(){

    const key = gon.stripe_public_key;
  
    const stripe = Stripe(key);
  
    const elements = stripe.elements();
  
    const style = {
      base: {
        fontSize: '17px'
      }
    };
  
    const cardNumber = elements.create('cardNumber', {style: style});
    cardNumber.mount('#card-number');
    const cardExpiry = elements.create('cardExpiry',{style: style});
    cardExpiry.mount('#card-expiry');
    const cardCvc = elements.create('cardCvc', {style: style, placeholder: ''});
    cardCvc.mount('#card-cvc');
  
    // 項目入力時のエラー処理
    cardNumber.addEventListener('change', function(event) {
      const displayError = document.getElementById('card-errors');
      if (event.error) {
        displayError.textContent = event.error.message;
      } else {
        displayError.textContent = '';
      }
    });
  
    const form = document.getElementById('payment-form');
    form.addEventListener('submit', function(event) {
      event.preventDefault();
  
      // トークンを作成
      stripe.createToken(cardNumber).then(function(result) {
        if (result.error) {
          // カード情報を登録しようとした結果、内容が不適切であればエラーメッセージを表示
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
        } else {
          // カード情報が適切な内容であれば、トークンをフォームに入れてWebサーバに送信
          stripeTokenHandler(result.token);
        }
      });
    });
  
    function stripeTokenHandler(token) {
      // トークンをフォームに内包する
      const form = document.getElementById('payment-form');
      const hiddenInput = document.createElement('input');
      hiddenInput.setAttribute('type', 'hidden');
      hiddenInput.setAttribute('name', 'stripeToken');
      hiddenInput.setAttribute('value', token.id);
      form.appendChild(hiddenInput);
  
      //フォームをWebサーバに送信
      form.submit();
    }
  });