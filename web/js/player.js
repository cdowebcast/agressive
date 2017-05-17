$(document).ready(function() {

  var stream = 'http://sistematico.github.io/agressive/stream.mp3';

  var player = new MediaElementPlayer('#audio-player', {
    alwaysShowControls: true,
    features: ['volume'],
    audioVolume: 'horizontal',
    audioWidth: 280,
    audioHeight: 70,
    iPadUseNativeControls: false,
    iPhoneUseNativeControls: false,
    AndroidUseNativeControls: false,
    success: function(mediaElement, domObject) {
        },
        error: function() {
        }
  });

  function refresh() {
    player.setSrc(stream);
    player.play();
  }

  $('#logo').on('click',function(e){
    e.preventDefault();
    refresh();
  });

  $('#reload').on('click',function(e){
    refresh();
  });

});
