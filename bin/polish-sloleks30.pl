#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
print join("\t", 'FORM', 'LEMMA', 'MSD-sl', 'MSD-en', 'UPOS', 'UFEATS',
	   'RFPM', 'STANDARD', 'STATUS', 'ID') . "\n";
  
while (<>){
    chomp;
    next unless /\t/;
    my ($form, $lemma, $msd_en, $msd_sl, $freq, $standard, $id, $status, $mte_feats, $ufeats)
	= split /\t/;
    $standard = 'standard' unless $standard;
    if    ($status eq 'MANUAL') {$status = 'manual'}
    elsif ($status eq 'AUTOMATIC') {$status = 'auto'}
    else {die "Bad standard $status\n"}
    print join("\t", ($form, $lemma, $msd_sl, $msd_en, $ufeats,
		      $freq, $standard, $status, $id)) . "\n";
}
