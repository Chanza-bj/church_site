"use strict";

function desktopMenu() {
    if (!isResponsive(641)) {
        // only run at 640px+
        jQuery('.nav-menu-main').find('li').each(function() {
            if (jQuery(this).find('ul.sub-menu').length) {
                // item has a submenu
                jQuery(this).addClass('has-submenu');
            }
        });

        popupDesktopMenu();

        androidDesktopMenuFix();
    }
}

function responsiveMenu() {
    var toggle = '.main-nav .menu-toggle' + (isResponsive(320) ? '' : ', .menu-overlay');
    jQuery(toggle).bind('touchstart MSPointerDown mousedown', function(e) {
        e.stopPropagation();
        e.preventDefault();
        jQuery('#masthead').toggleClass('menu-opened');
        return false;
    });
}

function relocateSiteTools() {

    var headersTools = {

        'header-one': [{
            selector: '.site-tools',
            regularPos: jQuery('.header-container'),
            relocatedPos: jQuery('.site-header > .menu-container .nav-menu-container')
        }, ],

        'header-two': [{
            selector: '.ait-woocommerce-cart-widget',
            regularPos: {
                after: jQuery('.header-top .grid-main div:last-child')
            },
            relocatedPos: {
                after: jQuery('.header-container .site-logo')
            },
        }],

        'header-three': [{
            selector: '.site-info',
            regularPos: jQuery('.header-container'),
            relocatedPos: jQuery('.site-header .header-two .nav-menu-container')
        }],

        'header-four': [{
            selector: '.site-tools',
            regularPos: {
                after: jQuery('.header-container .site-logo')
            },
            relocatedPos: jQuery('.site-header > .menu-container .nav-menu-container')
        }],

        'header-five': [{
            selector: '.site-tools',
            regularPos: {
                after: jQuery('.header-container .site-logo')
            },
            relocatedPos: jQuery('.site-header > .menu-container .nav-menu-container')
        }],

        'header-six': [{
            selector: '.site-tools',
            regularPos: {
                after: jQuery('.site-header > .menu-container .main-nav')
            },
            relocatedPos: jQuery('.site-header > .menu-container .nav-menu-container')
        }]

    };

    var actualHeader = jQuery('.site-header').data('header');

    var relocateTools = function(pos) {
        if (!(actualHeader in headersTools)) return;
        jQuery(headersTools[actualHeader]).each(function() {
            var desiredPos = this[pos];
            var toolPos = desiredPos instanceof jQuery ? desiredPos : (desiredPos.after).parent();
            if (toolPos.find('> ' + this.selector).length <= 0) {
                if (desiredPos instanceof jQuery) {
                    jQuery(this.selector).first().prependTo(desiredPos);
                } else {
                    jQuery(this.selector).first().insertAfter((desiredPos.after));
                }
            }
        });
    }

    if (isResponsive(768)) {
        relocateTools('relocatedPos');
    } else {
        relocateTools('regularPos');
    }
}

function androidDesktopMenuFix() {
    if (isAndroid()) {
        jQuery('.nav-menu-main').find('li').each(function() {
            jQuery(this).bind('click', function(e) {
                e.stopPropagation();
                if (jQuery(this).hasClass('has-submenu')) {
                    var itemID = jQuery(this).attr('id');
                    if (jQuery(this).hasClass('clicked-once')) {
                        // the second click on target
                    } else {
                        // if there was clicked on other item reset all except current
                        jQuery('.nav-menu-main').find('li').each(function() {
                            if (jQuery(this).attr('id') != itemID) {
                                jQuery(this).removeClass('clicked-once');
                            }
                        });
                        // first click on target
                        e.preventDefault();
                        jQuery(this).addClass('clicked-once');
                    }
                } else {
                    // normal flow
                }
            });
        });
    }
}

function popupDesktopMenu() {
    if (jQuery('body').hasClass('sticky-menu-enabled')) {
        var clonedMenu = jQuery('header.site-header .nav-menu-main').clone();
        if (typeof clonedMenu.find('ul.nav-menu').attr('id') != "undefined") {
            clonedMenu.find('ul.nav-menu').attr({
                'id': clonedMenu.find('ul.nav-menu').attr('id') + '-clone'
            });
        }
        clonedMenu.find('ul.nav-menu').children('li').each(function() {
            if (typeof jQuery(this).attr('id') != "undefined") {
                jQuery(this).attr({
                    'id': jQuery(this).attr('id') + "-clone"
                });
            }
        });
        jQuery('div.sticky-menu .main-nav').append(clonedMenu);

        var container = jQuery('#masthead');
        var menu = {
            offset: container.offset(),
            height: container.outerHeight(true)
        };
        var page = jQuery('body');
        var scroll = (menu.offset.top + menu.height);
        if (!isResponsive(641)) {
            var win = jQuery(window);
            /*win.scroll(function(){
            	if(win.scrollTop() > scroll){
            		page.addClass('header-scrolled');
            	} else {
            		page.removeClass('header-scrolled');
            	}
            });*/

            setInterval(function() {
                if (win.scrollTop() > scroll) {
                    page.addClass('header-scrolled');
                } else {
                    page.removeClass('header-scrolled');
                }
            }, 200);
        }
    }
}