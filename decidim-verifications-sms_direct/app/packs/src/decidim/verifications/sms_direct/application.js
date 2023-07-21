$(() => {
  const verificationCodeInput = document.querySelector('#authorization_handler_verification_code');
  const mobilePhoneInput = document.querySelector('#authorization_handler_mobile_phone_number');
  verificationCodeInput.disabled = true;

  const sendSmsCodeButton = document.querySelector('.send-sms-code');
  const sendAuthorizationButton = document.querySelector('.send-authorization');
  
  sendSmsCodeButton.addEventListener('click', function() {
    sendSmsCodeButton.style.display = 'none';
    mobilePhoneInput.disabled = true;
    sendAuthorizationButton.style.display = 'block';

    const mobilePhoneNumberInput = document.querySelector('#authorization_handler_mobile_phone_number');
    let mobilePhoneNumber = mobilePhoneNumberInput.value;

    let request = new XMLHttpRequest();
    var url = `/sms_codes/send_code/${mobilePhoneNumber}`;
    request.open("POST", url, true);
 
    request.onreadystatechange = function () {
      if (this.readyState == 4 && this.status == 200) {
        console.log(this.response)
        verificationCodeInput.disabled = false;
      }
    }
  
    request.send();
  });

  sendAuthorizationButton.addEventListener('click', function() {
    sendAuthorizationButton.disabled = true;

    let verificationCode = verificationCodeInput.value;

    let request = new XMLHttpRequest();
    var url = `/sms_codes/create/${verificationCode}`;
    console.log(url)
    request.open("POST", url, true);

    // request.send();
  })
});
