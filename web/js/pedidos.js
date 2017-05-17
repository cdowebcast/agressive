// Onde toda a magia acontece!
$(document).ready(function() {
  // Pedindo
    $(document).on('click','.pedir',function(e){
     //e.preventDefault();
    $.ajax({
			type 		  : 'GET',
			url 		  : '../agressive/php/pedidos.php?id=' + $(this).attr('href')
		}).done(function(data) {

      // $('#lista').fadeOut('slow', function(){
      //     $('#lista').html(data, function(){
      //         $('#lista').fadeIn('slow');
      //     });
      // });

        $("#lista").fadeOut('slow');

        $("#alerta").html(data);

        $("#alerta").addClass("in").delay(5000).queue(function(){
            $(this).removeClass("in").dequeue();
        });

        //$("#alerta").addClass("in");

		}).fail(function(data) {
				$("#lista").html('Erro ao pedir música!');
		});
    return false;
  }); // Fim Pedindo

	// Processa o pedido...
	$('form').submit(function(e) {
		$('.form-group').removeClass('has-error'); // remove a classe de erro
		$('.help-block').remove(); // texto de erro
		var formData = {
			'titulo' : $('#titulo').val()
		};
		$.ajax({
			type 		: 'POST', // define the type of HTTP verb we want to use (POST for our form)
			url 		: '../agressive/php/pedidos.php', // the url where we want to POST
			data 		: formData, // our data object
			dataType 	: 'html', // what type of data do we expect back from the server
			encode 		: true
		})
			// Promise!!!
			.done(function(data) {
        $("#lista").html(data).hide().fadeIn('slow');
			})
			// Deu ruim...
			.fail(function(data) {
			//console.log(data);
			});
		e.preventDefault();
	});
});
