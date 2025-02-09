/*
 * AIT WordPress Theme
 *
 * Copyright (c) 2012, Affinity Information Technology, s.r.o. (http://ait-themes.com)
 */
/* Main Initialization Hook */
jQuery(document).ready(function() {
    gm_authFailure = function() {
        var apiBanner = document.createElement('div');
        var a = document.createElement('a');
        var linkText = document.createTextNode("Read more");
        a.appendChild(linkText);
        a.title = "Read more";
        a.href = "https://www.ait-themes.club/knowledge-base/google-maps-api-error/";
        a.target = "_blank";

        apiBanner.className = "alert alert-info";
        var bannerText = document.createTextNode("Please check Google API key settings");
        apiBanner.appendChild(bannerText);
        apiBanner.appendChild(document.createElement('br'));
        apiBanner.appendChild(a);

        jQuery(".google-map-container").html(apiBanner);
    };

    /* menu.js initialization */
    desktopMenu();
    responsiveMenu();
    relocateSiteTools();
    /* menu.js initialization */

    /* portfolio-item.js initialization */
    portfolioSingleToggles();
    /* portfolio-item.js initialization */

    /* custom.js initialization */
    renameUiClasses();
    removeUnwantedClasses();

    initWPGallery();
    initColorbox();
    initRatings();
    //initInfieldLabels();
    initSelectBox();

    notificationClose();
    /* custom.js initialization */

    /* Theme Dependent FIX Functions */
    /* LANGWITCH */
    fixLanguageMenu();
    fixWooCart();
    /* LANGWITCH */
    /* Theme Dependent FIX Functions */
});
/* Main Initialization Hook */

/* Window Resize Hook */
jQuery(window).resize(function() {
    relocateSiteTools();
});
/* Window Resize Hook */

/* Theme Dependenent Fix Functions */
// Langwitch | Language Dropdown
function fixLanguageMenu() {
    if (isResponsive(640)) {
        // only run at 640px-
        jQuery('.language-icons a.current-lang').bind('touchstart MSPointerDown', function() {
            if (jQuery('.language-icons').hasClass('menu-opened')) {
                jQuery('.language-icons .language-icons__list').hide();
            } else {
                jQuery('.language-icons .language-icons__list').show();
            }
            jQuery('.language-icons').toggleClass('menu-opened');

            return false;
        });
    }
}

// WooCommerce Cart
function fixWooCart() {
    var $cartWrapper = jQuery('#ait-woocommerce-cart-wrapper');
    var $cart = $cartWrapper.find('#ait-woocommerce-cart');

    if (isResponsive(768)) {
        if ($cart.children().length) {
            $cartWrapper.unbind('hover');
            $cartWrapper.find('.cart-header').bind('touchstart MSPointerDown mousedown', function(e) {
                e.stopPropagation();
                e.preventDefault();
                if (!$cartWrapper.hasClass('hover')) {
                    $cart.css({
                        display: 'block'
                    }).stop().animate({
                        opacity: 1
                    });
                } else {
                    $cart.stop().animate({
                        opacity: 0
                    }, function() {
                        $cart.css({
                            display: 'none'
                        });
                    });
                }
                $cartWrapper.toggleClass('hover');
            });
        }
    } else {
        if ($cart.children().length) {
            $cartWrapper.hover(
                function() {
                    $cartWrapper.addClass('hover');
                },
                function() {
                    $cartWrapper.removeClass('hover');
                }
            );
        }
    }
}
/* Theme Dependenent Fix Function */