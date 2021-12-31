#!/usr/bin/perl
# Convert CoNLL-U file to a lexicon
use warnings;
use utf8;
binmode STDIN, 'utf8';
binmode STDOUT, 'utf8';
binmode STDERR, 'utf8';
while (<>) {
    s/\cM//g;
    next unless /^\d+\t/;
    my ($n, $token, $lemma, $upos, $xpos, $feats) 
        = split /\t/;
    $token = lc $token unless $lemma =~ /^[[:upper:]]/;
    $key = join("\t", $token, $lemma, $upos, $xpos, $feats);
    $lex{$key}++
}
foreach $key (sort keys %lex) {
    #print "$key\t$lex{$key}\n"
    print "$key\n"
}
