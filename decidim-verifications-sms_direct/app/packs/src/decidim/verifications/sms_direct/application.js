$(() => {
  const mobilePhoneInput = document.querySelectorAll('#authorization-handler-sms_direct input')[0];
  const verificationCodeInput = document.querySelectorAll('#authorization-handler-sms_direct input')[1];
  verificationCodeInput.disabled = true;

  const sendSmsCodeButton = document.querySelector('.send-sms-code');
  
  sendSmsCodeButton.addEventListener('click', function() {
    sendSmsCodeButton.style.display = 'none';
    mobilePhoneInput.readOnly = true;

    let mobilePhoneNumber = mobilePhoneInput.value;

    let request = new XMLHttpRequest();
    var url = `/verifications_sms_direct/sms_codes?phone_num=${mobilePhoneNumber}`;
    request.open("POST", url, true);
 
    request.onreadystatechange = function () {
      if (this.readyState == 4 && this.status == 200) {
        verificationCodeInput.disabled = false;
      }
    }
  
    request.send();
  });
});
