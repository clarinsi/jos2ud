#!/usr/bin/perl -w
use utf8;
$mode = shift;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
$skip = 1;
$s_id = 'ssj619.3207.11412'; #First sentence without dependencies
if ($mode eq 'only') {
    while (<>){
	if (/# sent_id\s*=\s*$s_id/) {last}
	else {print}
    }
}
elsif ($mode eq 'except') {
    while (<>){
	if (/# sent_id\s*=\s*$s_id/) {
	    $skip = 0;
	    print
	}
	elsif ($skip) {}
	else {print}
    }
}
else {die "Mode is 'only' or 'except'\n"}
