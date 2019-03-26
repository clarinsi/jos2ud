#!/usr/bin/perl -w
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
$goldFile = shift;
open TBL, '<:utf8', $goldFile or die;
while (<TBL>) {
    next unless /\t/;
    chomp;
    my ($n, $tok, $lemma, 
	$ud_cat, $msd, $ud_feats, 
	$ud_head, $ud_deprel, $deps, $misc) = split /\t/;
    $ud_feats =~ s/\|/ /g;
    push @gold, join("\t", $n, $tok, $lemma, $ud_cat, $msd, $ud_feats)
}
while (<>){
    next if /^doc_id/;
    next unless /\t/;
    chomp;
    s/\t"/\t/g;
    s/"\t/\t/g;
    s/""/"/g;
    my ($doc_id, $sentence_id, $id, 
     $form, 
     $lemma_auto, $upos_auto, $xpos_auto, $feats_auto, 
     $lemma_err, $tok_err, $pos_err, $feats_err, 
     $lemma_man, $xpos_man, 
     $aux_verb) = split /\t/;
    my ($n, $tok, $lemma, $ud_cat, $msd, $ud_feats) = split("\t", shift @gold);
    die unless $n == $id and $tok eq $form and $lemma eq $lemma_man and $msd eq $xpos_man;
    if ($tok_err) {
	if ($lemma_err or $pos_err or $feats_err) {
	    print STDERR "ERROR: token = $tok_err but other errors: $_\n"
	}
    }
    else {
	if ($lemma_auto ne $lemma_man) {
	    if ($lemma_err ne 'F') {
		print STDERR "ERROR: lemma <> F but $lemma_auto <> $lemma_man: $_\n"
	    }
	}
	elsif ($lemma_err)  {
	    print STDERR "ERROR: lemma = $lemma_err but $lemma_auto = $lemma_man: $_\n"
	}
	if ($upos_auto ne $ud_cat) {
	    if ($pos_err ne 'F') {
		print STDERR "ERROR: pos <> F but $upos_auto <> $ud_cat: $_\n"
	    }
	}
	elsif ($pos_err)  {
	    print STDERR "ERROR: pos = $pos_err but $upos_auto = $ud_cat: $_\n"
	}
	$feats_err = 0 unless $feats_err;
	$feats_err2 = &cnt_errs($ud_feats, $feats_auto);
	if ($feats_err != $feats_err2) {
	    print STDERR "ERROR: feats mismatch $feats_err <> $feats_err2: $_ [[$msd = $ud_feats]]\n"
	}
    }
}
sub cnt_errs {
    my $f1s = shift;
    my $f2s = shift;
    my %f1;
    my %f2;
    foreach my $f (split(/ /, $f1s)) {
	if ($f eq '_') {$f1{$f} = $f}
	else {
	    ($a, $v) = split(/=/, $f);
	    $f1{$a} = $v
	}
    }
    foreach my $f (split(/ /, $f2s)) {
	if ($f eq '_') {$f2{$f} = $f}
	else {
	    ($a, $v) = split(/=/, $f);
	    $f2{$a} = $v
	}
    }
    my $e = 0;
    foreach $a (keys %f2) {
	if (not exists $f1{$a}) {$e++}
	elsif ($f1{$a} ne $f2{$a}) {$e++}
    }
    return $e
}
