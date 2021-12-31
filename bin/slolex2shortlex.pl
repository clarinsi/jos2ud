#!/usr/bin/perl
# Convert Slolex lexicon to simplified lexicon
use warnings;
use utf8;
binmode STDIN, 'utf8';
binmode STDOUT, 'utf8';
binmode STDERR, 'utf8';
while (<>) {
    s/\cM//;
    next unless /\t/;
    chomp;
    my ($token, $lemma, $xpos, $freq, $std, $mte, $ufeats) 
        = split /\t/;
    if ($ufeats =~ / /) {
        ($upos, $feats) = $ufeats =~ /(.+?) (.+)/;
        $feats =~ s/ /|/g;
    }
    else {
        $upos = $ufeats;
        $feats = '_'
    }
    print join("\t", $token, $lemma, $upos, $xpos, $feats) . "\n";
}
