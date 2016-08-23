/*
* responsável pela configuração do app
* */
(function() {
    function Config(){
		"use strict";

		this.online = false;

		this.HOST = (this.online) ?
			'http://backstagedigital.com.br/clientes/00_estudos/appGMaps/' :
			'http://192.168.1.1/developer/jhonnatan/__estudos/app-map/Webview/webapp/';

		//------------------------------------------------------------------
		//WS
		//------------------------------------------------------------------

		//retorna as posições iniciais com os locais das entregas de uma lista qualquer
		this.getPositions = "posicoes.php";

	}

	Config.prototype.constructor = Config;

    //---------------------------------------
    window.configuration = new Config();

})();


 









