<%attr>
skip_auth     => 1
no_check_path => 1
page_header   =>'/tmpl/prepend:manage_header_div_layout'
page_footer   =>'/tmpl/footer:footer_div'
onload        => 'document.login.user.focus();'
top_tab_type  => 'login'
body_id       => 'login'
nostandardheader => 1
</%attr>


<%once>
use TUSK::Constants;
use TUSK::Functions;
use Apache::Cookie;
</%once>

<%args>
$user => ''
$errmsg => ''
$url => ''
</%args>

<%method title>
% return "$TUSK::Constants::SiteAbbr Login";
</%method>

<%method stylearray>
% return ['/style/style.css', '/style/login.css'];
</%method>

<%method startup>
% $m->comp("SELF:set_no_cache");
</%method>

<%shared>
my $themeImage = '/graphics/icons/spacer.gif';

my %logoHash = ();
$logoHash{'2-14'}{'image'} = '/graphics/icons/hrtback.gif';
$logoHash{'10-31'}{'image'} = '/graphics/icons/halloween3.gif';
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $isdst) = localtime(time());
my $date = $mon+1 . '-' . $mday;

if(exists($logoHash{$date})  && -f "/data/html$logoHash{$date}{image}") {
	$themeImage = $logoHash{$date}{'image'};
}
</%shared>

<%perl>
# see if there is a 
my %cookies = Apache::Cookie->new($r)->fetch();
my $message = $cookies{'login_error'} && $cookies{'login_error'}->value() ? $cookies{'login_error'}->value()
                  : $errmsg ? $errmsg
                  : '';
my $failedLoginUser = $cookies{'failed_login_user'} && $cookies{'failed_login_user'}->value() ? $cookies{'failed_login_user'}->value()
                  : $user ? $user
                  : '';
</%perl>




<div id="logLoginContainer">

% if($ENV{SCRIPT_URI} =~ /bigscreen/){
%	$url = '/bigscreen';
% }

<& SELF:build_login_box, message => $message, url => $url, failedLoginUser => $failedLoginUser &>

<p id="logMessage" class="xsm"><% $TUSK::Constants::HomepageMessage %></p>

</div> <!-- logLoginContainer -->

<div id="logDropdowns">

<& /tmpl/element:form, params => { action => '', name => 'forwardTo'} &>
<select name="address" onChange="javascript:location.href=this.options[this.selectedIndex].value;">
          <option value="" selected>-- Useful Links --</option>
          <option value="https://exchange.tufts.edu">Webmail</option>
          <option value="https://www.library.tufts.edu/ezproxy/ezproxy.asp?LOCATION=ovid">Ovid MEDLINE</option>
          <option value="/view/url/H1185C/580566/839836"><% $TUSK::Constants::SiteAbbr %> User Guide</option>
          <option value="/about/our_vision">About <% $TUSK::Constants::SiteAbbr %></option>
          <option value="http://directory.tufts.edu">Directory</option>
</select>
<select name="address" onChange="javascript:location.href=this.options[this.selectedIndex].value;">
          <option value ="" selected>-- Schedules --</option>
% foreach my $schoolName (HSDB4::Constants::schedule_schools()){
%	foreach my $homepage_item (TUSK::HomepageCategory->new(_school => $schoolName)->lookup_conditions("schedule=1", "order by sort_order")){
          <option value="/view/schedule/<% $schoolName %>/<% $homepage_item->get_primary_user_group_id %>"><% $schoolName %> <% $homepage_item->get_label() %></option>
%	}
% }
</select>
<select name="address" onChange="javascript:location.href=this.options[this.selectedIndex].value;">
          <option value="" selected>-- Schools & Libraries --</option>
          <option value="http://www.tufts.edu">Tufts University</option>
          <option value="http://www.tufts.edu/med/">School of Medicine</option>
          <option value="http://www.tufts.edu/dental/">School of Dental Medicine</option>
          <option value="http://www.tufts.edu/vet/">Cummings School of Veterinary Medicine</option>
          <option value="http://nutrition.tufts.edu/">Friedman School of Nutrition Science and Policy</option>
          <option value="http://www.tufts.edu/sackler">Sackler School of Graduate Biomedical Sciences</option>
          <option value="http://www.library.tufts.edu/hhsl">Hirsh Health Sciences Library</option>
          <option value="http://www.library.tufts.edu/vet/tulips.html">Webster Veterinary Library</option>
</select>

% if($TUSK::Constants::useShibboleth){
<select name="from" onChange="if(this[this.selectedIndex].value != 'Select') {document.location='https://<% $TUSK::Constants::shibbolethSP %>:<% $TUSK::Constants::shibSPSecurePort %>/shibboleth-login/provision/'+ this[this.selectedIndex].value;}">
	<option value="Select" SELECTED>-- Shibboleth Access --</option>
%	my $shibbolethUsers = TUSK::Shibboleth::User->new->lookup();
%	foreach my $shibUserObject (@{$shibbolethUsers}){
%		if($shibUserObject->ifIsEnabled()){
%			my $apacheShibId = $shibUserObject->getShibbolethUserID();
	<option value="<% $apacheShibId %>"><% $shibUserObject->getShibbolethInstitutionName() %></option>
%		}
%	}
	</select>
% }

</form>
</div> <!-- logDropdowns -->

% my $release = TUSK::Functions::get_tusk_version;
<p class="logRelease xsm">Release : <% $release %></p>


% if($TUSK::Constants::UseTracking){
<% $TUSK::Constants::TrackingString %>
% }


<%method build_login_box>
<%args>
$message => ''
$is_mobi => 0
$url => ''
$failedLoginUser => ''
</%args>
<div id="logLoginBox">
<div id="errordiv">
% if($message){
%	$message =~ s/</&lt;/g;
%	$message =~ s/>/&gt;/g;
%	my $prefix = ($is_mobi)? '/mobi' : '';
<p class="errTxt"><% $message %></p>
<p class="xxsm">If you believe you got this message in error please <a href="<% $prefix %>/about/contact_us">contact us</a></p>
% }
</div>
% my $ssrv = $r->dir_config('SecureLogin') || 'https://'.$TUSK::Constants::Domain.'/login';

<& /tmpl/element:form, params => { action => $ssrv, method => 'post', name => 'login'} &>

% if ($is_mobi && !$url) {
%	$url = '/mobi/home';
% }
% if ($url && $url =~ /^\// ) {
%	$m->comp('/tmpl/element:hidden_form_element', params => { name => 'request_uri', value => $url });
% }

<div style="background:#fff 96% top no-repeat url('<% $themeImage %>');">
<div style="border:2px solid red; padding:2px; margin:2px;">
We apologize for the outage this morning. TUSK was  offline due to technical difficulties beyond our control. We will strive to prevent similar outages from occurring in the future. If you have any questions or trouble accessing TUSK, please contact us.
</div>
<fieldset>
<label for="user" class="xsm">Username:</label>
<input name="user" type="text" class="textareawhite" size="20" value="<% $failedLoginUser %>"/>
</fieldset>

<fieldset>
<label for="password" class="xsm">Password:</label>
<input name="password" type="password" class="textareawhite" size="20"/><br/>
</fieldset>

<div class="loginButtons">

<& /tmpl/element:submit_button, params => { name => 'Submit', label => 'Login', class => 'btnLogin' } &>

% unless($is_mobi){
<& /tmpl/element:button, params => { name => 'guest_access', label => 'Guest Access', onclick => "location.href='allcourses.htm'" } &>
% }
</div>
</div>

% unless($is_mobi){
<script type="text/javascript">isValidTUSKBrowser();</script>
<p class="xsm loginHelp">
<a href="/tusk/tools/pswdreset">Forgot your password?</a>
</p>
% }

</form>
<script type="text/javascript" language="JavaScript">
document.forms['login'].elements['user'].focus();
</script>
</div><!-- logLoginBox -->

</%method>

