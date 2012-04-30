# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Shibboleth::Configurator;

=head1 NAME

B<TUSK::Shibboleth::Configurator> - Class for manipulating files in addons/shibboleth

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Constants;
use TUSK::Shibboleth::User;

BEGIN {
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    @ISA = qw( );
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
	# Find out what class we are
	my $class = shift;
	$class = ref $class || $class;
	# Call the super-class's constructor and give it all the values
	my $self = {
		_variables  => {},
	};
	bless $self, $class;
	# Finish initialization...
	return $self;
}

### Get/Set methods

#######################################################

=item B<writeConfigFileFromTemplate>

my ($worked, $errors, $warnings) = $obj->writeConfigFileFromTemplate();

Wtite the main config file from the template

=cut

sub getConfigurationFiles {
	my %hashOfVariables;
	my $serverRoot = $TUSK::Constants::ServerRoot;
	my $logRoot = $TUSK::Constants::LogRoot;
	unless($serverRoot) {$serverRoot = "/usr/local/tusk/current";}
	unless($logRoot) {$logRoot = $serverRoot."/logs";}

	my %configFiles;
	$configFiles{'pidFile'} = "$logRoot/shibd.pid";
	$configFiles{'shibdSock'} = "$logRoot/shib-shar.sock";
	$configFiles{'xmlFile'} = "${serverRoot}/addons/shibboleth/shibboleth.xml";
	$configFiles{'shibRoot'} = "/opt/shibboleth-sp";
	return %configFiles;
}

sub writeConfigFiles {
	my ($self) = @_;

	# Get the SERVER_ROOT because its used in an open later
	my $certFile = "/usr/local/tusk/ssl_certificate/server.crt";
	my $keyFile = "/usr/local/tusk/ssl_certificate/server.key";
	my $serverRoot = $TUSK::Constants::ServerRoot;
	unless($serverRoot && $certFile && $keyFile) {
		my $hashValues = '';
		return(0, "Missing configuration values in tusk.conf.". '');
	}

	my $shibDir = "$serverRoot/addons/shibboleth";
	my $shibTemplate = "$shibDir/shib_template.xml";
	my $shibConfigFile = "$shibDir/shibboleth.xml";

	# verify that the addons/shibboleth directory exists and can be written to
	unless(-e $shibDir) { return(0, "Missing addons directory '$shibDir'", ''); }
	unless(-w $shibDir) { return(0, 'Unable to write to addons directory', '');}

	# verify that the template file is there and can be read
	unless(open(TEMPLATE, $shibTemplate)) { return(0, 'Missing shibboleth template', ''); }
	unless(open(CONFIG, ">$shibConfigFile")) { return(0, 'Unable to open shibboleth.xml for write', ''); }

	# write to each of the school.xml files
	my $warnings = "";
	my $errors = "";

	my $shibIdPs = TUSK::Shibboleth::User->new()->lookup();
	my %idPSSOBindings;
	my %idPHosts;

	foreach my $shibIdPObject (@{$shibIdPs}) {
		if($shibIdPObject->getIdPXML) {
			if($shibIdPObject->getIdPXML =~ /EntityDescriptor entityID="([^"]*)"/) {
				$idPSSOBindings{$shibIdPObject->getShibbolethUserID()} = $1;
				$idPHosts{$shibIdPObject->getShibbolethUserID()} = $idPSSOBindings{$shibIdPObject->getShibbolethUserID()};
				$idPHosts{$shibIdPObject->getShibbolethUserID()} =~ s/http[s]:\/\///g;
				$idPHosts{$shibIdPObject->getShibbolethUserID()} =~ s/\/.*//g;

				my $idPFile = $shibIdPObject->getUniqueName() . ".xml";
				unless(open(XML_FILE, ">$shibDir/$idPFile")) {
					$errors += "Unable to create file $idPFile.<Br>";
				} else {
					print XML_FILE $shibIdPObject->getIdPXML;
					close(XML_FILE);
					$shibIdPObject->setNeedsRegen('N');
					$shibIdPObject->save();
				}
			} else {
				$errors .= $shibIdPObject->getShibbolethInstitutionName() . " does not appear to contain information no how shibboleth 2.0 uses it.<br>";
			}
		} else {
			$warnings .= $shibIdPObject->getShibbolethInstitutionName() . " does not contain any IdP xml.<br>";
		}
	}


	# generate the main shibboleth.xml file
	while(<TEMPLATE>) {
		if(/<!-- TUSK Providers -->/) {
			foreach my $shibIdPObject (@{$shibIdPs}) {
				if($shibIdPObject->ifIsEnabled()) {
					my $idPFileName = "$shibDir/" . $shibIdPObject->getUniqueName() . ".xml";
					if(-e $idPFileName) {
						print CONFIG "<MetadataProvider type=\"XML\" file=\"${idPFileName}\"/>\n";
					}
				}
			}
		} elsif(/<!-- TUSK IdP Definations -->/) {
			foreach my $shibIdPObject (@{$shibIdPs}) {
				if($shibIdPObject->ifIsEnabled() && exists($idPSSOBindings{$shibIdPObject->getShibbolethUserID()})) {
					print CONFIG "<SessionInitiator type=\"SAML2\" Location=\"/WAYF/". $idPHosts{$shibIdPObject->getShibbolethUserID()} ."\"";
					print CONFIG " isDefault=\"false\" defaultACSIndex=\"1\" template=\"bindingTemplate.html\" id=\"". $shibIdPObject->getShibbolethUserID() ."\"";
					print CONFIG " entityID=\"". $idPSSOBindings{$shibIdPObject->getShibbolethUserID()} ."\"/>\n";
				}
			}
		} else {
			s/TUSK_HOST_NAME/$TUSK::Constants::shibbolethSP/g;
			s/TUSK_SECURE_PORT/$TUSK::Constants::shibSPSecurePort/g;
			s/TUSK_LOG_DIRECTORY/$ENV{LOG_ROOT}/g;
			s/TUSK_CERT_KEY/$keyFile/g;
			s/TUSK_CERT/$certFile/g;

			print CONFIG $_;
		}
	}
	close(TEMPLATE);
	close(CONFIG);
	return(1, $errors, $warnings);
}


=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2011.

=cut

1;

