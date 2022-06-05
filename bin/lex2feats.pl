#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
my $mapFile = shift or die "Need mapping file!\n";
my %msd_map;

open MAP, $mapFile or die "Can't open $mapFile!\n";
binmode MAP,"utf8";
while (<MAP>) {
    next if /^#/ or not /\t/;
    chomp;
    ($msd, $feats) = split /\t/;
    $msd{$msd} = $feats;
}
close MAP;

while (<>){
    #A line starting with # and no tabs is a comment
    if (/^#/ and not /\t/) {
	print;
	next
    }
    chomp;
    my ($word, $lemma, $msd) = split /\t/;
    die "Bad MSD $msd!\n" unless exists $msd{$msd};
    print;
    print "\t$msd{$msd}\n"
}
