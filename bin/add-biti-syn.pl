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
	if ($lemma ne 'biti' and $msd !~ /Va/) {
	    print $line, "\n";
	    $i++;
	    next;
	}
	my ($dep) = $misc =~ m|Dep=(\d+)| or die;
	my ($rel) = $misc =~ m|Rel=(\w+)| or die;

	my ($h_n, $h_tok, $h_lemma, 
	    $h_ud_cat, $h_msd, $h_ud_feats, 
	    $h_ud_head, $h_ud_deprel, $h_deps, $h_misc);
	my ($h_dep, $h_rel);

	if ($dep > 0) {
	    my $key = $dep + $comments - 1;
	    $head = $lines[$key];
	    ($h_n, $h_tok, $h_lemma, 
	     $h_ud_cat, $h_msd, $h_ud_feats, 
	     $h_ud_head, $h_ud_deprel, $h_deps, $h_misc) 
		= split /\t/, $head;
	    ($h_dep) = $h_misc =~ m|Dep=(\d+)| or die;
	    ($h_rel) = $h_misc =~ m|Rel=(\w+)| or die;
	    # Criterum 3: the head of "biti" is also the parent of a token labelled as 'Sb' 
	    # (e.g. Ne vem, kaj.Nom <--Conj-- je --Sb-->to
	    $crit3 = 0;  
	    # Criterum 4: "biti" is a parent of a token labelled as 'Sb', which occurs after the copula, 
	    # i.e. id(copula) < id(Sb) (e.g. Nakazuje, kateri.Nom <--Conj-- je --Sb-->element)
	    $crit4 = 0;  
	    foreach my $l (@lines) {
		next unless $l =~ /\t/;
		my ($t_n, $t_tok, $t_lemma, 
		    $t_ud_cat, $t_msd, $t_ud_feats, 
		    $t_ud_head, $t_ud_deprel, $t_deps, $t_misc) 
		    = split /\t/, $l;
		($t_dep) = $t_misc =~ m|Dep=(\d+)| or die;
		($t_rel) = $t_misc =~ m|Rel=(\w+)| or die;
		if ($t_n != $n and $t_n != $h_n) {
		    if ($t_rel eq 'Sb' and $t_dep == $h_n) {
			$crit3 = 1;
			# print STDERR "INFO: found C3 for $n\n"
		    }
		    if ($t_rel eq 'Sb' and $t_dep == $n and $t_n > $n) {
			$crit4 = 1;
			# print STDERR "INFO: found C4 for $n\n"
		    }
		}
	    }
	}
	if (not $dep) {$ud_cat = 'VERB'}
	elsif ($rel eq 'PPart') {$ud_cat = 'AUX'}
	elsif ($h_msd =~ /[NAPMXY]/ and $h_rel eq 'Atr') {$ud_cat = 'AUX'}
	elsif ($h_lemma =~ /^(kaj|kdo|kar||kdor|karkoli)$/ and 
	       $h_ud_feats =~ /Case=Nom/ and $h_rel eq 'Conj' and $crit3) {
	    $ud_cat = 'AUX!3'
	}
	elsif ($h_lemma =~ /^(kateri|čigar|kakršen|kolikšen|kakšen)$/ and 
	       $h_ud_feats =~ /Case=Nom/ and $h_rel eq 'Conj' and $crit4) {
	    $ud_cat = 'AUX'
	}
	else {$ud_cat = 'VERB'}
	
	print join("\t", 
		   ($n, $tok, $lemma, 
		    $ud_cat, $msd, $ud_feats, 
		    $ud_head, $ud_deprel, $deps, $misc)),  "\n";
    }
    $i++;
    print "\n";
}
