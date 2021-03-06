#!/usr/bin/perl -w

# Parses the bpf.h header file to generate the dlt_names.h header
# which maps the DLT types to the DLT string name

# run from the tcpreplay source base directory as:
# cat /usr/include/pcap-bpf.h | ./scripts/dlt2name.pl

use strict;
my $out_c = 'src/common/dlt_names.c';
my $out_h = 'src/common/dlt_names.h';

# open outfile
open(OUT_C, ">$out_c") or die("Unable to open $out_c for writing: $!");
open(OUT_H, ">$out_h") or die("Unable to open $out_h for writing: $!");

# read STDIN

# some DLT types aren't in a format we can parse easily or just doesn't
# exist in my /usr/include/net/bpf.h file so we list them here
my %known = (107 => 'BSD/OS Frame Relay',
             108 => 'OpenBSD Loopback',
             113 => 'Linux Cooked Sockets',
             114 => 'Apple LocalTalk',
             115 => 'Acorn Econet',
             116 => 'OpenBSD IPFilter',
             117 => 'OpenBSD PF Log/SuSE 6.3 LANE 802.3',
             118 => 'Cisco IOS',
             119 => '802.11 Prism Header',
             120 => '802.11 Aironet Header',
             121 => 'Siemens HiPath HDLC',
             122 => 'IP over Fibre Channel'
            );
my @names;

# put our known DLT types in names since the format of bpf.h is 
# inconsistent

foreach my $dlt (keys %known) {
  $names[$dlt]{name} = $known{$dlt};
}

while (my $line = <STDIN>) {

  if ($line =~ /^\#define\s+(DLT_[a-zA-Z0-9_]+)\s+(\d+)/) {
    my $key = $1;
    my $dlt = $2;
    my $name = $names[$dlt]{name} ? $names[$dlt]{name} : "";
    if ($line =~ /\/\*\s+(.*)\s+\*\//) {
      $name = $1;
    }
    $names[$dlt]{key} = $key;
    $names[$dlt]{name} = $name;
  }

}

# print the license info 
while (my $line = <DATA>) {
    print OUT_C $line;
    print OUT_H $line;
}

# prep the header
print OUT_C <<HEADER;

#include <stdlib.h>

/* DLT to descriptions */
char *dlt2desc[] = {
HEADER

for (my $i = 0; $i < $#names; $i ++) {
  if (! defined $names[$i]) {
    print OUT_C "\t\t\"Unknown\",\n";
  } else {
    print OUT_C "\t\t\"$names[$i]->{name}\",\n";
  }
}

print OUT_C <<FOOTER;
\t\tNULL
};

FOOTER

print OUT_H <<HEADER;

/* include all the DLT types form pcap-bpf.h */

extern const char *dlt2desc[];
extern const char *dlt2name[];
#define DLT2DESC_LEN $#names
#define DLT2NAME_LEN $#names

HEADER

for (my $i = 0; $i < 255; $i++) {
    next if ! defined $names[$i];
    print OUT_H "#ifndef $names[$i]{key}\n#define $names[$i]{key} $i\n#endif\n\n";
}

print OUT_C <<NAMES;

/* DLT to names */
char *dlt2name[] = {
NAMES

for (my $i = 0; $i < 255; $i++) {
    if (! defined $names[$i]) {
        print OUT_C "\t\t\"Unknown\",\n";
    } else {
        print OUT_C "\t\t\"$names[$i]{key}\",\n";
    }
}

print OUT_C <<FOOTER;
\t\tNULL
};
FOOTER

close OUT_C;
close OUT_H;

exit 0;

__DATA__
/*
 * Copyright (c) 2006 Aaron Turner
 * All rights reserved.
 *
 * This file is generated by scripts/dlt2name.pl which converts your pcap-bpf.h
 * header file which comes with libpcap into a header file
 * which translates DLT values to their string names as well as a list of all
 * of the available DLT types.
 *
 * Hence DO NOT EDIT THIS FILE!
 * If your DLT type is not listed here, edit the %known hash in
 * scripts/dlt2name.pl
 * 
 * This file contains data which was taken from libpcap's pcap-bpf.h.  
 * The copyright/license is included below:
 */
 
 /*-
  * Copyright (c) 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997
  *      The Regents of the University of California.  All rights reserved.
  *
  * This code is derived from the Stanford/CMU enet packet filter,
  * (net/enet.c) distributed as part of 4.3BSD, and code contributed
  * to Berkeley by Steven McCanne and Van Jacobson both of Lawrence 
  * Berkeley Laboratory.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions
  * are met:
  * 1. Redistributions of source code must retain the above copyright
  *    notice, this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright
  *    notice, this list of conditions and the following disclaimer in the
  *    documentation and/or other materials provided with the distribution.
  * 3. All advertising materials mentioning features or use of this software
  *    must display the following acknowledgement:
  *      This product includes software developed by the University of
  *      California, Berkeley and its contributors.
  * 4. Neither the name of the University nor the names of its contributors
  *    may be used to endorse or promote products derived from this software
  *    without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
  * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  * SUCH DAMAGE.
  *
  *      @(#)bpf.h       7.1 (Berkeley) 5/7/91
  *
  * @(#) $Header: /tcpdump/master/libpcap/pcap-bpf.h,v 1.34.2.6 2005/08/13 22:29:47 hannes Exp $ (LBL)
  */

