#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
while (<>){
    next unless /\t/;
    chomp;
    my ($word, $lemma, $msd_en, $msd_sl, $freq, $std, $id, $status, $mte_feats,
	$ufeats) = split /\t/;
    if ($lemma eq 'biti' and $mte_feats =~ /Verb Type=auxiliary/) {
	print;
	print "\n";
	s/\tAUX /\tVERB /;
    }
    print;
    print "\n";
}
