#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
while (<>){
    next unless /\t/;
    chomp;
    my ($word, $lemma, $msd, $freq, $std, $feats, $ud_feats) = split /\t/;
    if ($lemma eq 'biti' and $feats =~ /Verb Type=auxiliary/) {
	s/\tAUX /\tAUX|VERB /;
    }
    print;
    print "\n";
}
