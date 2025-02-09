jQuery(document).ready(function() {

    // PrayBox AJAX
    jQuery(document).ready(function($) {

        jQuery('table.pbx-req a').on('click', function(e) {
            e.preventDefault();
            var req_id = jQuery(this).attr('req');
            jQuery('.pbx-modal-bg').fadeIn(function() {
                jQuery('#req_' + req_id).fadeIn();
            });
        });

        jQuery('.pbx-modal-bg').on('click', function() {
            jQuery('.pbx-modal').fadeOut(function() {
                jQuery('.pbx-modal-bg').fadeOut();
            });
        });

        jQuery('.pbx-modal button.flag-btn').on('click', function(e) {
            e.preventDefault();
            var req_id = jQuery(this).parents('.pbx-modal').attr('rel');
            var pb_flag_op = (jQuery(this).hasClass('flag-abuse')) ? "abuse" : "prayed";


            var data = {
                pb_action: 'pb_flag_request',
                req_id: req_id,
                flag_op: pb_flag_op
            };

            jQuery.post('pb_ajaxurl', data, function(response) {
                if (response == 'prayed') {
                    // increment prayed count
                    jQuery('#row_' + req_id + ' td.num-prayers').each(function() {
                        var old_count = jQuery(this).text();
                        jQuery(this).empty().append(parseInt(old_count) + 1);
                    });
                } else {

                }
            });
        });
    });
});