$(document).ready(function() {
var titulo,artista,musica,capa,mus,art;
var capapadrao = '/img/player/capa.jpg';
var fb = 'https://facebook.com/sharer/sharer.php?u=https://sistematico.github.io/escondendo-categorias-no-wordpress/&t=Escondendo uma categoria da index do seu site no Wordpress';
var tw = 'https://twitter.com/intent/tweet?source=https://sistematico.github.io/escondendo-categorias-no-wordpress/&url=https://sistematico.github.io/escondendo-categorias-no-wordpress/&text=Escondendo uma categoria da index do seu site no Wordpress&via=sistematico';

$.SHOUTcast({
   host : 'localhost',
   port : 8000,
   interval : 5000,
   stats: function(){
     titulo = this.get('songtitle');
     artista = titulo.split('-')[0];
     if(this.onAir()){
       $('#musica').text(titulo);
       pegaCapa(artista);
     } else {
       $('#capa').html('<img src="' + capapadrao + '" />');
       player.setSrc(stream);
       player.play();
     }

   }
}).startStats();

function pegaCapa(artista) {
  art = artista.trim();
      $.ajax({
        url: 'http://itunes.apple.com/search',
        data: {
          term: art,
          media: 'music'
        },
        cache: false,
        dataType: 'jsonp',
        success: function(json) {
          if(json.results.length === 0) {
            $('img[name="nowplayingimage"]').attr('src', '/img/player/capa.jpg');
            return;
          }

          // trust the first result blindly...
          var artworkURL = json.results[0].artworkUrl100;
          $('img[name="nowplayingimage"]').attr('src', artworkURL);
        }
     });
}
//setInterval(pegaCapa(capa1), 5000);

});
