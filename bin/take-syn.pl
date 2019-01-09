#!/usr/bin/perl -w
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
while (<>){
    if (/# sent_id\s*=\s*ssj619.3207.11412/) {last}
    else {print}
}
