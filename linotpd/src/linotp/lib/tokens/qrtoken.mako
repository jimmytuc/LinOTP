# -*- coding: utf-8 -*-
<%doc>
 *
 *   LinOTP - the open source solution for two factor authentication
 *   Copyright (C) 2010 - 2016 LSE Leading Security Experts GmbH
 *
 *   This file is part of LinOTP server.
 *
 *   This program is free software: you can redistribute it and/or
 *   modify it under the terms of the GNU Affero General Public
 *   License, version 3, as published by the Free Software Foundation.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the
 *              GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *    E-mail: linotp@lsexperts.de
 *    Contact: www.linotp.org
 *    Support: www.lsexperts.de
 *
 * contains the qrtoken token web interface
</%doc>

%if c.scope == 'config.title' :
 ${_("QRToken")}
%endif


%if c.scope == 'config' :

<form class="cmxform" id="form_qrtoken_config">
<fieldset>
	<legend>${_("QRToken Settings")}</legend>
<table>
</table>
</fieldset>
</form>
%endif


%if c.scope == 'enroll.title' :
${_("QRToken - challenge/response Token")}
%endif

%if c.scope == 'enroll' :
<script>
/*
 * 'typ'_enroll_setup_defaults()
 *
 * this method is called, before the dialog is shown
 *
 */
function qrtoken_enroll_setup_defaults(config, options){
    qrtoken_clear_input_fields();
}

/*
 * 'typ'_get_enroll_params()
 *
 * this method is called, when the token  is submitted
 * - it will return a hash of parameters for admin/init call
 *
 */

function qr_get_enroll_params(){
    var url = {};
    url['type'] = 'qrtan';
    url['description'] = $('#enroll_qrtan_desc').val();
    url['hashlib'] = $('#qrtan_hash_algorithm').val();

    jQuery.extend(url, add_user_data());

    qrtoken_clear_input_fields();
    return url;
}

function qrtoken_clear_input_fields() {
    // Empty input fields for PINs and Keys
    $('#enroll_qrtan_desc').val('')
    $('#enroll_qrtan_desc').val('sha256')
}
</script>
<hr>
<table>
<tr>
	<td><label for="hash_algorithm">${_("Hash algorithm")}</label></td>
	<td>
	    <select name="hash_algorithm" id='qrtoken_hash_algorithm' >
            	<option selected value="sha256">SHA256</option>
            	<option value="sha512">SHA512</option>
            	<option value="sha1">SHA1</option>
    	    </select>
	</td>
</tr>
<tr>
    <td><label for="enroll_qrtoken_desc" id='enroll_qrtoken_desc_label'>${_("Description")}</label></td>
    <td><input type="text" name="enroll_qrtoken_desc" id="enroll_qrtoken_desc" value="webGUI_generated" class="text" /></td>
</tr>
</table>

% endif




%if c.scope == 'selfservice.title.enroll':
${_("Enroll your QRToken")}
%endif


%if c.scope == 'selfservice.enroll':
<script>
	jQuery.extend(jQuery.validator.messages, {
		required: "${_('required input field')}",
		minlength: "${_('minimum length must be greater than {0}')}",
		maxlength: "${_('maximum length must be lower than {0}')}",
		range: '${_("Please enter a valid init secret. It may only contain numbers and the letters A-F.")}',
	});


function self_qrtoken_get_param() {
	var urlparam = {};

	urlparam['type'] = 'qr';
	urlparam['description'] = $('#qrtoken_desc').val();
	return urlparam;
}

function self_qrtoken_clear() {
	$('#qrtoken_desc').val('');
}

function self_qrtoken_submit() {

	var params =  self_qrtoken_get_param();
	enroll_token( params );
	return true;

};

function self_qrtoken_enroll_details(data) {
	return;
};

$( document ).ready(function() {
    $('#button_enroll_qrtoken').click(function (e){
        e.preventDefault();
        self_qrtoken_submit();
    });
});

</script>
<h1>${_("Enroll your QRToken")}</h1>
<div id='enroll_qrtoken_form'>
	<form class="cmxform">
	<fieldset>
		<table>
			<tr>
				<td><label id='qrtoken_desc_label2' for='qrtoken_desc'>${_("Token description")}</label></td>
				<td><input id='qrtoken_desc' name='qrtoken_desc' class="ui-widget-content ui-corner-all" value='self enrolled'/></td>
			</tr>
        </table>
	    <button class='action-button' id='button_enroll_qrtoken'>${_("enroll qrtoken")}</button>
    </fieldset>
    </form>
</div>

%endif

%if c.scope == 'selfservice.title.activate':
${_("Activate your QRToken")}
%endif

%if c.scope == 'selfservice.activate':

<script>

$( document ).ready(function() {
    $('#button_activate_qrtoken_start').click(function (e){
        e.preventDefault();
        self_qrtoken_activate_get_challenge();
    });

    $('#button_activate_qrtoken_finish').click(function (e){
        e.preventDefault();
        self_qrtoken_activate_submit_result();
    });
});

function self_qrtoken_activate_get_challenge() {
    var serial = $('#activate_qrtoken_serial').val();
    var pin = $('#activate_qrtoken_pin').val();
    var message = $('#activate_qrtoken_serial').val();

    var targetselector = "#qrtoken_qr_code"

    var params = {};
    params['serial'] = serial;
    params['pass'] = pin;
    params['data'] = message;
    params['qr'] = 'html';

    var url = '/validate/check_s';

    try {
        var data = clientUrlFetchSync(url, params);
        if ( typeof (data) == "object") {
            var err = data.result.error.message;
            alert(err);
        } else {
            var img = $(data).find('#challenge_qrcode');
            $(targetselector).html(img);

            var lseqrurl = $(data).find('#challenge_qrcode').attr("alt");
            lseqrurl = decodeURIComponent(lseqrurl);
            $(targetselector).append("<p><a href=\"" + lseqrurl + "\">" + lseqrurl + "</a></p>");

            qrtoken_activation_transactionid = $(data).find('#challenge_data .transactionid').text();

            self_qrtoken_activate_switch_phase("two");
        }
    } catch (e) {
        alert(e);
    }
}

function self_qrtoken_activate_submit_result() {
    var otpvalue = $('#activate_qrtoken_otp_value').val();

    var targetselector = "#qrtoken_qr_code"

    var params = {};
    params['transactionid'] = qrtoken_activation_transactionid;
    params['pass'] = otpvalue;

    var url = '/validate/check_t';

    try {
        var resp = clientUrlFetchSync(url, params);
        var data = jQuery.parseJSON(resp);
        if ( data.result.status === false || data.result.value.value === false) {
            self_alert_box({'title':i18n.gettext("QRToken Activation"),
                   'text': i18n.gettext("QRToken activation failed."),
                   'escaped': true});
        } else {
            self_alert_box({'title':i18n.gettext("QRToken Activation"),
                   'text': i18n.gettext("QRToken successfully activated."),
                   'escaped': true});
        }
        self_qrtoken_activate_switch_phase("one");
    } catch (e) {
        alert(e);
    }
}

function self_qrtoken_activate_switch_phase(phase) {
    $('.activate_qrtoken_phase')
        .not("#activate_qrtoken_phase_" + phase)
        .addClass("hidden");
    $("#activate_qrtoken_phase_" + phase).removeClass("hidden");
    $("#activate_qrtoken_phase_" + phase).find("input").each(function(){
        $( this ).val('');
    })
}

</script>

<h1>${_("Activate your QRToken")}</h1>

<div id="activate_qrtoken_phase_one" class="activate_qrtoken_phase">
    <form class="cmxform">
        <table>
            <tr>
                <td>${_("Select QRToken: ")}</td>
                <td>
                    <input type="text" class="selectedToken ui-corner-all" disabled
                        id="activate_qrtoken_serial"/>
                </td>
            </tr>
            <tr>
                <td>${_("Enter pin: ")}</td>
                <td>
                    <input type="password" class="text ui-widget-content ui-corner-all"
                        id="activate_qrtoken_pin"/>
                </td>
            </tr>
            <tr>
                <td>
                    <div id='qr2_activate'>
                        <button class="action-button" id="button_activate_qrtoken_start">${_("activate token")}</button>
                    </div>
                </td>
            </tr>
        </table>
    </form>
</div>
<div id="activate_qrtoken_phase_two" class="activate_qrtoken_phase hidden">
    <form class="cmxform">
        <table>
            <tr>
                <td>
                    <h2>${_('Challenge triggered successfully')}</h2>
                    <p>${_('Please scan the qr code and submit your response or enter the otp value in the form below.')}</p>
                </td>
                <td>
                    <div id="qrtoken_qr_code" class="qrcode-inline"></div>
                </td>
            </tr>
            <tr>
                <td>${_("OTP Value: ")}</td>
                <td>
                    <input type="text" class="ui-corner-all"
                        id="activate_qrtoken_otp_value"/>
                </td>
            </tr>
            <tr>
                <td>
                    <div id='qr2_activate'>
                        <button class="action-button" id="button_activate_qrtoken_finish">${_("finalize activation")}</button>
                    </div>
                </td>
            </tr>
        </table>
    </form>
</div>
% endif
