/*
 * responsável pela criação do framework
 * */
(function() {
    "use strict";
//----------------
// Initialize your app
        var myApp = new Framework7({
            /*animateNavBackIcon:true,
             pushState:true,
             pushStateSeparator:'',
             pushStateNoAnimation:true*/
        });

// Export selectors engine
        var $$ = Dom7;

// Add main View
        var mainView = myApp.addView('.view-main', {
            /*// Enable dynamic Navbar
             dynamicNavbar: true,*/
            // Enable Dom Cache so we can use all inline pages
            domCache: true
        });

        window.mainView = mainView;
        window.myApp = myApp;

})();













