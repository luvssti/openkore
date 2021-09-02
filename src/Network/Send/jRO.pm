#########################################################################
#  OpenKore - Network subsystem
#  This module contains functions for sending messages to the server.
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
# jRO (Japan)
# Servertype overview: https://openkore.com/wiki/ServerType
package Network::Send::jRO;

use strict;
use Network::Send::ServerType0;
use base qw(Network::Send::ServerType0);
use Globals qw(%config);
use Log qw(debug);

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);

	my %packets = (
		'027C' => ['master_login', 'V Z24 Z52 a14', [qw(version username_salted password_salted mac)]],# 96
	);

	$self->{packet_list}{$_} = $packets{$_} for keys %packets;

	my %handlers = qw(
		master_login 027C
	);
	$self->{packet_lut}{$_} = $handlers{$_} for keys %handlers;

	return $self;
}

sub sendMasterLogin {
	my ($self, $username_salted, $password_salted, $mac, $version) = @_;
	my $msg;

	die "don't forget to add jRO_auth plugin to sys.txt\n".
		"https://openkore.com/wiki/loadPlugins_list\n" unless ($username_salted and $password_salted);

	$msg = $self->reconstruct({
		switch => 'master_login',
		version => $version || $self->version,
		mac => $mac,
		username_salted => $username_salted,
		password_salted => $password_salted,
	});

	$self->sendToServer($msg);
	debug "Sent sendMasterLogin\n", "sendPacket", 2;
}

1;
