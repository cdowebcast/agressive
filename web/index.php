<?php
  include_once "conf/config.php";
?>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <title>agreSSive</title>
    
    <meta name="description" content="">
    <meta name="keywords" content="">
    <meta name="author" content="">
    <link rel="icon" href="img/favicon.ico">
    <link href="css/mediaelementplayer.min.css" rel="stylesheet" type="text/css">
    <link href="css/agressive.css" rel="stylesheet" type="text/css">
    <!--[if lt IE 9]>
    <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
  </head>
  <body>
    <?php
      ini_set('display_errors', 'On');
      error_reporting(E_ALL);
    ?>

    <div class="container">
      <img id="logo" src="img/agressive.png"/>
      <h1>Agressive</h1>
      <div id="player"><audio id="audio-player" src="<?php echo $shoutcast_url . ':' . $shoutcast_port . '/;'; ?>" controls autoplay preload="none"></audio></div>
      <div class="medialinks">
        <a id="link-github" href="https://github.com/sistematico/agressive" target="_blank"><img src="img/github.svg" alt="GitHub" class="icon-medialink"></a>
      </div>
      <footer>
        <div id="footer-copyright">
          <p>Copyright &copy; 2017 Lucas Saliés Brum</p>
        </div>
      </footer>
    </div>    

    <script src="js/jquery.min.js"></script>
    <script src="js/mediaelement-and-player.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        var player = new MediaElementPlayer('audio-player', {
          pluginPath: "js/",
          features: ['playpause','volume'],
          forceLive: true,
          startVolume: .6,
          audioWidth: 130,
          success: function() {}
        });
      });   
    </script>
  </body>
</html>
