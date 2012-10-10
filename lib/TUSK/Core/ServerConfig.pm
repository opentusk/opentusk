package TUSK::Core::ServerConfig;

use strict;
use TUSK::Constants;
use Sys::Hostname;

sub dbReadUser {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers->{$token}->{'readusername'};
}

sub dbWriteUser {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers->{$token}->{'writeusername'};
}

sub dbReadPassword {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers->{$token}->{'readpassword'};
}

sub dbWritePassword {
    my $token = shift || "ContentManager";
    return $TUSK::Constants::DatabaseUsers->{$token}->{'writepassword'};
}

sub dbReadDefaultDB {
    return $TUSK::Constants::DefaultDB;
}

sub dbWriteDefaultDB {
    return $TUSK::Constants::DefaultDB;
}

sub dbReadHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::DBParameters{$hostname}->{"ReadHost"};
}

sub dbWriteHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::DBParameters{$hostname}->{"WriteHost"};
}

sub dbSearchHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::DBParameters{$hostname}->{"SearchHost"};
}

sub dbVideoHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::DBParameters{$hostname}->{"VideoHost"};
}

sub dbAudioHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::DBParameters{$hostname}->{"AudioHost"};
}

sub dbFlashPixHost {
    my $hostname = Sys::Hostname::hostname;
    return $TUSK::Constants::DBParameters{$hostname}->{"FlashPixHost"};
}

1;
