var curntTab = window.location.href;
//var curntTab = "http://www.bbc.co.uk/news/world-middle-east-44116340";


document.addEventListener('DOMContentLoaded', function()
  {
    var notifContainer = document.getElementById('choiceConfirmation');
    var yesButton = document.getElementById('yesBtn');
    var noButton = document.getElementById('noBtn');
    var sendButton = document.getElementById('sendBtn')

    sendButton.addEventListener('click', function()
    {
      var url = "ws://42ba53d1.ngrok.io/HelloWorld:5000";
      cnnws = new WebSocket(url);
      cnnws.onopen = function()
      {
        cnnws.send(curntTab);
        console.log('OPENED SOCKET AT' + url);
        cnnws.onmessage() = function(x)
        {
          console.log(x.data);
        }
      }
      cnnws.onclose = function(x)
      {
        notifContainer.MaterialSnackbar.showSnackbar(x);
      }
    });

    yesButton.addEventListener('click', function()
      {
        var yesVal = document.getElementById('emailField').value;
        if (yesVal == "") {
          var data = {message: 'Please enter your email first.'};
          notifContainer.MaterialSnackbar.showSnackbar(data);
        } else {
          var data = {message: 'You have trusted this article!'};
          notifContainer.MaterialSnackbar.showSnackbar(data);
          $('.queryCard > .mdl-card__title').css({'background-image': 'url(../images/cardBgHap.jpg)'});
        }
      });

    noButton.addEventListener('click', function()
      {
        var noVal = document.getElementById('emailField').value;
        if (noVal == "") {
          var data = {message: 'Please enter your email first.'};
          notifContainer.MaterialSnackbar.showSnackbar(data);
        } else {
          var data = {message: 'You do not trust this article!'};
          notifContainer.MaterialSnackbar.showSnackbar(data);
          $('.queryCard > .mdl-card__title').css({'background-image': 'url(../images/cardBgSad.jpg)'});
        }
      });

  }, false);

console.log(curntTab);
