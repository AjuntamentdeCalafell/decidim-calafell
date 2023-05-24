$(() => {
  const sendSmsCodeButton = document.querySelector('.send-sms-code');
  
  sendSmsCodeButton.addEventListener('click', function() {
    const mobilePhoneNumberInput = document.querySelector('#authorization_handler_mobile_phone_number');

    mobilePhoneNumber = mobilePhoneNumberInput.value;

    console.log(mobilePhoneNumber)

    let request = new XMLHttpRequest();
    // TODO: URL WS send code to mobile phone with Parlem
    var url = `/send_code/${mobilePhoneNumber.value}`;
    request.open("GET", url, true);
 
    request.onreadystatechange = function () {
      if (this.readyState == 4 && this.status == 200) {
        console.log(this.responseText);
      }
    }
  
    request.send();
  })
});