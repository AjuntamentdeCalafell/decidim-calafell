$(() => {
  const mobilePhoneInput = document.querySelectorAll('#sms_direct-form-partial input')[0];
  const verificationCodeInput = document.querySelectorAll('#sms_direct-form-partial input')[1];
  verificationCodeInput.disabled = true;

  const sendSmsCodeButton = document.querySelector('.send-sms-code');
  sendSmsCodeButton.addEventListener('click', function() {
    let mobilePhoneNumber = mobilePhoneInput.value;

    let request = new XMLHttpRequest();
    var url = `/verifications_sms_direct/sms_codes?phone_num=${mobilePhoneNumber}`;
    request.open("POST", url, true);
 
    request.onload = function () {
      if (request.readyState == "4") {//Request finished and response is ready
        if (request.status == "200") {
          sendSmsCodeButton.style.display = 'none';
          mobilePhoneInput.readOnly = true;
          verificationCodeInput.disabled = false;
        } else if (this.status == 400) {
          mobilePhoneInput.readOnly = false
          errorMsg = request.responseText;
          alert(errorMsg);
        } else {
          alert("Problem retrieving data");
        }
      }
    }
    request.send();
  });
});
