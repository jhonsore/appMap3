(function($) {
    function App(){
		"use strict";

		this.statusMoveMapUser = false;
	}
	
	App.prototype.constructor = App;
	
	App.prototype.init = function(){

		$.app.initLogin();
		$.app.initHome();
		$.app.initMapListeners();

	}

	/*
	 *
	 * listeners para o mapa
	 *
	 * */
	App.prototype.initMapListeners = function(){

		//--------
		//listener para quando a rota for criada
		$.appMap.addListener($.appMap.ON_SOLVED, function(__arg__){

			$("#trip-data").append("<p>Tempo estimado: "+$.appMap.getTotalDurationTrip()+"</p>");
			$("#trip-data").append("<p>Distância: "+$.appMap.getTotalDistanceTrip()+"</p>");
			$("#bt-menu").show();

		});

		//listener para quando mudar a rota do usuário
		$.appMapUser.addListener($.appMapUser.ON_SOLVED, function(__arg__){

			$("#trip-data-move").empty();
			$("#trip-data-move").append("<p>Tempo estimado: "+$.appMapUser.getTotalDurationTrip()+"</p>");
			$("#trip-data-move").append("<p>Distância: "+$.appMapUser.getTotalDistanceTrip()+"</p>");

			myApp.closeModal();

			if(deviceOS) {

				if (deviceOS == 'ios') {

					setTimeout(function () {
						calliOSFunction("startUpdateposUser", [],function(__result__){

						}, onErrorCallingNativeFunction);
					},500);

				}

			}

		});

		$("#bt-menu").click(function(){

			if($(this).hasClass('on')){
				$(this).removeClass('on');
				$("#box-menu").removeClass('on');
			}else{
				$(this).addClass('on');
				$("#box-menu").addClass('on');
			}

			return false;
		});

		$("#button-pan").click(function(){

			if( $(this).hasClass("on") ){
				$.app.turnMoveMapUserOff();
			}else{
				$.app.turnMoveMapUserOn();
			}

			return false;
		});

	}

	/*
	 *
	 * move mapa para o centro do mapa ao atualizar a posição do usuário
	 *
	 * */
	App.prototype.turnMoveMapUserOn = function(){

		var _button = $("#button-pan");
		_button.addClass('on');
		$.app.statusMoveMapUser = true;
		$.appMapUser.centerMapOnMarkerUser();

	}

	/*
	 *
	 * para de mover o mapa para o centro do mapa ao atualizar a posição do usuário
	 *
	 * */
	App.prototype.turnMoveMapUserOff = function(){

		var _button = $("#button-pan");
		_button.removeClass('on');
		$.app.statusMoveMapUser = false;

	}

	/*
	*
	* LOGIN
	*
	* */
	App.prototype.initLogin = function(){
		$("#js-login").click(function(){
			$.app.makeLogin();
			return false;
		});
	}

	/*
	 *
	 * responsável pelo login
	 *
	 * */
	App.prototype.makeLogin = function(){

		mainView.router.load({pageName: 'home'});

		return false;
	}

	/*
	 *
	 * HOME
	 *
	 * */
	App.prototype.initHome = function(){

		$(".js-list-item").click(function(){
			$.app.openDescricaoEntrega();
			return false;
		});
		$("#bt-efetuar-entrega").click(function(){
			$.app.getUserPositionFromDevice();
			return false;
		});

	}

	/*
	 *
	 * abre overlay com a descrição da entrega
	 *
	 * */
	App.prototype.openDescricaoEntrega = function(){

		myApp.popup('.popup-entrega');

	}

	/*
	 *
	 * pega a posição do usuário para iniciar o mapa com as entregas
	 *
	 * */
	var _timerFindeUser;//timer para encontrar o usuario
 	App.prototype.getUserPositionFromDevice = function(){

		//checa se estamos rodando o app em um aparelho mobile
		if(deviceOS){

			myApp.showPreloader('Localizando usuário');

			//
			if(deviceOS == 'ios'){

				//máximo tempo para timeout da procura pela posição do usuário
				var MAX_TIMER_WAIT = 1000;
				//contador para encontrar a posição do usuário
				var countTimer = 0;

				//rola um setinterval para encontrar a posição do usuário
				// caso countTimer exceda o MAX_TIMER_WAIT gera um alert
				//para o usuário dizendo que não foi possível encontrar sua localização
				//então, ele pode fechar a mensagem ou tentar novamente
				_timerFindeUser = setInterval(function(){
					if(countTimer < MAX_TIMER_WAIT ){
						calliOSFunction("getPositionUser", [],function(__result__){

							var _json = JSON.parse(__result__);

							if(!$.isEmptyObject(_json.result)){

								myApp.hidePreloader();
								countTimer = 0;
								clearInterval(_timerFindeUser);
								_timerFindeUser = null;

								if(_json.result.error){
									callErroLocalizacaoUser({error:_json.result.error});
								}else{
									myApp.closeModal('.popup-entrega');
									setTimeout(function () {
										$.app.efetuarEntrega({positionUser : _json.result });
									},300);

								}

							}

						}, onErrorCallingNativeFunction);
					}else{
						myApp.hidePreloader();
						callErroLocalizacaoUser({error:"Ocorreu um erro ao localizar o usuário (1001)"});

						countTimer = 0;
						clearInterval(_timerFindeUser);
						_timerFindeUser = null;
					}
					countTimer++;
				},1);
			}

		}else{
			//estamos no desktop, tão passanos um valor na mão para testes no navegador
			myApp.closeModal('.popup-entrega');
			$.app.efetuarEntrega({positionUser : {latitude: "-20.332791", longitude: "-40.394722"}});
		}

		function callErroLocalizacaoUser (__args__){
			myApp.modal({
				title:  'Atenção',
				text: __args__.error,
				buttons: [
					{
						text: 'Fechar',
						onClick: function() {

						}
					},
					{
						text: 'Repetir',
						onClick: function() {
							$.app.getUserPositionFromDevice();
						}
					}
				]
			})
		}

	}

	/*
	 *
	 * efetua a entrega
	 *
	 * */
	App.prototype.efetuarEntrega = function(__args__){

		myApp.modal({
			title:  'Aguarde',
			text: 'Traçando rota'
		});

		$.app.callMapa();

		/*var data = {locais :[
			"-20.316746, -40.319567",
			"-20.307926, -40.316646",
			"-20.302345, -40.314406",
			"-20.299350, -40.310998",
			"-20.301941, -40.304396",
			"-20.314593, -40.302100",
			"-20.299888, -40.297005",
			"-20.284004, -40.301167",
			"-20.274412, -40.297184",
			"-20.255866, -40.296969",
		]};

		var _d = $.extend(data,__args__);
		$.app.callMapWithPositions(_d);*/

		$.ajax({
			type:"GET",
			url:configuration.HOST+configuration.getPositions,
			processData: false,
			dataType : "json",
			success : function(data){
				if(data.status)
				{
					var _d = $.extend(data,__args__);
					$.app.callMapWithPositions(_d);
				}else{
					myApp.alert('Ocorreu um erro, tente novamente (1001)', 'Atenção!');
				}
			},
			error : function (req, status, err)
			{
				myApp.alert(JSON.stringify(req)+" / "+ status+" / "+ err, 'Atenção!');
			},
			complete: function ()
			{

			}
		});

		//--------------------------------

	}

	App.prototype.callMapWithPositions = function (__args__){

		//inicia o mapa com os marcadores já definidos
		/*
		 [
		 "-20.316746, -40.319567",
		 "-20.307926, -40.316646",
		 "-20.302345, -40.314406",
		 "-20.299350, -40.310998",
		 "-20.301941, -40.304396",
		 "-20.314593, -40.302100",
		 "-20.299888, -40.297005",
		 "-20.284004, -40.301167",
		 "-20.274412, -40.297184",
		 "-20.255866, -40.296969",
		 ];
		* */
		var _array = __args__.locais;

		//var _t = $.parseJSON( posicaoInicialUser );

		//posição inicial do entregador
		var _posUser = __args__.positionUser.latitude+", "+__args__.positionUser.longitude;
		//var _posUser = "-20.332791, -40.394722";

		//adicionamos sua posição no início do array
		_array.unshift(_posUser);

		var _obj = {
			direction: 1,
			arrayLocations:_array
		};

		if(!_posUser){
			myApp.alert("Posição do usuário não encontrada","Atenção");
		}else{
			$(".box-initial").remove();
			$.appMap.initMapWithLocations(_obj);
		}

		statusBeginDelivery = true;
	}

	/*
	 *
	 * abrir mapa
	 *
	 * */
	App.prototype.callMapa = function(){

		mainView.router.load({pageName: 'mapa'});
		$.appMap.init();

		$.appMap.gMaps.addListener('drag', function() {
			if($.app.statusMoveMapUser){
				$.app.turnMoveMapUserOff();
			}
		});

		$("#bt-back-mapa").unbind().click(function(){
			$.app.closeMapa();
			return false;
		});
	}

	/*
	 *
	 * fechar mapa
	 *
	 * */
	App.prototype.closeMapa = function(){
		$.appMap.destroy();
		mainView.router.back();
	}

	/*
	 *
	 * call move marker user
	 *
	 * */
	App.prototype.moveMapUser = function(__args__){

		var _t = $.parseJSON( __args__ );
		$.appMapUser.moveMarkerUser({
			lat: _t.latitude,
			long: _t.longitude,
			moveMap: $.app.statusMoveMapUser
		});

	}

    //---------------------------------------
    $.app = new App();

    jQuery(document).ready(
        function ()
        {
            $.app.init();
        });
    //---------------------------------------

})(jQuery);


var deviceOS = myApp.device.os;

//--------------------------------------------------------------------
//--------------------------------------------------------------------
//APP COMMUNICATION
/*
* as chamadas diretas do aplicativo para o javascript devem ser
* functions fora do encapsulamento APP() para serem enxergadas pelo app nativo
* */
//--------------------------------------------------------------------
//--------------------------------------------------------------------
function onErrorCallingNativeFunction (){
	alert('Ocorreu um erro (1001)');
}

var posicaoInicialUser;
var statusBeginDelivery;

function updatePosUser (__args__){

	if($.appMapUser && statusBeginDelivery && $.appMap){
		$.app.moveMapUser(__args__);
	}
}

 









