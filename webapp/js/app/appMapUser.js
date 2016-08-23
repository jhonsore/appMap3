$(function() {
    function AppMapUser(){
        "use strict";

        CustomEventHandler.call(this);

        //instância do google maps
        this.gMaps;

        //instância do tsp
        this.tsp;

        //posição atual do usuário
        this.currentPosition = 0;

        //proxima posição a ir
        this.nextPosition = 1;

        //--------
        this.ON_SOLVED = "onSolved";

        //ícone do usuário
        this.iconUser = "img/icon-user.png";

    }

    AppMapUser.prototype = new CustomEventHandler();

    AppMapUser.prototype.constructor = AppMapUser;

    AppMapUser.prototype.init = function (){

        //setamos o gmaps do appMap
        this.gMaps = $.appMap.gMaps;

        //iniciamos o marcador do usuário
        if($.appMap.getUserPosition()){
            this.position = $.appMap.getUserPosition();
            $.appMapUser.initMarkerUser();
            $.appMapUser.initRoute();
        }else{
            myApp.alert("Posição do usuário não encontrada","Atenção");
        }
    }

    /*
     * destrói app user
     * */
    AppMapUser.prototype.destroy = function (){
        if(this.markerUser){
            this.markerUser.setMap(null);
            this.markerUser = null;
        }
    }

    /*
     * duração total estimada da viagem
     * */
    AppMapUser.prototype.getTotalDurationTrip = function (){
        return $.utils.getTotalDurationTrip($.appMapUser.gDirections);
    }

    /*
     * distância total da viagem
     * */
    AppMapUser.prototype.getTotalDistanceTrip = function (){
        return $.utils.getTotalDistanceTrip($.appMapUser.gDirections);
    }

    /*
     * cria marcador do usuário
     * */
    AppMapUser.prototype.initMarkerUser = function (){

        var myLatLng = this.position;
        var icon = new google.maps.MarkerImage($.appMapUser.iconUser);
        var marker = new google.maps.Marker( {
            position: myLatLng,
            map: $.appMapUser.gMaps,
            optimized: false,
            icon: icon,
            zIndex: google.maps.Marker.MAX_ZINDEX//mudamos o indexo do marcador do usuário
        } );

        marker.setMap( this.gMaps );

        this.markerUser = marker;

    }

    /*
     * cria rota a ser feita
     * */
    AppMapUser.prototype.initRoute = function (){

        if(!$.appMap.checkRoute()) return false;

        $.appMap.tsp.startOver(); // limpamos o tsp para termos os itens que queremos
        $.appMap.tsp.addWaypoint($.appMap.markers[$.appMapUser.currentPosition].getPosition());//adicionamos a posição inicial
        $.appMap.tsp.addWaypoint($.appMap.markers[$.appMapUser.nextPosition].getPosition());//adicionamos a posição final

        if(!$.appMap.checkRoute()) return false;

        $.utils.addLoader();

        $.appMap.tsp.setOnProgressCallback($.appMapUser.onProgressCallback);

        if ($.appMap.mode == 0)
            $.appMap.tsp.solveRoundTrip($.appMapUser.onSolveCallback);
        else
            $.appMap.tsp.solveAtoZ($.appMapUser.onSolveCallback);

    }

    /*
     * onProgressCallback
     * */
    AppMapUser.prototype.onProgressCallback = function (){
        var _val = 100 * ($.appMap.tsp.getNumDirectionsComputed()) / ($.appMap.tsp.getNumDirectionsNeeded());
        $(".loader-calculation").css({width:_val+"%"});
    }

    /*
     * onSolveCallback
     * */
    AppMapUser.prototype.onSolveCallback = function (){

        var dirRes = $.appMap.tsp.getGDirections();
        var dir = dirRes.routes[0];

        $.appMapUser.gDirections = dir;

        $.utils.removeLoader();

        //----------
        // Clean up old path.
        if ($.appMapUser.dirRenderer != null) {
            $.appMapUser.dirRenderer.setMap(null);
        }

        var polylineOptionsActual = new google.maps.Polyline({
            strokeColor: '#FF0000',
            strokeOpacity: 1.0,
            strokeWeight: 6,
            zIndex: 1000
        });

        $.appMapUser.dirRenderer = new google.maps.DirectionsRenderer({
            polylineOptions: polylineOptionsActual,
            directions: dirRes,
            hideRouteList: true,
            map: $.appMapUser.gMaps,
            panel: null,
            preserveViewport: false,
            suppressInfoWindows: true,
            suppressMarkers: true });

        $.appMapUser.dispatchEvent($.appMapUser.ON_SOLVED,{});

    }

    /*
     * onProgressCallback
     * */
    AppMapUser.prototype.onProgressCallback = function (){
        var _val = 100 * ($.appMap.tsp.getNumDirectionsComputed()) / ($.appMap.tsp.getNumDirectionsNeeded());
        $(".loader-calculation").css({width:_val+"%"});
    }

    /*
     * move marcador do usuário
     * */
    AppMapUser.prototype.moveMarkerUser = function (__arg__){

        var _lat = __arg__.lat;
        var _long = __arg__.long;

        $.appMapUser.markerUser.setPosition( new google.maps.LatLng( _lat, _long ));

        //move o mapa para a posição do marcador
        if(__arg__.moveMap){
            $.appMapUser.centerMapOnMarkerUser();
            //$.appMapUser.gMaps.panTo( new google.maps.LatLng( _lat, _long ));
        }
    };

    /*
     * centraliza o mapa de acordo com o marcador do usuário
     * */
    AppMapUser.prototype.centerMapOnMarkerUser = function (){
        $.appMapUser.gMaps.panTo($.appMapUser.markerUser.getPosition());
    };

    //cria nova instância do app
    $.appMapUser = new AppMapUser();

});
