(function($) {
    function Utils(){
        "use strict";
    }

    Utils.prototype.constructor = Utils;

    /*
     * adiciona o loader
     * */
    Utils.prototype.addLoader = function (){
        var _template = "<div class='box-calculator'>";
        _template += "<div class='loader-calculation'></div>";
        _template += "</div>";
        $("body").append(_template);
    }

    /*
     * remove o loader
     * */
    Utils.prototype.removeLoader = function (){
        $(".box-calculator").remove();
    }

//-----------------------------------------

    /*
     * duração total estimada da viagem
     * */
    Utils.prototype.getTotalDurationTrip = function (__gDirection__){
        return $.utils.formatTime($.utils.getTotalDuration(__gDirection__));//$.appMap.gDirections
    }

    /*
     * distância total da viagem
     * */
    Utils.prototype.getTotalDistanceTrip = function (__gDirection__){
        return $.utils.formatLength($.utils.getTotalDistance(__gDirection__));
    }

    //FORMATER UTILS

    /* Returns a textual representation of time in the format
     * "N days M hrs P min Q sec". Does not include days if
     * 0 days etc. Does not include seconds if time is more than
     * 1 hour.
     */
    Utils.prototype.formatTime = function (seconds){
        var days;
        var hours;
        var minutes;
        days = parseInt(seconds / (24*3600));
        seconds -= days * 24 * 3600;
        hours = parseInt(seconds / 3600);
        seconds -= hours * 3600;
        minutes = parseInt(seconds / 60);
        seconds -= minutes * 60;
        var ret = "";
        if (days > 0)
            ret += days + " dias ";
        if (days > 0 || hours > 0)
            ret += hours + " hrs ";
        if (days > 0 || hours > 0 || minutes > 0)
            ret += minutes + " min ";
        if (days == 0 && hours == 0)
            ret += seconds + " seg";
        return(ret);
    }

    /* Returns textual representation of distance in the format
     * "N km M m". Does not include km if less than 1 km. Does not
     * include meters if km >= 10.
     */
    Utils.prototype.formatLength = function (meters){
        var km = parseInt(meters / 1000);
        meters -= km * 1000;
        var ret = "";
        if (km > 0)
            ret += km + " km ";
        if (km < 10)
            ret += meters + " m";
        return(ret);
    }

    Utils.prototype.getTotalDuration = function (dir){
        var sum = 0;
        for (var i = 0; i < dir.legs.length; i++) {
            sum += dir.legs[i].duration.value;
        }
        return sum;
    }

    Utils.prototype.getTotalDistance = function (dir){
        var sum = 0;
        for (var i = 0; i < dir.legs.length; i++) {
            sum += dir.legs[i].distance.value;
        }
        return sum;
    }

    /* Returns textual representation of distance in the format
     * "N.M miles".
     */
    Utils.prototype.formatLengthMiles = function (meters){
        var sMeters = meters * 0.621371192;
        var miles = parseInt(sMeters / 1000);
        var commaMiles = parseInt((sMeters - miles * 1000 + 50) / 100);
        var ret = miles + "." + commaMiles + " miles";
        return(ret);
    }

    //---------------------------------------
    $.utils = new Utils();

})(jQuery);











