#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
$/ = "\n\n";
while (<>){
    @lines = split /\n/;
    $comments = 0;
    $i = 0;
    foreach $line (@lines) {
	if ($line=~/^#/ or $line !~ /\t/) {
	    print $line, "\n";
	    $i++;
	    $comments++;
	    next;
	}
	my ($n, $tok, $lemma, 
	    $ud_cat, $msd, $ud_feats, 
	    $ud_head, $ud_deprel, $deps, $misc) = split /\t/, $line;
	if ($lemma ne 'biti' or $msd !~ /Va/) {
	    print $line, "\n";
	    $i++;
	    next;
	}
	#Does this token satisfy the "copula" criteria
	# a. does the parent belong to JOS-POS categories: N, A, P, M, X, Y and 
        #    has JOS-dep 'Atr'
	#   (e.g. Avto je.AUX --Atr--> zelen.ADJ)
	$copula_a = 0;
	#b. does the parent have one of the following lemmas: kaj, kdo, kar, kdor, karkoli and
	#   is in Nominative case and is labelled with the JOS-dep Conj and
	#   is also the parent of a token labelled as 'Sb' 
	#   (e.g. Ne vem, kaj.Nom <--Conj-- je --Sb-->to)
	$copula_b = 0;
	# c. does the parent have one of the following lemmas: kateri, čigar, kakršen, kolikšen, kakšen and
	#    is in Nominative case and is labelled with the JOS-dep 'Conj' and 
	#    is also the parent of a token labelled as 'Sb', 
	#    which occurs after the copula, i.e. id(copula) < id(Sb) 
	# e.g. Nakazuje, kateri.Nom <--Conj-- je --Sb-->element
	$copula_c = 0;
	foreach my $l (@lines) {
	    next unless $l =~ /\t/;
	    my ($t_n, $t_tok, $t_lemma, 
		$t_ud_cat, $t_msd, $t_ud_feats, 
		$t_ud_head, $t_ud_deprel, $t_deps, $t_misc) 
		= split /\t/, $l;
	    ($t_dep) = $t_misc =~ m|Dep=(\d+)| or die;
	    ($t_rel) = $t_misc =~ m|Rel=(\w+)| or die;
	    if ($t_dep == $n) { #Found a parent of "biti"
		if ($t_msd =~ /[NAPMXY]/ and 
		    $t_rel eq 'Atr') {$copula_a = 1}
		if ($t_lemma =~ /^(kaj|kdo|kar||kdor|karkoli)$/ and 
		    $t_ud_feats =~ /Case=Nom/ and
		    $t_rel eq 'Conj') {
		    foreach my $ll (@lines) {
			next unless $ll =~ /\t/;
			my ($x_n, $x_tok, $x_lemma, 
			    $x_ud_cat, $x_msd, $x_ud_feats, 
			    $x_ud_head, $x_ud_deprel, $x_deps, $x_misc) 
			    = split /\t/, $ll;
			($x_dep) = $x_misc =~ m|Dep=(\d+)| or die;
			($x_rel) = $x_misc =~ m|Rel=(\w+)| or die;
			if ($x_dep == $t_dep and $x_rel eq 'Sb') {
			    $copula_b = 1
			}
		    }
		}
		if ($t_lemma =~ /^(kateri|čigar|kakršen|kolikšen|kakšen)$/ and 
		    $t_ud_feats =~ /Case=Nom/ and
		    $t_rel eq 'Conj') {
		    foreach my $ll (@lines) {
			next unless $ll =~ /\t/;
			my ($x_n, $x_tok, $x_lemma, 
			    $x_ud_cat, $x_msd, $x_ud_feats, 
			    $x_ud_head, $x_ud_deprel, $x_deps, $x_misc) 
			    = split /\t/, $ll;
			($x_dep) = $x_misc =~ m|Dep=(\d+)| or die;
			($x_rel) = $x_misc =~ m|Rel=(\w+)| or die;
			if ($x_dep == $t_dep and $x_rel eq 'Sb' and $x_n > $n) {
			    $copula_c = 1
			}
		    }
		}
	    }
	}
	if ($misc =~ /Rel=PPart/) {$ud_cat = 'AUX'}
	elsif ($copula_a) {$ud_cat = 'AUX'}
	elsif ($copula_b) {$ud_cat = 'AUX'}
	elsif ($copula_c) {$ud_cat = 'AUX'}
	else {$ud_cat = 'VERB'}
	
	print join("\t", 
		   ($n, $tok, $lemma, 
		    $ud_cat, $msd, $ud_feats, 
		    $ud_head, $ud_deprel, $deps, $misc)),  "\n";
    }
    $i++;
    print "\n";
}
