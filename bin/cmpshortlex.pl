#!/usr/bin/perl
# Compare differences in UD features between two shortlexes
use warnings;
use utf8;
binmode STDIN, 'utf8';
binmode STDOUT, 'utf8';
binmode STDERR, 'utf8';
$lex1File = shift;
$lex2File = shift;
open L1, '<:utf8', $lex1File or die;    
open L2, '<:utf8', $lex2File or die;    
while (<L1>) {
    next unless /\t/;
    chomp;
    my ($token, $lemma, $upos, $xpos, $feats) = split /\t/;
    $key = join("\t", $token, $lemma, $upos, $xpos);
    $lex1{$key} = $feats
}
close L1;
while (<L2>) {
    next unless /\t/;
    chomp;
    my ($token, $lemma, $upos, $xpos, $feats) = split /\t/;
    $key = join("\t", $token, $lemma, $upos, $xpos);
    if (exists $lex1{$key}) {
        if ($lex1{$key} ne $feats) {
            print "ERROR: Feat conflict $lex1{$key} $_ vs. $lex1{$key}\n"
        }
    }
}
