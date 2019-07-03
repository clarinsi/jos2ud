#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
my $mapFile = shift or die "Need mapping file!\n";

open MAP, $mapFile or die "Can't open $mapFile!\n";
binmode MAP,"utf8";
while (<MAP>) {
    chomp;
    next unless /./;
    ($id, $n) = /^(.+)\.t(\d+)/;
    push @{$mark{$id}}, $n;
}
close MAP;

while (<>){
    if (/^# sent_id = (.+?)$/) {
	$id = $1;
	if (exists $mark{$id}) {
	    @toks = @{$mark{$id}};
	    $tok_n = shift @toks;
	}
	else {
	    @toks = ();
	    $tok = 0;
	}
    }
    elsif (/^\d+\t/) {
	chomp;
	($n, $tok, $lemma, 
	 $ud_cat, $msd, $ud_feats, 
	 $ud_head, $ud_deprel, $deps, $misc) = split /\t/;
	if (exists $mark{$id} and $n == $tok_n) {
	    die unless $lemma eq 'biti';
	    $_ = join("\t", $n, $tok, $lemma, 
		      'VERB', $msd, $ud_feats, 
		      $ud_head, $ud_deprel, $deps, $misc);
	    if (@toks) {$tok_n = shift @toks}
	    else {$tok_n = 0}
	}
	elsif ($lemma and $lemma eq 'biti' and $ud_head == -1) {
	    $_ = join("\t", $n, $tok, $lemma, 
		      'AUX', $msd, $ud_feats, 
		      $ud_head, $ud_deprel, $deps, $misc);
	}
	else {
	    $_ = join("\t", $n, $tok, $lemma, 
		      $ud_cat, $msd, $ud_feats, 
		      $ud_head, $ud_deprel, $deps, $misc);
	}
	$_ .= "\n";
    }
    print;
}
