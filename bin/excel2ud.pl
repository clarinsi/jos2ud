#!/usr/bin/perl -w
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
$lexFile = shift;
open TBL, '<:utf8', $lexFile or die;
while (<TBL>) {
    next unless /\t/;
    chomp;
    my ($word, $lemma, $msd, $freq) = split /\t/;
    $wl_key = lc($word) . "\t" . lc($lemma);
    $wm_key = lc($word) . "\t" . $msd;
    push @{$wl2m{$wl_key}}, $msd;
    push @{$wm2l{$wm_key}}, $lemma;
}

while (<DATA>) {
    next unless /\t/;
    chomp;
    ($msd, $feats) = split /\t/;
    $feats{$msd} = $feats
}

my ($doc_id, $sentence_id, $id, 
    $form, 
    $lemma_auto, $upos_auto, $xpos_auto, $feats_auto, 
    $lemma_err, $tok_err, $pos_err, $feats_err, 
    $lemma_man, $xpos_man, 
    $aux_verb);
$first = 1;
$prev_sent = 0;
@sent_text = ();
@cooked = ();

while (<>){
    next if /^doc_id/;
    next unless /\t/;
    chomp;
    s/\t"/\t/g;
    s/"\t/\t/g;
    s/""/"/g;
    $tokens++;
    ($doc_id, $sentence_id, $id, 
     $form, 
     $lemma_auto, $upos_auto, $xpos_auto, $feats_auto, 
     $lemma_err, $tok_err, $pos_err, $feats_err, 
     $lemma_man, $xpos_man, 
     $aux_verb) = split /\t/;
    print STDERR "ERROR: no doc_id in $_!\n" unless $doc_id;
    $preamble  = "# sent_id = $doc_id.$sentence_id\n" unless $prev_sent;
    if ($prev_sent and $prev_sent != $sentence_id) {
	print "\n" unless $first;
	$first = 0;
	print $preamble;
	$preamble  = "# sent_id = $doc_id.$sentence_id\n";
	print "# text = " . join(" ", @sent_text) . "\n";
	print join "\n", @cooked;
	print "\n";
	@sent_text = ();
	@cooked = ();
    }
    $prev_sent = $sentence_id;
    push @sent_text, $form;
    $err = 0;
    unless (exists $feats{$xpos_man}) {
	print STDERR "ERROR: bad MSD '$xpos_man', cf. '$_'\n";
	$xpos_man = 'X';
	$cat = 'Residual';
	$feats = '_';
	$err = 1;
    }
    elsif ($feats{$xpos_man} =~ / /) {
	($cat, $feats) = $feats{$xpos_man} =~ /(.+?) (.+)/
	    or die "Bad map of $xpos_man: '$feats{$xpos_man}'\n";
	$feats =~ s/ /|/g;
    }
    else {
	$cat = $feats{$xpos_man};
	$feats = '_';
    }
    if ($lemma_man eq 'biti') {
	if    ($aux_verb eq 'AUX') {}
	elsif ($aux_verb eq 'VERB') {
	    $feats =~ s/Type=auxiliary/Type=main/ 
		or print STDERR "WARN: 'biti' as Vm, cf. '$_'\n"
	}
	else {
	    print STDERR "ERROR: bad VERB/AUX marking for 'biti' ($aux_verb), cf. '$_'\n"}
    }
    $wl_key = lc($form) . "\t" . lc($lemma_man);
    if (exists $wl2m{$wl_key}) {
	$msd_check++;
	$ok = 0;
	foreach $m (@{$wl2m{$wl_key}}) {
	    $ok = 1 if $m eq $xpos_man
	}
	unless ($ok or $xpos_man =~ /Np/ or $xpos_man =~ /I/) {
	    print STDERR "WARN: '$wl_key' might have bad MSD '$xpos_man'. ";
	    print STDERR "It could be '" . join("', '", @{$wl2m{$wl_key}}) . "', cf. '$_'\n"
	}
    }
    $wm_key = lc($form) . "\t" . $xpos_man;
    if (exists $wm2l{$wm_key}) {
	$lemma_check++;
	$ok = 0;
	foreach $l (@{$wm2l{$wm_key}}) {
	    $ok = 1 if $l eq $lemma_man
	}
	unless ($ok) {
	    print STDERR "WARN: '$wm_key' might have bad lemma '$lemma_man'. ";
	    print STDERR "It could be '" . join("', '", @{$wm2l{$wm_key}}) . "', cf. '$_'\n"
	}
    }
    $token = join "\t", $id, $form, $lemma_man, $cat, $xpos_man, $feats, '0', '_', '_', '_';
    push @cooked, $token;
}
print "\n";
print $preamble;
print "# text = " . join(" ", @sent_text) . "\n";
print join "\n", @cooked;
print "\n";

print STDERR "INFO: checked $lemma_check lemmas, $msd_check MSDs of $tokens tokens\n";


__DATA__
Agcfda	Adjective Type=general Degree=comparative Gender=feminine Number=dual Case=accusative
Agcfdd	Adjective Type=general Degree=comparative Gender=feminine Number=dual Case=dative
Agcfdg	Adjective Type=general Degree=comparative Gender=feminine Number=dual Case=genitive
Agcfdi	Adjective Type=general Degree=comparative Gender=feminine Number=dual Case=instrumental
Agcfdl	Adjective Type=general Degree=comparative Gender=feminine Number=dual Case=locative
Agcfdn	Adjective Type=general Degree=comparative Gender=feminine Number=dual Case=nominative
Agcfpa	Adjective Type=general Degree=comparative Gender=feminine Number=plural Case=accusative
Agcfpd	Adjective Type=general Degree=comparative Gender=feminine Number=plural Case=dative
Agcfpg	Adjective Type=general Degree=comparative Gender=feminine Number=plural Case=genitive
Agcfpi	Adjective Type=general Degree=comparative Gender=feminine Number=plural Case=instrumental
Agcfpl	Adjective Type=general Degree=comparative Gender=feminine Number=plural Case=locative
Agcfpn	Adjective Type=general Degree=comparative Gender=feminine Number=plural Case=nominative
Agcfsa	Adjective Type=general Degree=comparative Gender=feminine Number=singular Case=accusative
Agcfsd	Adjective Type=general Degree=comparative Gender=feminine Number=singular Case=dative
Agcfsg	Adjective Type=general Degree=comparative Gender=feminine Number=singular Case=genitive
Agcfsi	Adjective Type=general Degree=comparative Gender=feminine Number=singular Case=instrumental
Agcfsl	Adjective Type=general Degree=comparative Gender=feminine Number=singular Case=locative
Agcfsn	Adjective Type=general Degree=comparative Gender=feminine Number=singular Case=nominative
Agcmda	Adjective Type=general Degree=comparative Gender=masculine Number=dual Case=accusative
Agcmdd	Adjective Type=general Degree=comparative Gender=masculine Number=dual Case=dative
Agcmdg	Adjective Type=general Degree=comparative Gender=masculine Number=dual Case=genitive
Agcmdi	Adjective Type=general Degree=comparative Gender=masculine Number=dual Case=instrumental
Agcmdl	Adjective Type=general Degree=comparative Gender=masculine Number=dual Case=locative
Agcmdn	Adjective Type=general Degree=comparative Gender=masculine Number=dual Case=nominative
Agcmpa	Adjective Type=general Degree=comparative Gender=masculine Number=plural Case=accusative
Agcmpd	Adjective Type=general Degree=comparative Gender=masculine Number=plural Case=dative
Agcmpg	Adjective Type=general Degree=comparative Gender=masculine Number=plural Case=genitive
Agcmpi	Adjective Type=general Degree=comparative Gender=masculine Number=plural Case=instrumental
Agcmpl	Adjective Type=general Degree=comparative Gender=masculine Number=plural Case=locative
Agcmpn	Adjective Type=general Degree=comparative Gender=masculine Number=plural Case=nominative
Agcmsa	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=accusative
Agcmsay	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=accusative Definiteness=yes
Agcmsd	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=dative
Agcmsg	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=genitive
Agcmsi	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=instrumental
Agcmsl	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=locative
Agcmsny	Adjective Type=general Degree=comparative Gender=masculine Number=singular Case=nominative Definiteness=yes
Agcnda	Adjective Type=general Degree=comparative Gender=neuter Number=dual Case=accusative
Agcndd	Adjective Type=general Degree=comparative Gender=neuter Number=dual Case=dative
Agcndg	Adjective Type=general Degree=comparative Gender=neuter Number=dual Case=genitive
Agcndi	Adjective Type=general Degree=comparative Gender=neuter Number=dual Case=instrumental
Agcndl	Adjective Type=general Degree=comparative Gender=neuter Number=dual Case=locative
Agcndn	Adjective Type=general Degree=comparative Gender=neuter Number=dual Case=nominative
Agcnpa	Adjective Type=general Degree=comparative Gender=neuter Number=plural Case=accusative
Agcnpd	Adjective Type=general Degree=comparative Gender=neuter Number=plural Case=dative
Agcnpg	Adjective Type=general Degree=comparative Gender=neuter Number=plural Case=genitive
Agcnpi	Adjective Type=general Degree=comparative Gender=neuter Number=plural Case=instrumental
Agcnpl	Adjective Type=general Degree=comparative Gender=neuter Number=plural Case=locative
Agcnpn	Adjective Type=general Degree=comparative Gender=neuter Number=plural Case=nominative
Agcnsa	Adjective Type=general Degree=comparative Gender=neuter Number=singular Case=accusative
Agcnsd	Adjective Type=general Degree=comparative Gender=neuter Number=singular Case=dative
Agcnsg	Adjective Type=general Degree=comparative Gender=neuter Number=singular Case=genitive
Agcnsi	Adjective Type=general Degree=comparative Gender=neuter Number=singular Case=instrumental
Agcnsl	Adjective Type=general Degree=comparative Gender=neuter Number=singular Case=locative
Agcnsn	Adjective Type=general Degree=comparative Gender=neuter Number=singular Case=nominative
Agpfda	Adjective Type=general Degree=positive Gender=feminine Number=dual Case=accusative
Agpfdd	Adjective Type=general Degree=positive Gender=feminine Number=dual Case=dative
Agpfdg	Adjective Type=general Degree=positive Gender=feminine Number=dual Case=genitive
Agpfdi	Adjective Type=general Degree=positive Gender=feminine Number=dual Case=instrumental
Agpfdl	Adjective Type=general Degree=positive Gender=feminine Number=dual Case=locative
Agpfdn	Adjective Type=general Degree=positive Gender=feminine Number=dual Case=nominative
Agpfpa	Adjective Type=general Degree=positive Gender=feminine Number=plural Case=accusative
Agpfpd	Adjective Type=general Degree=positive Gender=feminine Number=plural Case=dative
Agpfpg	Adjective Type=general Degree=positive Gender=feminine Number=plural Case=genitive
Agpfpi	Adjective Type=general Degree=positive Gender=feminine Number=plural Case=instrumental
Agpfpl	Adjective Type=general Degree=positive Gender=feminine Number=plural Case=locative
Agpfpn	Adjective Type=general Degree=positive Gender=feminine Number=plural Case=nominative
Agpfsa	Adjective Type=general Degree=positive Gender=feminine Number=singular Case=accusative
Agpfsd	Adjective Type=general Degree=positive Gender=feminine Number=singular Case=dative
Agpfsg	Adjective Type=general Degree=positive Gender=feminine Number=singular Case=genitive
Agpfsi	Adjective Type=general Degree=positive Gender=feminine Number=singular Case=instrumental
Agpfsl	Adjective Type=general Degree=positive Gender=feminine Number=singular Case=locative
Agpfsn	Adjective Type=general Degree=positive Gender=feminine Number=singular Case=nominative
Agpmda	Adjective Type=general Degree=positive Gender=masculine Number=dual Case=accusative
Agpmdd	Adjective Type=general Degree=positive Gender=masculine Number=dual Case=dative
Agpmdg	Adjective Type=general Degree=positive Gender=masculine Number=dual Case=genitive
Agpmdi	Adjective Type=general Degree=positive Gender=masculine Number=dual Case=instrumental
Agpmdl	Adjective Type=general Degree=positive Gender=masculine Number=dual Case=locative
Agpmdn	Adjective Type=general Degree=positive Gender=masculine Number=dual Case=nominative
Agpmpa	Adjective Type=general Degree=positive Gender=masculine Number=plural Case=accusative
Agpmpd	Adjective Type=general Degree=positive Gender=masculine Number=plural Case=dative
Agpmpg	Adjective Type=general Degree=positive Gender=masculine Number=plural Case=genitive
Agpmpi	Adjective Type=general Degree=positive Gender=masculine Number=plural Case=instrumental
Agpmpl	Adjective Type=general Degree=positive Gender=masculine Number=plural Case=locative
Agpmpn	Adjective Type=general Degree=positive Gender=masculine Number=plural Case=nominative
Agpmsa	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=accusative
Agpmsan	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=accusative Definiteness=no
Agpmsay	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=accusative Definiteness=yes
Agpmsd	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=dative
Agpmsg	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=genitive
Agpmsi	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=instrumental
Agpmsl	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=locative
Agpmsnn	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=nominative Definiteness=no
Agpmsny	Adjective Type=general Degree=positive Gender=masculine Number=singular Case=nominative Definiteness=yes
Agpnda	Adjective Type=general Degree=positive Gender=neuter Number=dual Case=accusative
Agpndd	Adjective Type=general Degree=positive Gender=neuter Number=dual Case=dative
Agpndg	Adjective Type=general Degree=positive Gender=neuter Number=dual Case=genitive
Agpndi	Adjective Type=general Degree=positive Gender=neuter Number=dual Case=instrumental
Agpndl	Adjective Type=general Degree=positive Gender=neuter Number=dual Case=locative
Agpndn	Adjective Type=general Degree=positive Gender=neuter Number=dual Case=nominative
Agpnpa	Adjective Type=general Degree=positive Gender=neuter Number=plural Case=accusative
Agpnpd	Adjective Type=general Degree=positive Gender=neuter Number=plural Case=dative
Agpnpg	Adjective Type=general Degree=positive Gender=neuter Number=plural Case=genitive
Agpnpi	Adjective Type=general Degree=positive Gender=neuter Number=plural Case=instrumental
Agpnpl	Adjective Type=general Degree=positive Gender=neuter Number=plural Case=locative
Agpnpn	Adjective Type=general Degree=positive Gender=neuter Number=plural Case=nominative
Agpnsa	Adjective Type=general Degree=positive Gender=neuter Number=singular Case=accusative
Agpnsd	Adjective Type=general Degree=positive Gender=neuter Number=singular Case=dative
Agpnsg	Adjective Type=general Degree=positive Gender=neuter Number=singular Case=genitive
Agpnsi	Adjective Type=general Degree=positive Gender=neuter Number=singular Case=instrumental
Agpnsl	Adjective Type=general Degree=positive Gender=neuter Number=singular Case=locative
Agpnsn	Adjective Type=general Degree=positive Gender=neuter Number=singular Case=nominative
Agsfda	Adjective Type=general Degree=superlative Gender=feminine Number=dual Case=accusative
Agsfdd	Adjective Type=general Degree=superlative Gender=feminine Number=dual Case=dative
Agsfdg	Adjective Type=general Degree=superlative Gender=feminine Number=dual Case=genitive
Agsfdi	Adjective Type=general Degree=superlative Gender=feminine Number=dual Case=instrumental
Agsfdl	Adjective Type=general Degree=superlative Gender=feminine Number=dual Case=locative
Agsfdn	Adjective Type=general Degree=superlative Gender=feminine Number=dual Case=nominative
Agsfpa	Adjective Type=general Degree=superlative Gender=feminine Number=plural Case=accusative
Agsfpd	Adjective Type=general Degree=superlative Gender=feminine Number=plural Case=dative
Agsfpg	Adjective Type=general Degree=superlative Gender=feminine Number=plural Case=genitive
Agsfpi	Adjective Type=general Degree=superlative Gender=feminine Number=plural Case=instrumental
Agsfpl	Adjective Type=general Degree=superlative Gender=feminine Number=plural Case=locative
Agsfpn	Adjective Type=general Degree=superlative Gender=feminine Number=plural Case=nominative
Agsfsa	Adjective Type=general Degree=superlative Gender=feminine Number=singular Case=accusative
Agsfsd	Adjective Type=general Degree=superlative Gender=feminine Number=singular Case=dative
Agsfsg	Adjective Type=general Degree=superlative Gender=feminine Number=singular Case=genitive
Agsfsi	Adjective Type=general Degree=superlative Gender=feminine Number=singular Case=instrumental
Agsfsl	Adjective Type=general Degree=superlative Gender=feminine Number=singular Case=locative
Agsfsn	Adjective Type=general Degree=superlative Gender=feminine Number=singular Case=nominative
Agsmda	Adjective Type=general Degree=superlative Gender=masculine Number=dual Case=accusative
Agsmdd	Adjective Type=general Degree=superlative Gender=masculine Number=dual Case=dative
Agsmdg	Adjective Type=general Degree=superlative Gender=masculine Number=dual Case=genitive
Agsmdi	Adjective Type=general Degree=superlative Gender=masculine Number=dual Case=instrumental
Agsmdl	Adjective Type=general Degree=superlative Gender=masculine Number=dual Case=locative
Agsmdn	Adjective Type=general Degree=superlative Gender=masculine Number=dual Case=nominative
Agsmpa	Adjective Type=general Degree=superlative Gender=masculine Number=plural Case=accusative
Agsmpd	Adjective Type=general Degree=superlative Gender=masculine Number=plural Case=dative
Agsmpg	Adjective Type=general Degree=superlative Gender=masculine Number=plural Case=genitive
Agsmpi	Adjective Type=general Degree=superlative Gender=masculine Number=plural Case=instrumental
Agsmpl	Adjective Type=general Degree=superlative Gender=masculine Number=plural Case=locative
Agsmpn	Adjective Type=general Degree=superlative Gender=masculine Number=plural Case=nominative
Agsmsa	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=accusative
Agsmsay	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=accusative Definiteness=yes
Agsmsd	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=dative
Agsmsg	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=genitive
Agsmsi	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=instrumental
Agsmsl	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=locative
Agsmsny	Adjective Type=general Degree=superlative Gender=masculine Number=singular Case=nominative Definiteness=yes
Agsnda	Adjective Type=general Degree=superlative Gender=neuter Number=dual Case=accusative
Agsndd	Adjective Type=general Degree=superlative Gender=neuter Number=dual Case=dative
Agsndg	Adjective Type=general Degree=superlative Gender=neuter Number=dual Case=genitive
Agsndi	Adjective Type=general Degree=superlative Gender=neuter Number=dual Case=instrumental
Agsndl	Adjective Type=general Degree=superlative Gender=neuter Number=dual Case=locative
Agsndn	Adjective Type=general Degree=superlative Gender=neuter Number=dual Case=nominative
Agsnpa	Adjective Type=general Degree=superlative Gender=neuter Number=plural Case=accusative
Agsnpd	Adjective Type=general Degree=superlative Gender=neuter Number=plural Case=dative
Agsnpg	Adjective Type=general Degree=superlative Gender=neuter Number=plural Case=genitive
Agsnpi	Adjective Type=general Degree=superlative Gender=neuter Number=plural Case=instrumental
Agsnpl	Adjective Type=general Degree=superlative Gender=neuter Number=plural Case=locative
Agsnpn	Adjective Type=general Degree=superlative Gender=neuter Number=plural Case=nominative
Agsnsa	Adjective Type=general Degree=superlative Gender=neuter Number=singular Case=accusative
Agsnsd	Adjective Type=general Degree=superlative Gender=neuter Number=singular Case=dative
Agsnsg	Adjective Type=general Degree=superlative Gender=neuter Number=singular Case=genitive
Agsnsi	Adjective Type=general Degree=superlative Gender=neuter Number=singular Case=instrumental
Agsnsl	Adjective Type=general Degree=superlative Gender=neuter Number=singular Case=locative
Agsnsn	Adjective Type=general Degree=superlative Gender=neuter Number=singular Case=nominative
Appfda	Adjective Type=participle Degree=positive Gender=feminine Number=dual Case=accusative
Appfdd	Adjective Type=participle Degree=positive Gender=feminine Number=dual Case=dative
Appfdg	Adjective Type=participle Degree=positive Gender=feminine Number=dual Case=genitive
Appfdi	Adjective Type=participle Degree=positive Gender=feminine Number=dual Case=instrumental
Appfdl	Adjective Type=participle Degree=positive Gender=feminine Number=dual Case=locative
Appfdn	Adjective Type=participle Degree=positive Gender=feminine Number=dual Case=nominative
Appfpa	Adjective Type=participle Degree=positive Gender=feminine Number=plural Case=accusative
Appfpd	Adjective Type=participle Degree=positive Gender=feminine Number=plural Case=dative
Appfpg	Adjective Type=participle Degree=positive Gender=feminine Number=plural Case=genitive
Appfpi	Adjective Type=participle Degree=positive Gender=feminine Number=plural Case=instrumental
Appfpl	Adjective Type=participle Degree=positive Gender=feminine Number=plural Case=locative
Appfpn	Adjective Type=participle Degree=positive Gender=feminine Number=plural Case=nominative
Appfsa	Adjective Type=participle Degree=positive Gender=feminine Number=singular Case=accusative
Appfsd	Adjective Type=participle Degree=positive Gender=feminine Number=singular Case=dative
Appfsg	Adjective Type=participle Degree=positive Gender=feminine Number=singular Case=genitive
Appfsi	Adjective Type=participle Degree=positive Gender=feminine Number=singular Case=instrumental
Appfsl	Adjective Type=participle Degree=positive Gender=feminine Number=singular Case=locative
Appfsn	Adjective Type=participle Degree=positive Gender=feminine Number=singular Case=nominative
Appmda	Adjective Type=participle Degree=positive Gender=masculine Number=dual Case=accusative
Appmdd	Adjective Type=participle Degree=positive Gender=masculine Number=dual Case=dative
Appmdg	Adjective Type=participle Degree=positive Gender=masculine Number=dual Case=genitive
Appmdi	Adjective Type=participle Degree=positive Gender=masculine Number=dual Case=instrumental
Appmdl	Adjective Type=participle Degree=positive Gender=masculine Number=dual Case=locative
Appmdn	Adjective Type=participle Degree=positive Gender=masculine Number=dual Case=nominative
Appmpa	Adjective Type=participle Degree=positive Gender=masculine Number=plural Case=accusative
Appmpd	Adjective Type=participle Degree=positive Gender=masculine Number=plural Case=dative
Appmpg	Adjective Type=participle Degree=positive Gender=masculine Number=plural Case=genitive
Appmpi	Adjective Type=participle Degree=positive Gender=masculine Number=plural Case=instrumental
Appmpl	Adjective Type=participle Degree=positive Gender=masculine Number=plural Case=locative
Appmpn	Adjective Type=participle Degree=positive Gender=masculine Number=plural Case=nominative
Appmsa	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=accusative
Appmsan	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=accusative Definiteness=no
Appmsay	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=accusative Definiteness=yes
Appmsd	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=dative
Appmsg	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=genitive
Appmsi	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=instrumental
Appmsl	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=locative
Appmsnn	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=nominative Definiteness=no
Appmsny	Adjective Type=participle Degree=positive Gender=masculine Number=singular Case=nominative Definiteness=yes
Appnda	Adjective Type=participle Degree=positive Gender=neuter Number=dual Case=accusative
Appndd	Adjective Type=participle Degree=positive Gender=neuter Number=dual Case=dative
Appndg	Adjective Type=participle Degree=positive Gender=neuter Number=dual Case=genitive
Appndi	Adjective Type=participle Degree=positive Gender=neuter Number=dual Case=instrumental
Appndl	Adjective Type=participle Degree=positive Gender=neuter Number=dual Case=locative
Appndn	Adjective Type=participle Degree=positive Gender=neuter Number=dual Case=nominative
Appnpa	Adjective Type=participle Degree=positive Gender=neuter Number=plural Case=accusative
Appnpd	Adjective Type=participle Degree=positive Gender=neuter Number=plural Case=dative
Appnpg	Adjective Type=participle Degree=positive Gender=neuter Number=plural Case=genitive
Appnpi	Adjective Type=participle Degree=positive Gender=neuter Number=plural Case=instrumental
Appnpl	Adjective Type=participle Degree=positive Gender=neuter Number=plural Case=locative
Appnpn	Adjective Type=participle Degree=positive Gender=neuter Number=plural Case=nominative
Appnsa	Adjective Type=participle Degree=positive Gender=neuter Number=singular Case=accusative
Appnsd	Adjective Type=participle Degree=positive Gender=neuter Number=singular Case=dative
Appnsg	Adjective Type=participle Degree=positive Gender=neuter Number=singular Case=genitive
Appnsi	Adjective Type=participle Degree=positive Gender=neuter Number=singular Case=instrumental
Appnsl	Adjective Type=participle Degree=positive Gender=neuter Number=singular Case=locative
Appnsn	Adjective Type=participle Degree=positive Gender=neuter Number=singular Case=nominative
Aspfda	Adjective Type=possessive Degree=positive Gender=feminine Number=dual Case=accusative
Aspfdd	Adjective Type=possessive Degree=positive Gender=feminine Number=dual Case=dative
Aspfdg	Adjective Type=possessive Degree=positive Gender=feminine Number=dual Case=genitive
Aspfdi	Adjective Type=possessive Degree=positive Gender=feminine Number=dual Case=instrumental
Aspfdl	Adjective Type=possessive Degree=positive Gender=feminine Number=dual Case=locative
Aspfdn	Adjective Type=possessive Degree=positive Gender=feminine Number=dual Case=nominative
Aspfpa	Adjective Type=possessive Degree=positive Gender=feminine Number=plural Case=accusative
Aspfpd	Adjective Type=possessive Degree=positive Gender=feminine Number=plural Case=dative
Aspfpg	Adjective Type=possessive Degree=positive Gender=feminine Number=plural Case=genitive
Aspfpi	Adjective Type=possessive Degree=positive Gender=feminine Number=plural Case=instrumental
Aspfpl	Adjective Type=possessive Degree=positive Gender=feminine Number=plural Case=locative
Aspfpn	Adjective Type=possessive Degree=positive Gender=feminine Number=plural Case=nominative
Aspfsa	Adjective Type=possessive Degree=positive Gender=feminine Number=singular Case=accusative
Aspfsd	Adjective Type=possessive Degree=positive Gender=feminine Number=singular Case=dative
Aspfsg	Adjective Type=possessive Degree=positive Gender=feminine Number=singular Case=genitive
Aspfsi	Adjective Type=possessive Degree=positive Gender=feminine Number=singular Case=instrumental
Aspfsl	Adjective Type=possessive Degree=positive Gender=feminine Number=singular Case=locative
Aspfsn	Adjective Type=possessive Degree=positive Gender=feminine Number=singular Case=nominative
Aspmda	Adjective Type=possessive Degree=positive Gender=masculine Number=dual Case=accusative
Aspmdd	Adjective Type=possessive Degree=positive Gender=masculine Number=dual Case=dative
Aspmdg	Adjective Type=possessive Degree=positive Gender=masculine Number=dual Case=genitive
Aspmdi	Adjective Type=possessive Degree=positive Gender=masculine Number=dual Case=instrumental
Aspmdl	Adjective Type=possessive Degree=positive Gender=masculine Number=dual Case=locative
Aspmdn	Adjective Type=possessive Degree=positive Gender=masculine Number=dual Case=nominative
Aspmpa	Adjective Type=possessive Degree=positive Gender=masculine Number=plural Case=accusative
Aspmpd	Adjective Type=possessive Degree=positive Gender=masculine Number=plural Case=dative
Aspmpg	Adjective Type=possessive Degree=positive Gender=masculine Number=plural Case=genitive
Aspmpi	Adjective Type=possessive Degree=positive Gender=masculine Number=plural Case=instrumental
Aspmpl	Adjective Type=possessive Degree=positive Gender=masculine Number=plural Case=locative
Aspmpn	Adjective Type=possessive Degree=positive Gender=masculine Number=plural Case=nominative
Aspmsa	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=accusative
Aspmsan	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=accusative Definiteness=no
Aspmsd	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=dative
Aspmsg	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=genitive
Aspmsi	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=instrumental
Aspmsl	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=locative
Aspmsnn	Adjective Type=possessive Degree=positive Gender=masculine Number=singular Case=nominative Definiteness=no
Aspnda	Adjective Type=possessive Degree=positive Gender=neuter Number=dual Case=accusative
Aspndd	Adjective Type=possessive Degree=positive Gender=neuter Number=dual Case=dative
Aspndg	Adjective Type=possessive Degree=positive Gender=neuter Number=dual Case=genitive
Aspndi	Adjective Type=possessive Degree=positive Gender=neuter Number=dual Case=instrumental
Aspndl	Adjective Type=possessive Degree=positive Gender=neuter Number=dual Case=locative
Aspndn	Adjective Type=possessive Degree=positive Gender=neuter Number=dual Case=nominative
Aspnpa	Adjective Type=possessive Degree=positive Gender=neuter Number=plural Case=accusative
Aspnpd	Adjective Type=possessive Degree=positive Gender=neuter Number=plural Case=dative
Aspnpg	Adjective Type=possessive Degree=positive Gender=neuter Number=plural Case=genitive
Aspnpi	Adjective Type=possessive Degree=positive Gender=neuter Number=plural Case=instrumental
Aspnpl	Adjective Type=possessive Degree=positive Gender=neuter Number=plural Case=locative
Aspnpn	Adjective Type=possessive Degree=positive Gender=neuter Number=plural Case=nominative
Aspnsa	Adjective Type=possessive Degree=positive Gender=neuter Number=singular Case=accusative
Aspnsd	Adjective Type=possessive Degree=positive Gender=neuter Number=singular Case=dative
Aspnsg	Adjective Type=possessive Degree=positive Gender=neuter Number=singular Case=genitive
Aspnsi	Adjective Type=possessive Degree=positive Gender=neuter Number=singular Case=instrumental
Aspnsl	Adjective Type=possessive Degree=positive Gender=neuter Number=singular Case=locative
Aspnsn	Adjective Type=possessive Degree=positive Gender=neuter Number=singular Case=nominative
Cc	Conjunction Type=coordinating
Cs	Conjunction Type=subordinating
I	Interjection
Mdc	Numeral Form=digit Type=cardinal
Mdo	Numeral Form=digit Type=ordinal
Mlcfda	Numeral Form=letter Type=cardinal Gender=feminine Number=dual Case=accusative
Mlcfdd	Numeral Form=letter Type=cardinal Gender=feminine Number=dual Case=dative
Mlcfdg	Numeral Form=letter Type=cardinal Gender=feminine Number=dual Case=genitive
Mlcfdi	Numeral Form=letter Type=cardinal Gender=feminine Number=dual Case=instrumental
Mlcfdl	Numeral Form=letter Type=cardinal Gender=feminine Number=dual Case=locative
Mlcfdn	Numeral Form=letter Type=cardinal Gender=feminine Number=dual Case=nominative
Mlcfpa	Numeral Form=letter Type=cardinal Gender=feminine Number=plural Case=accusative
Mlcfpd	Numeral Form=letter Type=cardinal Gender=feminine Number=plural Case=dative
Mlcfpg	Numeral Form=letter Type=cardinal Gender=feminine Number=plural Case=genitive
Mlcfpi	Numeral Form=letter Type=cardinal Gender=feminine Number=plural Case=instrumental
Mlcfpl	Numeral Form=letter Type=cardinal Gender=feminine Number=plural Case=locative
Mlcfpn	Numeral Form=letter Type=cardinal Gender=feminine Number=plural Case=nominative
Mlcmda	Numeral Form=letter Type=cardinal Gender=masculine Number=dual Case=accusative
Mlcmdd	Numeral Form=letter Type=cardinal Gender=masculine Number=dual Case=dative
Mlcmdg	Numeral Form=letter Type=cardinal Gender=masculine Number=dual Case=genitive
Mlcmdi	Numeral Form=letter Type=cardinal Gender=masculine Number=dual Case=instrumental
Mlcmdl	Numeral Form=letter Type=cardinal Gender=masculine Number=dual Case=locative
Mlcmdn	Numeral Form=letter Type=cardinal Gender=masculine Number=dual Case=nominative
Mlcmpa	Numeral Form=letter Type=cardinal Gender=masculine Number=plural Case=accusative
Mlcmpd	Numeral Form=letter Type=cardinal Gender=masculine Number=plural Case=dative
Mlcmpg	Numeral Form=letter Type=cardinal Gender=masculine Number=plural Case=genitive
Mlcmpi	Numeral Form=letter Type=cardinal Gender=masculine Number=plural Case=instrumental
Mlcmpl	Numeral Form=letter Type=cardinal Gender=masculine Number=plural Case=locative
Mlcmpn	Numeral Form=letter Type=cardinal Gender=masculine Number=plural Case=nominative
Mlcnda	Numeral Form=letter Type=cardinal Gender=neuter Number=dual Case=accusative
Mlcndd	Numeral Form=letter Type=cardinal Gender=neuter Number=dual Case=dative
Mlcndg	Numeral Form=letter Type=cardinal Gender=neuter Number=dual Case=genitive
Mlcndi	Numeral Form=letter Type=cardinal Gender=neuter Number=dual Case=instrumental
Mlcndl	Numeral Form=letter Type=cardinal Gender=neuter Number=dual Case=locative
Mlcndn	Numeral Form=letter Type=cardinal Gender=neuter Number=dual Case=nominative
Mlcnpa	Numeral Form=letter Type=cardinal Gender=neuter Number=plural Case=accusative
Mlcnpd	Numeral Form=letter Type=cardinal Gender=neuter Number=plural Case=dative
Mlcnpg	Numeral Form=letter Type=cardinal Gender=neuter Number=plural Case=genitive
Mlcnpi	Numeral Form=letter Type=cardinal Gender=neuter Number=plural Case=instrumental
Mlcnpl	Numeral Form=letter Type=cardinal Gender=neuter Number=plural Case=locative
Mlcnpn	Numeral Form=letter Type=cardinal Gender=neuter Number=plural Case=nominative
Mlc-pa	Numeral Form=letter Type=cardinal Number=plural Case=accusative
Mlc-pd	Numeral Form=letter Type=cardinal Number=plural Case=dative
Mlc-pg	Numeral Form=letter Type=cardinal Number=plural Case=genitive
Mlc-pi	Numeral Form=letter Type=cardinal Number=plural Case=instrumental
Mlc-pl	Numeral Form=letter Type=cardinal Number=plural Case=locative
Mlc-pn	Numeral Form=letter Type=cardinal Number=plural Case=nominative
Mlofda	Numeral Form=letter Type=ordinal Gender=feminine Number=dual Case=accusative
Mlofdd	Numeral Form=letter Type=ordinal Gender=feminine Number=dual Case=dative
Mlofdg	Numeral Form=letter Type=ordinal Gender=feminine Number=dual Case=genitive
Mlofdi	Numeral Form=letter Type=ordinal Gender=feminine Number=dual Case=instrumental
Mlofdl	Numeral Form=letter Type=ordinal Gender=feminine Number=dual Case=locative
Mlofdn	Numeral Form=letter Type=ordinal Gender=feminine Number=dual Case=nominative
Mlofpa	Numeral Form=letter Type=ordinal Gender=feminine Number=plural Case=accusative
Mlofpd	Numeral Form=letter Type=ordinal Gender=feminine Number=plural Case=dative
Mlofpg	Numeral Form=letter Type=ordinal Gender=feminine Number=plural Case=genitive
Mlofpi	Numeral Form=letter Type=ordinal Gender=feminine Number=plural Case=instrumental
Mlofpl	Numeral Form=letter Type=ordinal Gender=feminine Number=plural Case=locative
Mlofpn	Numeral Form=letter Type=ordinal Gender=feminine Number=plural Case=nominative
Mlofsa	Numeral Form=letter Type=ordinal Gender=feminine Number=singular Case=accusative
Mlofsd	Numeral Form=letter Type=ordinal Gender=feminine Number=singular Case=dative
Mlofsg	Numeral Form=letter Type=ordinal Gender=feminine Number=singular Case=genitive
Mlofsi	Numeral Form=letter Type=ordinal Gender=feminine Number=singular Case=instrumental
Mlofsl	Numeral Form=letter Type=ordinal Gender=feminine Number=singular Case=locative
Mlofsn	Numeral Form=letter Type=ordinal Gender=feminine Number=singular Case=nominative
Mlomda	Numeral Form=letter Type=ordinal Gender=masculine Number=dual Case=accusative
Mlomdd	Numeral Form=letter Type=ordinal Gender=masculine Number=dual Case=dative
Mlomdg	Numeral Form=letter Type=ordinal Gender=masculine Number=dual Case=genitive
Mlomdi	Numeral Form=letter Type=ordinal Gender=masculine Number=dual Case=instrumental
Mlomdl	Numeral Form=letter Type=ordinal Gender=masculine Number=dual Case=locative
Mlomdn	Numeral Form=letter Type=ordinal Gender=masculine Number=dual Case=nominative
Mlompa	Numeral Form=letter Type=ordinal Gender=masculine Number=plural Case=accusative
Mlompd	Numeral Form=letter Type=ordinal Gender=masculine Number=plural Case=dative
Mlompg	Numeral Form=letter Type=ordinal Gender=masculine Number=plural Case=genitive
Mlompi	Numeral Form=letter Type=ordinal Gender=masculine Number=plural Case=instrumental
Mlompl	Numeral Form=letter Type=ordinal Gender=masculine Number=plural Case=locative
Mlompn	Numeral Form=letter Type=ordinal Gender=masculine Number=plural Case=nominative
Mlomsa	Numeral Form=letter Type=ordinal Gender=masculine Number=singular Case=accusative
Mlomsd	Numeral Form=letter Type=ordinal Gender=masculine Number=singular Case=dative
Mlomsg	Numeral Form=letter Type=ordinal Gender=masculine Number=singular Case=genitive
Mlomsi	Numeral Form=letter Type=ordinal Gender=masculine Number=singular Case=instrumental
Mlomsl	Numeral Form=letter Type=ordinal Gender=masculine Number=singular Case=locative
Mlomsn	Numeral Form=letter Type=ordinal Gender=masculine Number=singular Case=nominative
Mlonda	Numeral Form=letter Type=ordinal Gender=neuter Number=dual Case=accusative
Mlondd	Numeral Form=letter Type=ordinal Gender=neuter Number=dual Case=dative
Mlondg	Numeral Form=letter Type=ordinal Gender=neuter Number=dual Case=genitive
Mlondi	Numeral Form=letter Type=ordinal Gender=neuter Number=dual Case=instrumental
Mlondl	Numeral Form=letter Type=ordinal Gender=neuter Number=dual Case=locative
Mlondn	Numeral Form=letter Type=ordinal Gender=neuter Number=dual Case=nominative
Mlonpa	Numeral Form=letter Type=ordinal Gender=neuter Number=plural Case=accusative
Mlonpd	Numeral Form=letter Type=ordinal Gender=neuter Number=plural Case=dative
Mlonpg	Numeral Form=letter Type=ordinal Gender=neuter Number=plural Case=genitive
Mlonpi	Numeral Form=letter Type=ordinal Gender=neuter Number=plural Case=instrumental
Mlonpl	Numeral Form=letter Type=ordinal Gender=neuter Number=plural Case=locative
Mlonpn	Numeral Form=letter Type=ordinal Gender=neuter Number=plural Case=nominative
Mlonsa	Numeral Form=letter Type=ordinal Gender=neuter Number=singular Case=accusative
Mlonsd	Numeral Form=letter Type=ordinal Gender=neuter Number=singular Case=dative
Mlonsg	Numeral Form=letter Type=ordinal Gender=neuter Number=singular Case=genitive
Mlonsi	Numeral Form=letter Type=ordinal Gender=neuter Number=singular Case=instrumental
Mlonsl	Numeral Form=letter Type=ordinal Gender=neuter Number=singular Case=locative
Mlonsn	Numeral Form=letter Type=ordinal Gender=neuter Number=singular Case=nominative
Mlpfda	Numeral Form=letter Type=pronominal Gender=feminine Number=dual Case=accusative
Mlpfdd	Numeral Form=letter Type=pronominal Gender=feminine Number=dual Case=dative
Mlpfdg	Numeral Form=letter Type=pronominal Gender=feminine Number=dual Case=genitive
Mlpfdi	Numeral Form=letter Type=pronominal Gender=feminine Number=dual Case=instrumental
Mlpfdl	Numeral Form=letter Type=pronominal Gender=feminine Number=dual Case=locative
Mlpfdn	Numeral Form=letter Type=pronominal Gender=feminine Number=dual Case=nominative
Mlpfpa	Numeral Form=letter Type=pronominal Gender=feminine Number=plural Case=accusative
Mlpfpd	Numeral Form=letter Type=pronominal Gender=feminine Number=plural Case=dative
Mlpfpg	Numeral Form=letter Type=pronominal Gender=feminine Number=plural Case=genitive
Mlpfpi	Numeral Form=letter Type=pronominal Gender=feminine Number=plural Case=instrumental
Mlpfpl	Numeral Form=letter Type=pronominal Gender=feminine Number=plural Case=locative
Mlpfpn	Numeral Form=letter Type=pronominal Gender=feminine Number=plural Case=nominative
Mlpfsa	Numeral Form=letter Type=pronominal Gender=feminine Number=singular Case=accusative
Mlpfsd	Numeral Form=letter Type=pronominal Gender=feminine Number=singular Case=dative
Mlpfsg	Numeral Form=letter Type=pronominal Gender=feminine Number=singular Case=genitive
Mlpfsi	Numeral Form=letter Type=pronominal Gender=feminine Number=singular Case=instrumental
Mlpfsl	Numeral Form=letter Type=pronominal Gender=feminine Number=singular Case=locative
Mlpfsn	Numeral Form=letter Type=pronominal Gender=feminine Number=singular Case=nominative
Mlpmda	Numeral Form=letter Type=pronominal Gender=masculine Number=dual Case=accusative
Mlpmdd	Numeral Form=letter Type=pronominal Gender=masculine Number=dual Case=dative
Mlpmdg	Numeral Form=letter Type=pronominal Gender=masculine Number=dual Case=genitive
Mlpmdi	Numeral Form=letter Type=pronominal Gender=masculine Number=dual Case=instrumental
Mlpmdl	Numeral Form=letter Type=pronominal Gender=masculine Number=dual Case=locative
Mlpmdn	Numeral Form=letter Type=pronominal Gender=masculine Number=dual Case=nominative
Mlpmpa	Numeral Form=letter Type=pronominal Gender=masculine Number=plural Case=accusative
Mlpmpd	Numeral Form=letter Type=pronominal Gender=masculine Number=plural Case=dative
Mlpmpg	Numeral Form=letter Type=pronominal Gender=masculine Number=plural Case=genitive
Mlpmpi	Numeral Form=letter Type=pronominal Gender=masculine Number=plural Case=instrumental
Mlpmpl	Numeral Form=letter Type=pronominal Gender=masculine Number=plural Case=locative
Mlpmpn	Numeral Form=letter Type=pronominal Gender=masculine Number=plural Case=nominative
Mlpmsan	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=accusative Definiteness=no
Mlpmsa	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=accusative
Mlpmsay	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=accusative Definiteness=yes
Mlpmsd	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=dative
Mlpmsg	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=genitive
Mlpmsi	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=instrumental
Mlpmsl	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=locative
Mlpmsnn	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=nominative Definiteness=no
Mlpmsn	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=nominative
Mlpmsny	Numeral Form=letter Type=pronominal Gender=masculine Number=singular Case=nominative Definiteness=yes
Mlpnda	Numeral Form=letter Type=pronominal Gender=neuter Number=dual Case=accusative
Mlpndd	Numeral Form=letter Type=pronominal Gender=neuter Number=dual Case=dative
Mlpndg	Numeral Form=letter Type=pronominal Gender=neuter Number=dual Case=genitive
Mlpndi	Numeral Form=letter Type=pronominal Gender=neuter Number=dual Case=instrumental
Mlpndl	Numeral Form=letter Type=pronominal Gender=neuter Number=dual Case=locative
Mlpndn	Numeral Form=letter Type=pronominal Gender=neuter Number=dual Case=nominative
Mlpnpa	Numeral Form=letter Type=pronominal Gender=neuter Number=plural Case=accusative
Mlpnpd	Numeral Form=letter Type=pronominal Gender=neuter Number=plural Case=dative
Mlpnpg	Numeral Form=letter Type=pronominal Gender=neuter Number=plural Case=genitive
Mlpnpi	Numeral Form=letter Type=pronominal Gender=neuter Number=plural Case=instrumental
Mlpnpl	Numeral Form=letter Type=pronominal Gender=neuter Number=plural Case=locative
Mlpnpn	Numeral Form=letter Type=pronominal Gender=neuter Number=plural Case=nominative
Mlpnsa	Numeral Form=letter Type=pronominal Gender=neuter Number=singular Case=accusative
Mlpnsd	Numeral Form=letter Type=pronominal Gender=neuter Number=singular Case=dative
Mlpnsg	Numeral Form=letter Type=pronominal Gender=neuter Number=singular Case=genitive
Mlpnsi	Numeral Form=letter Type=pronominal Gender=neuter Number=singular Case=instrumental
Mlpnsl	Numeral Form=letter Type=pronominal Gender=neuter Number=singular Case=locative
Mlpnsn	Numeral Form=letter Type=pronominal Gender=neuter Number=singular Case=nominative
Mlsfda	Numeral Form=letter Type=special Gender=feminine Number=dual Case=accusative
Mlsfdd	Numeral Form=letter Type=special Gender=feminine Number=dual Case=dative
Mlsfdg	Numeral Form=letter Type=special Gender=feminine Number=dual Case=genitive
Mlsfdi	Numeral Form=letter Type=special Gender=feminine Number=dual Case=instrumental
Mlsfdl	Numeral Form=letter Type=special Gender=feminine Number=dual Case=locative
Mlsfdn	Numeral Form=letter Type=special Gender=feminine Number=dual Case=nominative
Mlsfpa	Numeral Form=letter Type=special Gender=feminine Number=plural Case=accusative
Mlsfpd	Numeral Form=letter Type=special Gender=feminine Number=plural Case=dative
Mlsfpg	Numeral Form=letter Type=special Gender=feminine Number=plural Case=genitive
Mlsfpi	Numeral Form=letter Type=special Gender=feminine Number=plural Case=instrumental
Mlsfpl	Numeral Form=letter Type=special Gender=feminine Number=plural Case=locative
Mlsfpn	Numeral Form=letter Type=special Gender=feminine Number=plural Case=nominative
Mlsfsa	Numeral Form=letter Type=special Gender=feminine Number=singular Case=accusative
Mlsfsd	Numeral Form=letter Type=special Gender=feminine Number=singular Case=dative
Mlsfsg	Numeral Form=letter Type=special Gender=feminine Number=singular Case=genitive
Mlsfsi	Numeral Form=letter Type=special Gender=feminine Number=singular Case=instrumental
Mlsfsl	Numeral Form=letter Type=special Gender=feminine Number=singular Case=locative
Mlsfsn	Numeral Form=letter Type=special Gender=feminine Number=singular Case=nominative
Mlsmda	Numeral Form=letter Type=special Gender=masculine Number=dual Case=accusative
Mlsmdd	Numeral Form=letter Type=special Gender=masculine Number=dual Case=dative
Mlsmdg	Numeral Form=letter Type=special Gender=masculine Number=dual Case=genitive
Mlsmdi	Numeral Form=letter Type=special Gender=masculine Number=dual Case=instrumental
Mlsmdl	Numeral Form=letter Type=special Gender=masculine Number=dual Case=locative
Mlsmdn	Numeral Form=letter Type=special Gender=masculine Number=dual Case=nominative
Mlsmpa	Numeral Form=letter Type=special Gender=masculine Number=plural Case=accusative
Mlsmpd	Numeral Form=letter Type=special Gender=masculine Number=plural Case=dative
Mlsmpg	Numeral Form=letter Type=special Gender=masculine Number=plural Case=genitive
Mlsmpi	Numeral Form=letter Type=special Gender=masculine Number=plural Case=instrumental
Mlsmpl	Numeral Form=letter Type=special Gender=masculine Number=plural Case=locative
Mlsmpn	Numeral Form=letter Type=special Gender=masculine Number=plural Case=nominative
Mlsmsan	Numeral Form=letter Type=special Gender=masculine Number=singular Case=accusative Definiteness=no
Mlsmsa	Numeral Form=letter Type=special Gender=masculine Number=singular Case=accusative
Mlsmsay	Numeral Form=letter Type=special Gender=masculine Number=singular Case=accusative Definiteness=yes
Mlsmsd	Numeral Form=letter Type=special Gender=masculine Number=singular Case=dative
Mlsmsg	Numeral Form=letter Type=special Gender=masculine Number=singular Case=genitive
Mlsmsi	Numeral Form=letter Type=special Gender=masculine Number=singular Case=instrumental
Mlsmsl	Numeral Form=letter Type=special Gender=masculine Number=singular Case=locative
Mlsmsnn	Numeral Form=letter Type=special Gender=masculine Number=singular Case=nominative Definiteness=no
Mlsmsny	Numeral Form=letter Type=special Gender=masculine Number=singular Case=nominative Definiteness=yes
Mlsnda	Numeral Form=letter Type=special Gender=neuter Number=dual Case=accusative
Mlsndd	Numeral Form=letter Type=special Gender=neuter Number=dual Case=dative
Mlsndg	Numeral Form=letter Type=special Gender=neuter Number=dual Case=genitive
Mlsndi	Numeral Form=letter Type=special Gender=neuter Number=dual Case=instrumental
Mlsndl	Numeral Form=letter Type=special Gender=neuter Number=dual Case=locative
Mlsndn	Numeral Form=letter Type=special Gender=neuter Number=dual Case=nominative
Mlsnpa	Numeral Form=letter Type=special Gender=neuter Number=plural Case=accusative
Mlsnpd	Numeral Form=letter Type=special Gender=neuter Number=plural Case=dative
Mlsnpg	Numeral Form=letter Type=special Gender=neuter Number=plural Case=genitive
Mlsnpi	Numeral Form=letter Type=special Gender=neuter Number=plural Case=instrumental
Mlsnpl	Numeral Form=letter Type=special Gender=neuter Number=plural Case=locative
Mlsnpn	Numeral Form=letter Type=special Gender=neuter Number=plural Case=nominative
Mlsnsa	Numeral Form=letter Type=special Gender=neuter Number=singular Case=accusative
Mlsnsd	Numeral Form=letter Type=special Gender=neuter Number=singular Case=dative
Mlsnsg	Numeral Form=letter Type=special Gender=neuter Number=singular Case=genitive
Mlsnsi	Numeral Form=letter Type=special Gender=neuter Number=singular Case=instrumental
Mlsnsl	Numeral Form=letter Type=special Gender=neuter Number=singular Case=locative
Mlsnsn	Numeral Form=letter Type=special Gender=neuter Number=singular Case=nominative
Mrc	Numeral Form=roman Type=cardinal
Mro	Numeral Form=roman Type=ordinal
Ncfda	Noun Type=common Gender=feminine Number=dual Case=accusative
Ncfdd	Noun Type=common Gender=feminine Number=dual Case=dative
Ncfdg	Noun Type=common Gender=feminine Number=dual Case=genitive
Ncfdi	Noun Type=common Gender=feminine Number=dual Case=instrumental
Ncfdl	Noun Type=common Gender=feminine Number=dual Case=locative
Ncfdn	Noun Type=common Gender=feminine Number=dual Case=nominative
Ncfpa	Noun Type=common Gender=feminine Number=plural Case=accusative
Ncfpd	Noun Type=common Gender=feminine Number=plural Case=dative
Ncfpg	Noun Type=common Gender=feminine Number=plural Case=genitive
Ncfpi	Noun Type=common Gender=feminine Number=plural Case=instrumental
Ncfpl	Noun Type=common Gender=feminine Number=plural Case=locative
Ncfpn	Noun Type=common Gender=feminine Number=plural Case=nominative
Ncfsa	Noun Type=common Gender=feminine Number=singular Case=accusative
Ncfsd	Noun Type=common Gender=feminine Number=singular Case=dative
Ncfsg	Noun Type=common Gender=feminine Number=singular Case=genitive
Ncfsi	Noun Type=common Gender=feminine Number=singular Case=instrumental
Ncfsl	Noun Type=common Gender=feminine Number=singular Case=locative
Ncfsn	Noun Type=common Gender=feminine Number=singular Case=nominative
Ncmda	Noun Type=common Gender=masculine Number=dual Case=accusative
Ncmdd	Noun Type=common Gender=masculine Number=dual Case=dative
Ncmdg	Noun Type=common Gender=masculine Number=dual Case=genitive
Ncmdi	Noun Type=common Gender=masculine Number=dual Case=instrumental
Ncmdl	Noun Type=common Gender=masculine Number=dual Case=locative
Ncmdn	Noun Type=common Gender=masculine Number=dual Case=nominative
Ncmpa	Noun Type=common Gender=masculine Number=plural Case=accusative
Ncmpd	Noun Type=common Gender=masculine Number=plural Case=dative
Ncmpg	Noun Type=common Gender=masculine Number=plural Case=genitive
Ncmpi	Noun Type=common Gender=masculine Number=plural Case=instrumental
Ncmpl	Noun Type=common Gender=masculine Number=plural Case=locative
Ncmpn	Noun Type=common Gender=masculine Number=plural Case=nominative
Ncmsan	Noun Type=common Gender=masculine Number=singular Case=accusative Animate=no
Ncmsay	Noun Type=common Gender=masculine Number=singular Case=accusative Animate=yes
Ncmsd	Noun Type=common Gender=masculine Number=singular Case=dative
Ncmsg	Noun Type=common Gender=masculine Number=singular Case=genitive
Ncmsi	Noun Type=common Gender=masculine Number=singular Case=instrumental
Ncmsl	Noun Type=common Gender=masculine Number=singular Case=locative
Ncmsn	Noun Type=common Gender=masculine Number=singular Case=nominative
Ncnda	Noun Type=common Gender=neuter Number=dual Case=accusative
Ncndd	Noun Type=common Gender=neuter Number=dual Case=dative
Ncndg	Noun Type=common Gender=neuter Number=dual Case=genitive
Ncndi	Noun Type=common Gender=neuter Number=dual Case=instrumental
Ncndl	Noun Type=common Gender=neuter Number=dual Case=locative
Ncndn	Noun Type=common Gender=neuter Number=dual Case=nominative
Ncnpa	Noun Type=common Gender=neuter Number=plural Case=accusative
Ncnpd	Noun Type=common Gender=neuter Number=plural Case=dative
Ncnpg	Noun Type=common Gender=neuter Number=plural Case=genitive
Ncnpi	Noun Type=common Gender=neuter Number=plural Case=instrumental
Ncnpl	Noun Type=common Gender=neuter Number=plural Case=locative
Ncnpn	Noun Type=common Gender=neuter Number=plural Case=nominative
Ncnsa	Noun Type=common Gender=neuter Number=singular Case=accusative
Ncnsd	Noun Type=common Gender=neuter Number=singular Case=dative
Ncnsg	Noun Type=common Gender=neuter Number=singular Case=genitive
Ncnsi	Noun Type=common Gender=neuter Number=singular Case=instrumental
Ncnsl	Noun Type=common Gender=neuter Number=singular Case=locative
Ncnsn	Noun Type=common Gender=neuter Number=singular Case=nominative
Npfda	Noun Type=proper Gender=feminine Number=dual Case=accusative
Npfdd	Noun Type=proper Gender=feminine Number=dual Case=dative
Npfdg	Noun Type=proper Gender=feminine Number=dual Case=genitive
Npfdi	Noun Type=proper Gender=feminine Number=dual Case=instrumental
Npfdl	Noun Type=proper Gender=feminine Number=dual Case=locative
Npfdn	Noun Type=proper Gender=feminine Number=dual Case=nominative
Npfpa	Noun Type=proper Gender=feminine Number=plural Case=accusative
Npfpd	Noun Type=proper Gender=feminine Number=plural Case=dative
Npfpg	Noun Type=proper Gender=feminine Number=plural Case=genitive
Npfpi	Noun Type=proper Gender=feminine Number=plural Case=instrumental
Npfpl	Noun Type=proper Gender=feminine Number=plural Case=locative
Npfpn	Noun Type=proper Gender=feminine Number=plural Case=nominative
Npfsa	Noun Type=proper Gender=feminine Number=singular Case=accusative
Npfsd	Noun Type=proper Gender=feminine Number=singular Case=dative
Npfsg	Noun Type=proper Gender=feminine Number=singular Case=genitive
Npfsi	Noun Type=proper Gender=feminine Number=singular Case=instrumental
Npfsl	Noun Type=proper Gender=feminine Number=singular Case=locative
Npfsn	Noun Type=proper Gender=feminine Number=singular Case=nominative
Npmda	Noun Type=proper Gender=masculine Number=dual Case=accusative
Npmdd	Noun Type=proper Gender=masculine Number=dual Case=dative
Npmdg	Noun Type=proper Gender=masculine Number=dual Case=genitive
Npmdi	Noun Type=proper Gender=masculine Number=dual Case=instrumental
Npmdl	Noun Type=proper Gender=masculine Number=dual Case=locative
Npmdn	Noun Type=proper Gender=masculine Number=dual Case=nominative
Npmpa	Noun Type=proper Gender=masculine Number=plural Case=accusative
Npmpd	Noun Type=proper Gender=masculine Number=plural Case=dative
Npmpg	Noun Type=proper Gender=masculine Number=plural Case=genitive
Npmpi	Noun Type=proper Gender=masculine Number=plural Case=instrumental
Npmpl	Noun Type=proper Gender=masculine Number=plural Case=locative
Npmpn	Noun Type=proper Gender=masculine Number=plural Case=nominative
Npmsan	Noun Type=proper Gender=masculine Number=singular Case=accusative Animate=no
Npmsay	Noun Type=proper Gender=masculine Number=singular Case=accusative Animate=yes
Npmsd	Noun Type=proper Gender=masculine Number=singular Case=dative
Npmsg	Noun Type=proper Gender=masculine Number=singular Case=genitive
Npmsi	Noun Type=proper Gender=masculine Number=singular Case=instrumental
Npmsl	Noun Type=proper Gender=masculine Number=singular Case=locative
Npmsn	Noun Type=proper Gender=masculine Number=singular Case=nominative
Npnpa	Noun Type=proper Gender=neuter Number=plural Case=accusative
Npnpd	Noun Type=proper Gender=neuter Number=plural Case=dative
Npnpg	Noun Type=proper Gender=neuter Number=plural Case=genitive
Npnpi	Noun Type=proper Gender=neuter Number=plural Case=instrumental
Npnpl	Noun Type=proper Gender=neuter Number=plural Case=locative
Npnpn	Noun Type=proper Gender=neuter Number=plural Case=nominative
Npnsa	Noun Type=proper Gender=neuter Number=singular Case=accusative
Npnsd	Noun Type=proper Gender=neuter Number=singular Case=dative
Npnsg	Noun Type=proper Gender=neuter Number=singular Case=genitive
Npnsi	Noun Type=proper Gender=neuter Number=singular Case=instrumental
Npnsl	Noun Type=proper Gender=neuter Number=singular Case=locative
Npnsn	Noun Type=proper Gender=neuter Number=singular Case=nominative
Pd-fda	Pronoun Type=demonstrative Gender=feminine Number=dual Case=accusative
Pd-fdd	Pronoun Type=demonstrative Gender=feminine Number=dual Case=dative
Pd-fdg	Pronoun Type=demonstrative Gender=feminine Number=dual Case=genitive
Pd-fdi	Pronoun Type=demonstrative Gender=feminine Number=dual Case=instrumental
Pd-fdl	Pronoun Type=demonstrative Gender=feminine Number=dual Case=locative
Pd-fdn	Pronoun Type=demonstrative Gender=feminine Number=dual Case=nominative
Pd-fpa	Pronoun Type=demonstrative Gender=feminine Number=plural Case=accusative
Pd-fpd	Pronoun Type=demonstrative Gender=feminine Number=plural Case=dative
Pd-fpg	Pronoun Type=demonstrative Gender=feminine Number=plural Case=genitive
Pd-fpi	Pronoun Type=demonstrative Gender=feminine Number=plural Case=instrumental
Pd-fpl	Pronoun Type=demonstrative Gender=feminine Number=plural Case=locative
Pd-fpn	Pronoun Type=demonstrative Gender=feminine Number=plural Case=nominative
Pd-fsa	Pronoun Type=demonstrative Gender=feminine Number=singular Case=accusative
Pd-fsd	Pronoun Type=demonstrative Gender=feminine Number=singular Case=dative
Pd-fsg	Pronoun Type=demonstrative Gender=feminine Number=singular Case=genitive
Pd-fsi	Pronoun Type=demonstrative Gender=feminine Number=singular Case=instrumental
Pd-fsl	Pronoun Type=demonstrative Gender=feminine Number=singular Case=locative
Pd-fsn	Pronoun Type=demonstrative Gender=feminine Number=singular Case=nominative
Pd-mda	Pronoun Type=demonstrative Gender=masculine Number=dual Case=accusative
Pd-mdd	Pronoun Type=demonstrative Gender=masculine Number=dual Case=dative
Pd-mdg	Pronoun Type=demonstrative Gender=masculine Number=dual Case=genitive
Pd-mdi	Pronoun Type=demonstrative Gender=masculine Number=dual Case=instrumental
Pd-mdl	Pronoun Type=demonstrative Gender=masculine Number=dual Case=locative
Pd-mdn	Pronoun Type=demonstrative Gender=masculine Number=dual Case=nominative
Pd-mpa	Pronoun Type=demonstrative Gender=masculine Number=plural Case=accusative
Pd-mpd	Pronoun Type=demonstrative Gender=masculine Number=plural Case=dative
Pd-mpg	Pronoun Type=demonstrative Gender=masculine Number=plural Case=genitive
Pd-mpi	Pronoun Type=demonstrative Gender=masculine Number=plural Case=instrumental
Pd-mpl	Pronoun Type=demonstrative Gender=masculine Number=plural Case=locative
Pd-mpn	Pronoun Type=demonstrative Gender=masculine Number=plural Case=nominative
Pd-msa	Pronoun Type=demonstrative Gender=masculine Number=singular Case=accusative
Pd-msd	Pronoun Type=demonstrative Gender=masculine Number=singular Case=dative
Pd-msg	Pronoun Type=demonstrative Gender=masculine Number=singular Case=genitive
Pd-msi	Pronoun Type=demonstrative Gender=masculine Number=singular Case=instrumental
Pd-msl	Pronoun Type=demonstrative Gender=masculine Number=singular Case=locative
Pd-msn	Pronoun Type=demonstrative Gender=masculine Number=singular Case=nominative
Pd-nda	Pronoun Type=demonstrative Gender=neuter Number=dual Case=accusative
Pd-ndd	Pronoun Type=demonstrative Gender=neuter Number=dual Case=dative
Pd-ndg	Pronoun Type=demonstrative Gender=neuter Number=dual Case=genitive
Pd-ndi	Pronoun Type=demonstrative Gender=neuter Number=dual Case=instrumental
Pd-ndl	Pronoun Type=demonstrative Gender=neuter Number=dual Case=locative
Pd-ndn	Pronoun Type=demonstrative Gender=neuter Number=dual Case=nominative
Pd-npa	Pronoun Type=demonstrative Gender=neuter Number=plural Case=accusative
Pd-npd	Pronoun Type=demonstrative Gender=neuter Number=plural Case=dative
Pd-npg	Pronoun Type=demonstrative Gender=neuter Number=plural Case=genitive
Pd-npi	Pronoun Type=demonstrative Gender=neuter Number=plural Case=instrumental
Pd-npl	Pronoun Type=demonstrative Gender=neuter Number=plural Case=locative
Pd-npn	Pronoun Type=demonstrative Gender=neuter Number=plural Case=nominative
Pd-nsa	Pronoun Type=demonstrative Gender=neuter Number=singular Case=accusative
Pd-nsd	Pronoun Type=demonstrative Gender=neuter Number=singular Case=dative
Pd-nsg	Pronoun Type=demonstrative Gender=neuter Number=singular Case=genitive
Pd-nsi	Pronoun Type=demonstrative Gender=neuter Number=singular Case=instrumental
Pd-nsl	Pronoun Type=demonstrative Gender=neuter Number=singular Case=locative
Pd-nsn	Pronoun Type=demonstrative Gender=neuter Number=singular Case=nominative
Pg-fda	Pronoun Type=general Gender=feminine Number=dual Case=accusative
Pg-fdd	Pronoun Type=general Gender=feminine Number=dual Case=dative
Pg-fdg	Pronoun Type=general Gender=feminine Number=dual Case=genitive
Pg-fdi	Pronoun Type=general Gender=feminine Number=dual Case=instrumental
Pg-fdl	Pronoun Type=general Gender=feminine Number=dual Case=locative
Pg-fdn	Pronoun Type=general Gender=feminine Number=dual Case=nominative
Pg-fpa	Pronoun Type=general Gender=feminine Number=plural Case=accusative
Pg-fpd	Pronoun Type=general Gender=feminine Number=plural Case=dative
Pg-fpg	Pronoun Type=general Gender=feminine Number=plural Case=genitive
Pg-fpi	Pronoun Type=general Gender=feminine Number=plural Case=instrumental
Pg-fpl	Pronoun Type=general Gender=feminine Number=plural Case=locative
Pg-fpn	Pronoun Type=general Gender=feminine Number=plural Case=nominative
Pg-fsa	Pronoun Type=general Gender=feminine Number=singular Case=accusative
Pg-fsd	Pronoun Type=general Gender=feminine Number=singular Case=dative
Pg-fsg	Pronoun Type=general Gender=feminine Number=singular Case=genitive
Pg-fsi	Pronoun Type=general Gender=feminine Number=singular Case=instrumental
Pg-fsl	Pronoun Type=general Gender=feminine Number=singular Case=locative
Pg-fsn	Pronoun Type=general Gender=feminine Number=singular Case=nominative
Pg-mda	Pronoun Type=general Gender=masculine Number=dual Case=accusative
Pg-mdd	Pronoun Type=general Gender=masculine Number=dual Case=dative
Pg-mdg	Pronoun Type=general Gender=masculine Number=dual Case=genitive
Pg-mdi	Pronoun Type=general Gender=masculine Number=dual Case=instrumental
Pg-mdl	Pronoun Type=general Gender=masculine Number=dual Case=locative
Pg-mdn	Pronoun Type=general Gender=masculine Number=dual Case=nominative
Pg-mpa	Pronoun Type=general Gender=masculine Number=plural Case=accusative
Pg-mpd	Pronoun Type=general Gender=masculine Number=plural Case=dative
Pg-mpg	Pronoun Type=general Gender=masculine Number=plural Case=genitive
Pg-mpi	Pronoun Type=general Gender=masculine Number=plural Case=instrumental
Pg-mpl	Pronoun Type=general Gender=masculine Number=plural Case=locative
Pg-mpn	Pronoun Type=general Gender=masculine Number=plural Case=nominative
Pg-msa	Pronoun Type=general Gender=masculine Number=singular Case=accusative
Pg-msd	Pronoun Type=general Gender=masculine Number=singular Case=dative
Pg-msg	Pronoun Type=general Gender=masculine Number=singular Case=genitive
Pg-msi	Pronoun Type=general Gender=masculine Number=singular Case=instrumental
Pg-msl	Pronoun Type=general Gender=masculine Number=singular Case=locative
Pg-msn	Pronoun Type=general Gender=masculine Number=singular Case=nominative
Pg-nda	Pronoun Type=general Gender=neuter Number=dual Case=accusative
Pg-ndd	Pronoun Type=general Gender=neuter Number=dual Case=dative
Pg-ndg	Pronoun Type=general Gender=neuter Number=dual Case=genitive
Pg-ndi	Pronoun Type=general Gender=neuter Number=dual Case=instrumental
Pg-ndl	Pronoun Type=general Gender=neuter Number=dual Case=locative
Pg-ndn	Pronoun Type=general Gender=neuter Number=dual Case=nominative
Pg-npa	Pronoun Type=general Gender=neuter Number=plural Case=accusative
Pg-npd	Pronoun Type=general Gender=neuter Number=plural Case=dative
Pg-npg	Pronoun Type=general Gender=neuter Number=plural Case=genitive
Pg-npi	Pronoun Type=general Gender=neuter Number=plural Case=instrumental
Pg-npl	Pronoun Type=general Gender=neuter Number=plural Case=locative
Pg-npn	Pronoun Type=general Gender=neuter Number=plural Case=nominative
Pg-nsa	Pronoun Type=general Gender=neuter Number=singular Case=accusative
Pg-nsd	Pronoun Type=general Gender=neuter Number=singular Case=dative
Pg-nsg	Pronoun Type=general Gender=neuter Number=singular Case=genitive
Pg-nsi	Pronoun Type=general Gender=neuter Number=singular Case=instrumental
Pg-nsl	Pronoun Type=general Gender=neuter Number=singular Case=locative
Pg-nsn	Pronoun Type=general Gender=neuter Number=singular Case=nominative
Pi-fda	Pronoun Type=indefinite Gender=feminine Number=dual Case=accusative
Pi-fdd	Pronoun Type=indefinite Gender=feminine Number=dual Case=dative
Pi-fdg	Pronoun Type=indefinite Gender=feminine Number=dual Case=genitive
Pi-fdi	Pronoun Type=indefinite Gender=feminine Number=dual Case=instrumental
Pi-fdl	Pronoun Type=indefinite Gender=feminine Number=dual Case=locative
Pi-fdn	Pronoun Type=indefinite Gender=feminine Number=dual Case=nominative
Pi-fpa	Pronoun Type=indefinite Gender=feminine Number=plural Case=accusative
Pi-fpd	Pronoun Type=indefinite Gender=feminine Number=plural Case=dative
Pi-fpg	Pronoun Type=indefinite Gender=feminine Number=plural Case=genitive
Pi-fpi	Pronoun Type=indefinite Gender=feminine Number=plural Case=instrumental
Pi-fpl	Pronoun Type=indefinite Gender=feminine Number=plural Case=locative
Pi-fpn	Pronoun Type=indefinite Gender=feminine Number=plural Case=nominative
Pi-fsa	Pronoun Type=indefinite Gender=feminine Number=singular Case=accusative
Pi-fsd	Pronoun Type=indefinite Gender=feminine Number=singular Case=dative
Pi-fsg	Pronoun Type=indefinite Gender=feminine Number=singular Case=genitive
Pi-fsi	Pronoun Type=indefinite Gender=feminine Number=singular Case=instrumental
Pi-fsl	Pronoun Type=indefinite Gender=feminine Number=singular Case=locative
Pi-fsn	Pronoun Type=indefinite Gender=feminine Number=singular Case=nominative
Pi-mda	Pronoun Type=indefinite Gender=masculine Number=dual Case=accusative
Pi-mdd	Pronoun Type=indefinite Gender=masculine Number=dual Case=dative
Pi-mdg	Pronoun Type=indefinite Gender=masculine Number=dual Case=genitive
Pi-mdi	Pronoun Type=indefinite Gender=masculine Number=dual Case=instrumental
Pi-mdl	Pronoun Type=indefinite Gender=masculine Number=dual Case=locative
Pi-mdn	Pronoun Type=indefinite Gender=masculine Number=dual Case=nominative
Pi-mpa	Pronoun Type=indefinite Gender=masculine Number=plural Case=accusative
Pi-mpd	Pronoun Type=indefinite Gender=masculine Number=plural Case=dative
Pi-mpg	Pronoun Type=indefinite Gender=masculine Number=plural Case=genitive
Pi-mpi	Pronoun Type=indefinite Gender=masculine Number=plural Case=instrumental
Pi-mpl	Pronoun Type=indefinite Gender=masculine Number=plural Case=locative
Pi-mpn	Pronoun Type=indefinite Gender=masculine Number=plural Case=nominative
Pi-msa	Pronoun Type=indefinite Gender=masculine Number=singular Case=accusative
Pi-msd	Pronoun Type=indefinite Gender=masculine Number=singular Case=dative
Pi-msg	Pronoun Type=indefinite Gender=masculine Number=singular Case=genitive
Pi-msi	Pronoun Type=indefinite Gender=masculine Number=singular Case=instrumental
Pi-msl	Pronoun Type=indefinite Gender=masculine Number=singular Case=locative
Pi-msn	Pronoun Type=indefinite Gender=masculine Number=singular Case=nominative
Pi-nda	Pronoun Type=indefinite Gender=neuter Number=dual Case=accusative
Pi-ndd	Pronoun Type=indefinite Gender=neuter Number=dual Case=dative
Pi-ndg	Pronoun Type=indefinite Gender=neuter Number=dual Case=genitive
Pi-ndi	Pronoun Type=indefinite Gender=neuter Number=dual Case=instrumental
Pi-ndl	Pronoun Type=indefinite Gender=neuter Number=dual Case=locative
Pi-ndn	Pronoun Type=indefinite Gender=neuter Number=dual Case=nominative
Pi-npa	Pronoun Type=indefinite Gender=neuter Number=plural Case=accusative
Pi-npd	Pronoun Type=indefinite Gender=neuter Number=plural Case=dative
Pi-npg	Pronoun Type=indefinite Gender=neuter Number=plural Case=genitive
Pi-npi	Pronoun Type=indefinite Gender=neuter Number=plural Case=instrumental
Pi-npl	Pronoun Type=indefinite Gender=neuter Number=plural Case=locative
Pi-npn	Pronoun Type=indefinite Gender=neuter Number=plural Case=nominative
Pi-nsa	Pronoun Type=indefinite Gender=neuter Number=singular Case=accusative
Pi-nsd	Pronoun Type=indefinite Gender=neuter Number=singular Case=dative
Pi-nsg	Pronoun Type=indefinite Gender=neuter Number=singular Case=genitive
Pi-nsi	Pronoun Type=indefinite Gender=neuter Number=singular Case=instrumental
Pi-nsl	Pronoun Type=indefinite Gender=neuter Number=singular Case=locative
Pi-nsn	Pronoun Type=indefinite Gender=neuter Number=singular Case=nominative
Pp1-da	Pronoun Type=personal Person=first Number=dual Case=accusative
Pp1-dd	Pronoun Type=personal Person=first Number=dual Case=dative
Pp1-dg	Pronoun Type=personal Person=first Number=dual Case=genitive
Pp1-di	Pronoun Type=personal Person=first Number=dual Case=instrumental
Pp1-dl	Pronoun Type=personal Person=first Number=dual Case=locative
Pp1fdn	Pronoun Type=personal Person=first Gender=feminine Number=dual Case=nominative
Pp1fpn	Pronoun Type=personal Person=first Gender=feminine Number=plural Case=nominative
Pp1mdn	Pronoun Type=personal Person=first Gender=masculine Number=dual Case=nominative
Pp1mpn	Pronoun Type=personal Person=first Gender=masculine Number=plural Case=nominative
Pp1-pa	Pronoun Type=personal Person=first Number=plural Case=accusative
Pp1-pd	Pronoun Type=personal Person=first Number=plural Case=dative
Pp1-pg	Pronoun Type=personal Person=first Number=plural Case=genitive
Pp1-pi	Pronoun Type=personal Person=first Number=plural Case=instrumental
Pp1-pl	Pronoun Type=personal Person=first Number=plural Case=locative
Pp1-sa--b	Pronoun Type=personal Person=first Number=singular Case=accusative Clitic=bound
Pp1-sa	Pronoun Type=personal Person=first Number=singular Case=accusative
Pp1-sa--y	Pronoun Type=personal Person=first Number=singular Case=accusative Clitic=yes
Pp1-sd	Pronoun Type=personal Person=first Number=singular Case=dative
Pp1-sd--y	Pronoun Type=personal Person=first Number=singular Case=dative Clitic=yes
Pp1-sg	Pronoun Type=personal Person=first Number=singular Case=genitive
Pp1-sg--y	Pronoun Type=personal Person=first Number=singular Case=genitive Clitic=yes
Pp1-si	Pronoun Type=personal Person=first Number=singular Case=instrumental
Pp1-sl	Pronoun Type=personal Person=first Number=singular Case=locative
Pp1-sn	Pronoun Type=personal Person=first Number=singular Case=nominative
Pp2-da	Pronoun Type=personal Person=second Number=dual Case=accusative
Pp2-dd	Pronoun Type=personal Person=second Number=dual Case=dative
Pp2-dg	Pronoun Type=personal Person=second Number=dual Case=genitive
Pp2-di	Pronoun Type=personal Person=second Number=dual Case=instrumental
Pp2-dl	Pronoun Type=personal Person=second Number=dual Case=locative
Pp2fdn	Pronoun Type=personal Person=second Gender=feminine Number=dual Case=nominative
Pp2fpn	Pronoun Type=personal Person=second Gender=feminine Number=plural Case=nominative
Pp2mdn	Pronoun Type=personal Person=second Gender=masculine Number=dual Case=nominative
Pp2mpn	Pronoun Type=personal Person=second Gender=masculine Number=plural Case=nominative
Pp2ndn	Pronoun Type=personal Person=second Gender=neuter Number=dual Case=nominative
Pp2npn	Pronoun Type=personal Person=second Gender=neuter Number=plural Case=nominative
Pp2-pa	Pronoun Type=personal Person=second Number=plural Case=accusative
Pp2-pd	Pronoun Type=personal Person=second Number=plural Case=dative
Pp2-pg	Pronoun Type=personal Person=second Number=plural Case=genitive
Pp2-pi	Pronoun Type=personal Person=second Number=plural Case=instrumental
Pp2-pl	Pronoun Type=personal Person=second Number=plural Case=locative
Pp2-sa--b	Pronoun Type=personal Person=second Number=singular Case=accusative Clitic=bound
Pp2-sa	Pronoun Type=personal Person=second Number=singular Case=accusative
Pp2-sa--y	Pronoun Type=personal Person=second Number=singular Case=accusative Clitic=yes
Pp2-sd	Pronoun Type=personal Person=second Number=singular Case=dative
Pp2-sd--y	Pronoun Type=personal Person=second Number=singular Case=dative Clitic=yes
Pp2-sg	Pronoun Type=personal Person=second Number=singular Case=genitive
Pp2-sg--y	Pronoun Type=personal Person=second Number=singular Case=genitive Clitic=yes
Pp2-si	Pronoun Type=personal Person=second Number=singular Case=instrumental
Pp2-sl	Pronoun Type=personal Person=second Number=singular Case=locative
Pp2-sn	Pronoun Type=personal Person=second Number=singular Case=nominative
Pp3fda--b	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=accusative Clitic=bound
Pp3fda	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=accusative
Pp3fda--y	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=accusative Clitic=yes
Pp3fdd	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=dative
Pp3fdd--y	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=dative Clitic=yes
Pp3fdg	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=genitive
Pp3fdg--y	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=genitive Clitic=yes
Pp3fdi	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=instrumental
Pp3fdl	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=locative
Pp3fdn	Pronoun Type=personal Person=third Gender=feminine Number=dual Case=nominative
Pp3fpa--b	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=accusative Clitic=bound
Pp3fpa	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=accusative
Pp3fpa--y	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=accusative Clitic=yes
Pp3fpd	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=dative
Pp3fpd--y	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=dative Clitic=yes
Pp3fpg	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=genitive
Pp3fpg--y	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=genitive Clitic=yes
Pp3fpi	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=instrumental
Pp3fpl	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=locative
Pp3fpn	Pronoun Type=personal Person=third Gender=feminine Number=plural Case=nominative
Pp3fsa--b	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=accusative Clitic=bound
Pp3fsa	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=accusative
Pp3fsa--y	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=accusative Clitic=yes
Pp3fsd	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=dative
Pp3fsd--y	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=dative Clitic=yes
Pp3fsg	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=genitive
Pp3fsg--y	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=genitive Clitic=yes
Pp3fsi	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=instrumental
Pp3fsl	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=locative
Pp3fsn	Pronoun Type=personal Person=third Gender=feminine Number=singular Case=nominative
Pp3mda--b	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=accusative Clitic=bound
Pp3mda	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=accusative
Pp3mda--y	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=accusative Clitic=yes
Pp3mdd	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=dative
Pp3mdd--y	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=dative Clitic=yes
Pp3mdg	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=genitive
Pp3mdg--y	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=genitive Clitic=yes
Pp3mdi	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=instrumental
Pp3mdl	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=locative
Pp3mdn	Pronoun Type=personal Person=third Gender=masculine Number=dual Case=nominative
Pp3mpa--b	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=accusative Clitic=bound
Pp3mpa	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=accusative
Pp3mpa--y	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=accusative Clitic=yes
Pp3mpd	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=dative
Pp3mpd--y	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=dative Clitic=yes
Pp3mpg	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=genitive
Pp3mpg--y	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=genitive Clitic=yes
Pp3mpi	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=instrumental
Pp3mpl	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=locative
Pp3mpn	Pronoun Type=personal Person=third Gender=masculine Number=plural Case=nominative
Pp3msa--b	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=accusative Clitic=bound
Pp3msa	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=accusative
Pp3msa--y	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=accusative Clitic=yes
Pp3msd	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=dative
Pp3msd--y	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=dative Clitic=yes
Pp3msg	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=genitive
Pp3msg--y	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=genitive Clitic=yes
Pp3msi	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=instrumental
Pp3msl	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=locative
Pp3msn	Pronoun Type=personal Person=third Gender=masculine Number=singular Case=nominative
Pp3nda--b	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=accusative Clitic=bound
Pp3nda	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=accusative
Pp3nda--y	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=accusative Clitic=yes
Pp3ndd	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=dative
Pp3ndd--y	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=dative Clitic=yes
Pp3ndg	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=genitive
Pp3ndg--y	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=genitive Clitic=yes
Pp3ndi	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=instrumental
Pp3ndl	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=locative
Pp3ndn	Pronoun Type=personal Person=third Gender=neuter Number=dual Case=nominative
Pp3npa--b	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=accusative Clitic=bound
Pp3npa	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=accusative
Pp3npa--y	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=accusative Clitic=yes
Pp3npd	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=dative
Pp3npd--y	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=dative Clitic=yes
Pp3npg	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=genitive
Pp3npg--y	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=genitive Clitic=yes
Pp3npi	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=instrumental
Pp3npl	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=locative
Pp3npn	Pronoun Type=personal Person=third Gender=neuter Number=plural Case=nominative
Pp3nsa--b	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=accusative Clitic=bound
Pp3nsa	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=accusative
Pp3nsa--y	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=accusative Clitic=yes
Pp3nsd	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=dative
Pp3nsd--y	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=dative Clitic=yes
Pp3nsg	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=genitive
Pp3nsg--y	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=genitive Clitic=yes
Pp3nsi	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=instrumental
Pp3nsl	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=locative
Pp3nsn	Pronoun Type=personal Person=third Gender=neuter Number=singular Case=nominative
Pq-fda	Pronoun Type=interrogative Gender=feminine Number=dual Case=accusative
Pq-fdd	Pronoun Type=interrogative Gender=feminine Number=dual Case=dative
Pq-fdg	Pronoun Type=interrogative Gender=feminine Number=dual Case=genitive
Pq-fdi	Pronoun Type=interrogative Gender=feminine Number=dual Case=instrumental
Pq-fdl	Pronoun Type=interrogative Gender=feminine Number=dual Case=locative
Pq-fdn	Pronoun Type=interrogative Gender=feminine Number=dual Case=nominative
Pq-fpa	Pronoun Type=interrogative Gender=feminine Number=plural Case=accusative
Pq-fpd	Pronoun Type=interrogative Gender=feminine Number=plural Case=dative
Pq-fpg	Pronoun Type=interrogative Gender=feminine Number=plural Case=genitive
Pq-fpi	Pronoun Type=interrogative Gender=feminine Number=plural Case=instrumental
Pq-fpl	Pronoun Type=interrogative Gender=feminine Number=plural Case=locative
Pq-fpn	Pronoun Type=interrogative Gender=feminine Number=plural Case=nominative
Pq-fsa	Pronoun Type=interrogative Gender=feminine Number=singular Case=accusative
Pq-fsd	Pronoun Type=interrogative Gender=feminine Number=singular Case=dative
Pq-fsg	Pronoun Type=interrogative Gender=feminine Number=singular Case=genitive
Pq-fsi	Pronoun Type=interrogative Gender=feminine Number=singular Case=instrumental
Pq-fsl	Pronoun Type=interrogative Gender=feminine Number=singular Case=locative
Pq-fsn	Pronoun Type=interrogative Gender=feminine Number=singular Case=nominative
Pq-mda	Pronoun Type=interrogative Gender=masculine Number=dual Case=accusative
Pq-mdd	Pronoun Type=interrogative Gender=masculine Number=dual Case=dative
Pq-mdg	Pronoun Type=interrogative Gender=masculine Number=dual Case=genitive
Pq-mdi	Pronoun Type=interrogative Gender=masculine Number=dual Case=instrumental
Pq-mdl	Pronoun Type=interrogative Gender=masculine Number=dual Case=locative
Pq-mdn	Pronoun Type=interrogative Gender=masculine Number=dual Case=nominative
Pq-mpa	Pronoun Type=interrogative Gender=masculine Number=plural Case=accusative
Pq-mpd	Pronoun Type=interrogative Gender=masculine Number=plural Case=dative
Pq-mpg	Pronoun Type=interrogative Gender=masculine Number=plural Case=genitive
Pq-mpi	Pronoun Type=interrogative Gender=masculine Number=plural Case=instrumental
Pq-mpl	Pronoun Type=interrogative Gender=masculine Number=plural Case=locative
Pq-mpn	Pronoun Type=interrogative Gender=masculine Number=plural Case=nominative
Pq-msa	Pronoun Type=interrogative Gender=masculine Number=singular Case=accusative
Pq-msd	Pronoun Type=interrogative Gender=masculine Number=singular Case=dative
Pq-msg	Pronoun Type=interrogative Gender=masculine Number=singular Case=genitive
Pq-msi	Pronoun Type=interrogative Gender=masculine Number=singular Case=instrumental
Pq-msl	Pronoun Type=interrogative Gender=masculine Number=singular Case=locative
Pq-msn	Pronoun Type=interrogative Gender=masculine Number=singular Case=nominative
Pq-nda	Pronoun Type=interrogative Gender=neuter Number=dual Case=accusative
Pq-ndd	Pronoun Type=interrogative Gender=neuter Number=dual Case=dative
Pq-ndg	Pronoun Type=interrogative Gender=neuter Number=dual Case=genitive
Pq-ndi	Pronoun Type=interrogative Gender=neuter Number=dual Case=instrumental
Pq-ndl	Pronoun Type=interrogative Gender=neuter Number=dual Case=locative
Pq-ndn	Pronoun Type=interrogative Gender=neuter Number=dual Case=nominative
Pq-npa	Pronoun Type=interrogative Gender=neuter Number=plural Case=accusative
Pq-npd	Pronoun Type=interrogative Gender=neuter Number=plural Case=dative
Pq-npg	Pronoun Type=interrogative Gender=neuter Number=plural Case=genitive
Pq-npi	Pronoun Type=interrogative Gender=neuter Number=plural Case=instrumental
Pq-npl	Pronoun Type=interrogative Gender=neuter Number=plural Case=locative
Pq-npn	Pronoun Type=interrogative Gender=neuter Number=plural Case=nominative
Pq-nsa	Pronoun Type=interrogative Gender=neuter Number=singular Case=accusative
Pq-nsd	Pronoun Type=interrogative Gender=neuter Number=singular Case=dative
Pq-nsg	Pronoun Type=interrogative Gender=neuter Number=singular Case=genitive
Pq-nsi	Pronoun Type=interrogative Gender=neuter Number=singular Case=instrumental
Pq-nsl	Pronoun Type=interrogative Gender=neuter Number=singular Case=locative
Pq-nsn	Pronoun Type=interrogative Gender=neuter Number=singular Case=nominative
Pr-fda	Pronoun Type=relative Gender=feminine Number=dual Case=accusative
Pr-fdd	Pronoun Type=relative Gender=feminine Number=dual Case=dative
Pr-fdg	Pronoun Type=relative Gender=feminine Number=dual Case=genitive
Pr-fdi	Pronoun Type=relative Gender=feminine Number=dual Case=instrumental
Pr-fdl	Pronoun Type=relative Gender=feminine Number=dual Case=locative
Pr-fdn	Pronoun Type=relative Gender=feminine Number=dual Case=nominative
Pr-fpa	Pronoun Type=relative Gender=feminine Number=plural Case=accusative
Pr-fpd	Pronoun Type=relative Gender=feminine Number=plural Case=dative
Pr-fpg	Pronoun Type=relative Gender=feminine Number=plural Case=genitive
Pr-fpi	Pronoun Type=relative Gender=feminine Number=plural Case=instrumental
Pr-fpl	Pronoun Type=relative Gender=feminine Number=plural Case=locative
Pr-fpn	Pronoun Type=relative Gender=feminine Number=plural Case=nominative
Pr-fsa	Pronoun Type=relative Gender=feminine Number=singular Case=accusative
Pr-fsd	Pronoun Type=relative Gender=feminine Number=singular Case=dative
Pr-fsg	Pronoun Type=relative Gender=feminine Number=singular Case=genitive
Pr-fsi	Pronoun Type=relative Gender=feminine Number=singular Case=instrumental
Pr-fsl	Pronoun Type=relative Gender=feminine Number=singular Case=locative
Pr-fsn	Pronoun Type=relative Gender=feminine Number=singular Case=nominative
Pr-mda	Pronoun Type=relative Gender=masculine Number=dual Case=accusative
Pr-mdd	Pronoun Type=relative Gender=masculine Number=dual Case=dative
Pr-mdg	Pronoun Type=relative Gender=masculine Number=dual Case=genitive
Pr-mdi	Pronoun Type=relative Gender=masculine Number=dual Case=instrumental
Pr-mdl	Pronoun Type=relative Gender=masculine Number=dual Case=locative
Pr-mdn	Pronoun Type=relative Gender=masculine Number=dual Case=nominative
Pr-mpa	Pronoun Type=relative Gender=masculine Number=plural Case=accusative
Pr-mpd	Pronoun Type=relative Gender=masculine Number=plural Case=dative
Pr-mpg	Pronoun Type=relative Gender=masculine Number=plural Case=genitive
Pr-mpi	Pronoun Type=relative Gender=masculine Number=plural Case=instrumental
Pr-mpl	Pronoun Type=relative Gender=masculine Number=plural Case=locative
Pr-mpn	Pronoun Type=relative Gender=masculine Number=plural Case=nominative
Pr-msa	Pronoun Type=relative Gender=masculine Number=singular Case=accusative
Pr-msd	Pronoun Type=relative Gender=masculine Number=singular Case=dative
Pr-msg	Pronoun Type=relative Gender=masculine Number=singular Case=genitive
Pr-msi	Pronoun Type=relative Gender=masculine Number=singular Case=instrumental
Pr-msl	Pronoun Type=relative Gender=masculine Number=singular Case=locative
Pr-msn	Pronoun Type=relative Gender=masculine Number=singular Case=nominative
Pr-nda	Pronoun Type=relative Gender=neuter Number=dual Case=accusative
Pr-ndd	Pronoun Type=relative Gender=neuter Number=dual Case=dative
Pr-ndg	Pronoun Type=relative Gender=neuter Number=dual Case=genitive
Pr-ndi	Pronoun Type=relative Gender=neuter Number=dual Case=instrumental
Pr-ndl	Pronoun Type=relative Gender=neuter Number=dual Case=locative
Pr-ndn	Pronoun Type=relative Gender=neuter Number=dual Case=nominative
Pr-npa	Pronoun Type=relative Gender=neuter Number=plural Case=accusative
Pr-npd	Pronoun Type=relative Gender=neuter Number=plural Case=dative
Pr-npg	Pronoun Type=relative Gender=neuter Number=plural Case=genitive
Pr-npi	Pronoun Type=relative Gender=neuter Number=plural Case=instrumental
Pr-npl	Pronoun Type=relative Gender=neuter Number=plural Case=locative
Pr-npn	Pronoun Type=relative Gender=neuter Number=plural Case=nominative
Pr-nsa	Pronoun Type=relative Gender=neuter Number=singular Case=accusative
Pr-nsd	Pronoun Type=relative Gender=neuter Number=singular Case=dative
Pr-nsg	Pronoun Type=relative Gender=neuter Number=singular Case=genitive
Pr-nsi	Pronoun Type=relative Gender=neuter Number=singular Case=instrumental
Pr-nsl	Pronoun Type=relative Gender=neuter Number=singular Case=locative
Pr-nsn	Pronoun Type=relative Gender=neuter Number=singular Case=nominative
Pr	Pronoun Type=relative
Pr----sm	Pronoun Type=relative Owner_Number=singular Owner_Gender=masculine
Ps1fdad	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=accusative Owner_Number=dual
Ps1fdap	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=accusative Owner_Number=plural
Ps1fdas	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=accusative Owner_Number=singular
Ps1fddd	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=dative Owner_Number=dual
Ps1fddp	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=dative Owner_Number=plural
Ps1fdds	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=dative Owner_Number=singular
Ps1fdgd	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=genitive Owner_Number=dual
Ps1fdgp	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=genitive Owner_Number=plural
Ps1fdgs	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=genitive Owner_Number=singular
Ps1fdid	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=instrumental Owner_Number=dual
Ps1fdip	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=instrumental Owner_Number=plural
Ps1fdis	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=instrumental Owner_Number=singular
Ps1fdld	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=locative Owner_Number=dual
Ps1fdlp	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=locative Owner_Number=plural
Ps1fdls	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=locative Owner_Number=singular
Ps1fdnd	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=nominative Owner_Number=dual
Ps1fdnp	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=nominative Owner_Number=plural
Ps1fdns	Pronoun Type=possessive Person=first Gender=feminine Number=dual Case=nominative Owner_Number=singular
Ps1fpad	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=accusative Owner_Number=dual
Ps1fpap	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=accusative Owner_Number=plural
Ps1fpas	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=accusative Owner_Number=singular
Ps1fpdd	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=dative Owner_Number=dual
Ps1fpdp	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=dative Owner_Number=plural
Ps1fpds	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=dative Owner_Number=singular
Ps1fpgd	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=genitive Owner_Number=dual
Ps1fpgp	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=genitive Owner_Number=plural
Ps1fpgs	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=genitive Owner_Number=singular
Ps1fpid	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=instrumental Owner_Number=dual
Ps1fpip	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=instrumental Owner_Number=plural
Ps1fpis	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=instrumental Owner_Number=singular
Ps1fpld	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=locative Owner_Number=dual
Ps1fplp	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=locative Owner_Number=plural
Ps1fpls	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=locative Owner_Number=singular
Ps1fpnd	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=nominative Owner_Number=dual
Ps1fpnp	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=nominative Owner_Number=plural
Ps1fpns	Pronoun Type=possessive Person=first Gender=feminine Number=plural Case=nominative Owner_Number=singular
Ps1fsad	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=accusative Owner_Number=dual
Ps1fsap	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=accusative Owner_Number=plural
Ps1fsas	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=accusative Owner_Number=singular
Ps1fsdd	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=dative Owner_Number=dual
Ps1fsdp	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=dative Owner_Number=plural
Ps1fsds	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=dative Owner_Number=singular
Ps1fsgd	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=genitive Owner_Number=dual
Ps1fsgp	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=genitive Owner_Number=plural
Ps1fsgs	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=genitive Owner_Number=singular
Ps1fsid	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=instrumental Owner_Number=dual
Ps1fsip	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=instrumental Owner_Number=plural
Ps1fsis	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=instrumental Owner_Number=singular
Ps1fsld	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=locative Owner_Number=dual
Ps1fslp	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=locative Owner_Number=plural
Ps1fsls	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=locative Owner_Number=singular
Ps1fsnd	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=nominative Owner_Number=dual
Ps1fsnp	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=nominative Owner_Number=plural
Ps1fsns	Pronoun Type=possessive Person=first Gender=feminine Number=singular Case=nominative Owner_Number=singular
Ps1mdad	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=accusative Owner_Number=dual
Ps1mdap	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=accusative Owner_Number=plural
Ps1mdas	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=accusative Owner_Number=singular
Ps1mddd	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=dative Owner_Number=dual
Ps1mddp	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=dative Owner_Number=plural
Ps1mdds	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=dative Owner_Number=singular
Ps1mdgd	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=genitive Owner_Number=dual
Ps1mdgp	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=genitive Owner_Number=plural
Ps1mdgs	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=genitive Owner_Number=singular
Ps1mdid	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=instrumental Owner_Number=dual
Ps1mdip	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=instrumental Owner_Number=plural
Ps1mdis	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=instrumental Owner_Number=singular
Ps1mdld	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=locative Owner_Number=dual
Ps1mdlp	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=locative Owner_Number=plural
Ps1mdls	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=locative Owner_Number=singular
Ps1mdnd	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=nominative Owner_Number=dual
Ps1mdnp	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=nominative Owner_Number=plural
Ps1mdns	Pronoun Type=possessive Person=first Gender=masculine Number=dual Case=nominative Owner_Number=singular
Ps1mpad	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=accusative Owner_Number=dual
Ps1mpap	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=accusative Owner_Number=plural
Ps1mpas	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=accusative Owner_Number=singular
Ps1mpdd	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=dative Owner_Number=dual
Ps1mpdp	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=dative Owner_Number=plural
Ps1mpds	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=dative Owner_Number=singular
Ps1mpgd	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=genitive Owner_Number=dual
Ps1mpgp	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=genitive Owner_Number=plural
Ps1mpgs	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=genitive Owner_Number=singular
Ps1mpid	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=instrumental Owner_Number=dual
Ps1mpip	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=instrumental Owner_Number=plural
Ps1mpis	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=instrumental Owner_Number=singular
Ps1mpld	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=locative Owner_Number=dual
Ps1mplp	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=locative Owner_Number=plural
Ps1mpls	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=locative Owner_Number=singular
Ps1mpnd	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=nominative Owner_Number=dual
Ps1mpnp	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=nominative Owner_Number=plural
Ps1mpns	Pronoun Type=possessive Person=first Gender=masculine Number=plural Case=nominative Owner_Number=singular
Ps1msad	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=accusative Owner_Number=dual
Ps1msap	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=accusative Owner_Number=plural
Ps1msas	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=accusative Owner_Number=singular
Ps1msdd	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=dative Owner_Number=dual
Ps1msdp	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=dative Owner_Number=plural
Ps1msds	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=dative Owner_Number=singular
Ps1msgd	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=genitive Owner_Number=dual
Ps1msgp	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=genitive Owner_Number=plural
Ps1msgs	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=genitive Owner_Number=singular
Ps1msid	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=instrumental Owner_Number=dual
Ps1msip	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=instrumental Owner_Number=plural
Ps1msis	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=instrumental Owner_Number=singular
Ps1msld	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=locative Owner_Number=dual
Ps1mslp	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=locative Owner_Number=plural
Ps1msls	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=locative Owner_Number=singular
Ps1msnd	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=nominative Owner_Number=dual
Ps1msnp	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=nominative Owner_Number=plural
Ps1msns	Pronoun Type=possessive Person=first Gender=masculine Number=singular Case=nominative Owner_Number=singular
Ps1ndad	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=accusative Owner_Number=dual
Ps1ndap	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=accusative Owner_Number=plural
Ps1ndas	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=accusative Owner_Number=singular
Ps1nddd	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=dative Owner_Number=dual
Ps1nddp	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=dative Owner_Number=plural
Ps1ndds	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=dative Owner_Number=singular
Ps1ndgd	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=genitive Owner_Number=dual
Ps1ndgp	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=genitive Owner_Number=plural
Ps1ndgs	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=genitive Owner_Number=singular
Ps1ndid	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=instrumental Owner_Number=dual
Ps1ndip	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=instrumental Owner_Number=plural
Ps1ndis	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=instrumental Owner_Number=singular
Ps1ndld	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=locative Owner_Number=dual
Ps1ndlp	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=locative Owner_Number=plural
Ps1ndls	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=locative Owner_Number=singular
Ps1ndnd	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=nominative Owner_Number=dual
Ps1ndnp	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=nominative Owner_Number=plural
Ps1ndns	Pronoun Type=possessive Person=first Gender=neuter Number=dual Case=nominative Owner_Number=singular
Ps1npad	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=accusative Owner_Number=dual
Ps1npap	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=accusative Owner_Number=plural
Ps1npas	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=accusative Owner_Number=singular
Ps1npdd	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=dative Owner_Number=dual
Ps1npdp	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=dative Owner_Number=plural
Ps1npds	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=dative Owner_Number=singular
Ps1npgd	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=genitive Owner_Number=dual
Ps1npgp	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=genitive Owner_Number=plural
Ps1npgs	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=genitive Owner_Number=singular
Ps1npid	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=instrumental Owner_Number=dual
Ps1npip	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=instrumental Owner_Number=plural
Ps1npis	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=instrumental Owner_Number=singular
Ps1npld	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=locative Owner_Number=dual
Ps1nplp	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=locative Owner_Number=plural
Ps1npls	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=locative Owner_Number=singular
Ps1npnd	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=nominative Owner_Number=dual
Ps1npnp	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=nominative Owner_Number=plural
Ps1npns	Pronoun Type=possessive Person=first Gender=neuter Number=plural Case=nominative Owner_Number=singular
Ps1nsad	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=accusative Owner_Number=dual
Ps1nsap	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=accusative Owner_Number=plural
Ps1nsas	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=accusative Owner_Number=singular
Ps1nsdd	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=dative Owner_Number=dual
Ps1nsdp	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=dative Owner_Number=plural
Ps1nsds	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=dative Owner_Number=singular
Ps1nsgd	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=genitive Owner_Number=dual
Ps1nsgp	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=genitive Owner_Number=plural
Ps1nsgs	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=genitive Owner_Number=singular
Ps1nsid	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=instrumental Owner_Number=dual
Ps1nsip	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=instrumental Owner_Number=plural
Ps1nsis	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=instrumental Owner_Number=singular
Ps1nsld	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=locative Owner_Number=dual
Ps1nslp	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=locative Owner_Number=plural
Ps1nsls	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=locative Owner_Number=singular
Ps1nsnd	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=nominative Owner_Number=dual
Ps1nsnp	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=nominative Owner_Number=plural
Ps1nsns	Pronoun Type=possessive Person=first Gender=neuter Number=singular Case=nominative Owner_Number=singular
Ps2fdad	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=accusative Owner_Number=dual
Ps2fdap	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=accusative Owner_Number=plural
Ps2fdas	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=accusative Owner_Number=singular
Ps2fddd	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=dative Owner_Number=dual
Ps2fddp	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=dative Owner_Number=plural
Ps2fdds	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=dative Owner_Number=singular
Ps2fdgd	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=genitive Owner_Number=dual
Ps2fdgp	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=genitive Owner_Number=plural
Ps2fdgs	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=genitive Owner_Number=singular
Ps2fdid	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=instrumental Owner_Number=dual
Ps2fdip	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=instrumental Owner_Number=plural
Ps2fdis	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=instrumental Owner_Number=singular
Ps2fdld	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=locative Owner_Number=dual
Ps2fdlp	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=locative Owner_Number=plural
Ps2fdls	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=locative Owner_Number=singular
Ps2fdnd	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=nominative Owner_Number=dual
Ps2fdnp	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=nominative Owner_Number=plural
Ps2fdns	Pronoun Type=possessive Person=second Gender=feminine Number=dual Case=nominative Owner_Number=singular
Ps2fpad	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=accusative Owner_Number=dual
Ps2fpap	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=accusative Owner_Number=plural
Ps2fpas	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=accusative Owner_Number=singular
Ps2fpdd	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=dative Owner_Number=dual
Ps2fpdp	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=dative Owner_Number=plural
Ps2fpds	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=dative Owner_Number=singular
Ps2fpgd	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=genitive Owner_Number=dual
Ps2fpgp	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=genitive Owner_Number=plural
Ps2fpgs	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=genitive Owner_Number=singular
Ps2fpid	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=instrumental Owner_Number=dual
Ps2fpip	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=instrumental Owner_Number=plural
Ps2fpis	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=instrumental Owner_Number=singular
Ps2fpld	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=locative Owner_Number=dual
Ps2fplp	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=locative Owner_Number=plural
Ps2fpls	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=locative Owner_Number=singular
Ps2fpnd	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=nominative Owner_Number=dual
Ps2fpnp	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=nominative Owner_Number=plural
Ps2fpns	Pronoun Type=possessive Person=second Gender=feminine Number=plural Case=nominative Owner_Number=singular
Ps2fsad	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=accusative Owner_Number=dual
Ps2fsap	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=accusative Owner_Number=plural
Ps2fsas	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=accusative Owner_Number=singular
Ps2fsdd	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=dative Owner_Number=dual
Ps2fsdp	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=dative Owner_Number=plural
Ps2fsds	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=dative Owner_Number=singular
Ps2fsgd	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=genitive Owner_Number=dual
Ps2fsgp	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=genitive Owner_Number=plural
Ps2fsgs	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=genitive Owner_Number=singular
Ps2fsid	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=instrumental Owner_Number=dual
Ps2fsip	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=instrumental Owner_Number=plural
Ps2fsis	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=instrumental Owner_Number=singular
Ps2fsld	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=locative Owner_Number=dual
Ps2fslp	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=locative Owner_Number=plural
Ps2fsls	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=locative Owner_Number=singular
Ps2fsnd	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=nominative Owner_Number=dual
Ps2fsnp	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=nominative Owner_Number=plural
Ps2fsns	Pronoun Type=possessive Person=second Gender=feminine Number=singular Case=nominative Owner_Number=singular
Ps2mdad	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=accusative Owner_Number=dual
Ps2mdap	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=accusative Owner_Number=plural
Ps2mdas	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=accusative Owner_Number=singular
Ps2mddd	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=dative Owner_Number=dual
Ps2mddp	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=dative Owner_Number=plural
Ps2mdds	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=dative Owner_Number=singular
Ps2mdgd	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=genitive Owner_Number=dual
Ps2mdgp	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=genitive Owner_Number=plural
Ps2mdgs	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=genitive Owner_Number=singular
Ps2mdid	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=instrumental Owner_Number=dual
Ps2mdip	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=instrumental Owner_Number=plural
Ps2mdis	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=instrumental Owner_Number=singular
Ps2mdld	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=locative Owner_Number=dual
Ps2mdlp	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=locative Owner_Number=plural
Ps2mdls	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=locative Owner_Number=singular
Ps2mdnd	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=nominative Owner_Number=dual
Ps2mdnp	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=nominative Owner_Number=plural
Ps2mdns	Pronoun Type=possessive Person=second Gender=masculine Number=dual Case=nominative Owner_Number=singular
Ps2mpad	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=accusative Owner_Number=dual
Ps2mpap	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=accusative Owner_Number=plural
Ps2mpas	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=accusative Owner_Number=singular
Ps2mpdd	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=dative Owner_Number=dual
Ps2mpdp	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=dative Owner_Number=plural
Ps2mpds	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=dative Owner_Number=singular
Ps2mpgd	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=genitive Owner_Number=dual
Ps2mpgp	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=genitive Owner_Number=plural
Ps2mpgs	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=genitive Owner_Number=singular
Ps2mpid	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=instrumental Owner_Number=dual
Ps2mpip	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=instrumental Owner_Number=plural
Ps2mpis	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=instrumental Owner_Number=singular
Ps2mpld	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=locative Owner_Number=dual
Ps2mplp	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=locative Owner_Number=plural
Ps2mpls	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=locative Owner_Number=singular
Ps2mpnd	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=nominative Owner_Number=dual
Ps2mpnp	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=nominative Owner_Number=plural
Ps2mpns	Pronoun Type=possessive Person=second Gender=masculine Number=plural Case=nominative Owner_Number=singular
Ps2msad	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=accusative Owner_Number=dual
Ps2msap	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=accusative Owner_Number=plural
Ps2msas	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=accusative Owner_Number=singular
Ps2msdd	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=dative Owner_Number=dual
Ps2msdp	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=dative Owner_Number=plural
Ps2msds	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=dative Owner_Number=singular
Ps2msgd	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=genitive Owner_Number=dual
Ps2msgp	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=genitive Owner_Number=plural
Ps2msgs	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=genitive Owner_Number=singular
Ps2msid	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=instrumental Owner_Number=dual
Ps2msip	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=instrumental Owner_Number=plural
Ps2msis	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=instrumental Owner_Number=singular
Ps2msld	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=locative Owner_Number=dual
Ps2mslp	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=locative Owner_Number=plural
Ps2msls	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=locative Owner_Number=singular
Ps2msnd	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=nominative Owner_Number=dual
Ps2msnp	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=nominative Owner_Number=plural
Ps2msns	Pronoun Type=possessive Person=second Gender=masculine Number=singular Case=nominative Owner_Number=singular
Ps2ndad	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=accusative Owner_Number=dual
Ps2ndap	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=accusative Owner_Number=plural
Ps2ndas	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=accusative Owner_Number=singular
Ps2nddd	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=dative Owner_Number=dual
Ps2nddp	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=dative Owner_Number=plural
Ps2ndds	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=dative Owner_Number=singular
Ps2ndgd	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=genitive Owner_Number=dual
Ps2ndgp	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=genitive Owner_Number=plural
Ps2ndgs	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=genitive Owner_Number=singular
Ps2ndid	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=instrumental Owner_Number=dual
Ps2ndip	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=instrumental Owner_Number=plural
Ps2ndis	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=instrumental Owner_Number=singular
Ps2ndld	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=locative Owner_Number=dual
Ps2ndlp	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=locative Owner_Number=plural
Ps2ndls	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=locative Owner_Number=singular
Ps2ndnd	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=nominative Owner_Number=dual
Ps2ndnp	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=nominative Owner_Number=plural
Ps2ndns	Pronoun Type=possessive Person=second Gender=neuter Number=dual Case=nominative Owner_Number=singular
Ps2npad	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=accusative Owner_Number=dual
Ps2npap	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=accusative Owner_Number=plural
Ps2npas	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=accusative Owner_Number=singular
Ps2npdd	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=dative Owner_Number=dual
Ps2npdp	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=dative Owner_Number=plural
Ps2npds	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=dative Owner_Number=singular
Ps2npgd	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=genitive Owner_Number=dual
Ps2npgp	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=genitive Owner_Number=plural
Ps2npgs	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=genitive Owner_Number=singular
Ps2npid	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=instrumental Owner_Number=dual
Ps2npip	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=instrumental Owner_Number=plural
Ps2npis	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=instrumental Owner_Number=singular
Ps2npld	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=locative Owner_Number=dual
Ps2nplp	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=locative Owner_Number=plural
Ps2npls	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=locative Owner_Number=singular
Ps2npnd	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=nominative Owner_Number=dual
Ps2npnp	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=nominative Owner_Number=plural
Ps2npns	Pronoun Type=possessive Person=second Gender=neuter Number=plural Case=nominative Owner_Number=singular
Ps2nsad	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=accusative Owner_Number=dual
Ps2nsap	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=accusative Owner_Number=plural
Ps2nsas	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=accusative Owner_Number=singular
Ps2nsdd	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=dative Owner_Number=dual
Ps2nsdp	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=dative Owner_Number=plural
Ps2nsds	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=dative Owner_Number=singular
Ps2nsgd	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=genitive Owner_Number=dual
Ps2nsgp	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=genitive Owner_Number=plural
Ps2nsgs	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=genitive Owner_Number=singular
Ps2nsid	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=instrumental Owner_Number=dual
Ps2nsip	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=instrumental Owner_Number=plural
Ps2nsis	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=instrumental Owner_Number=singular
Ps2nsld	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=locative Owner_Number=dual
Ps2nslp	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=locative Owner_Number=plural
Ps2nsls	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=locative Owner_Number=singular
Ps2nsnd	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=nominative Owner_Number=dual
Ps2nsnp	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=nominative Owner_Number=plural
Ps2nsns	Pronoun Type=possessive Person=second Gender=neuter Number=singular Case=nominative Owner_Number=singular
Ps3fdad	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=accusative Owner_Number=dual
Ps3fdap	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=accusative Owner_Number=plural
Ps3fdasf	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3fdasm	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3fdasn	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3fddd	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=dative Owner_Number=dual
Ps3fddp	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=dative Owner_Number=plural
Ps3fddsf	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3fddsm	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3fddsn	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3fdgd	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=genitive Owner_Number=dual
Ps3fdgp	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=genitive Owner_Number=plural
Ps3fdgsf	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3fdgsm	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3fdgsn	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3fdid	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=instrumental Owner_Number=dual
Ps3fdip	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=instrumental Owner_Number=plural
Ps3fdisf	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3fdism	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3fdisn	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3fdld	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=locative Owner_Number=dual
Ps3fdlp	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=locative Owner_Number=plural
Ps3fdlsf	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3fdlsm	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3fdlsn	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3fdnd	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=nominative Owner_Number=dual
Ps3fdnp	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=nominative Owner_Number=plural
Ps3fdnsf	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3fdnsm	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3fdnsn	Pronoun Type=possessive Person=third Gender=feminine Number=dual Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3fpad	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=accusative Owner_Number=dual
Ps3fpap	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=accusative Owner_Number=plural
Ps3fpasf	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3fpasm	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3fpasn	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3fpdd	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=dative Owner_Number=dual
Ps3fpdp	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=dative Owner_Number=plural
Ps3fpdsf	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3fpdsm	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3fpdsn	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3fpgd	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=genitive Owner_Number=dual
Ps3fpgp	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=genitive Owner_Number=plural
Ps3fpgsf	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3fpgsm	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3fpgsn	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3fpid	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=instrumental Owner_Number=dual
Ps3fpip	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=instrumental Owner_Number=plural
Ps3fpisf	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3fpism	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3fpisn	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3fpld	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=locative Owner_Number=dual
Ps3fplp	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=locative Owner_Number=plural
Ps3fplsf	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3fplsm	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3fplsn	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3fpnd	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=nominative Owner_Number=dual
Ps3fpnp	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=nominative Owner_Number=plural
Ps3fpnsf	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3fpnsm	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3fpnsn	Pronoun Type=possessive Person=third Gender=feminine Number=plural Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3fsad	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=accusative Owner_Number=dual
Ps3fsap	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=accusative Owner_Number=plural
Ps3fsasf	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3fsasm	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3fsasn	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3fsdd	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=dative Owner_Number=dual
Ps3fsdp	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=dative Owner_Number=plural
Ps3fsdsf	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3fsdsm	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3fsdsn	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3fsgd	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=genitive Owner_Number=dual
Ps3fsgp	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=genitive Owner_Number=plural
Ps3fsgsf	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3fsgsm	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3fsgsn	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3fsid	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=instrumental Owner_Number=dual
Ps3fsip	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=instrumental Owner_Number=plural
Ps3fsisf	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3fsism	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3fsisn	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3fsld	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=locative Owner_Number=dual
Ps3fslp	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=locative Owner_Number=plural
Ps3fslsf	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3fslsm	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3fslsn	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3fsnd	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=nominative Owner_Number=dual
Ps3fsnp	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=nominative Owner_Number=plural
Ps3fsnsf	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3fsnsm	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3fsnsn	Pronoun Type=possessive Person=third Gender=feminine Number=singular Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3mdad	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=accusative Owner_Number=dual
Ps3mdap	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=accusative Owner_Number=plural
Ps3mdasf	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3mdasm	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3mdasn	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3mddd	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=dative Owner_Number=dual
Ps3mddp	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=dative Owner_Number=plural
Ps3mddsf	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3mddsm	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3mddsn	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3mdgd	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=genitive Owner_Number=dual
Ps3mdgp	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=genitive Owner_Number=plural
Ps3mdgsf	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3mdgsm	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3mdgsn	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3mdid	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=instrumental Owner_Number=dual
Ps3mdip	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=instrumental Owner_Number=plural
Ps3mdisf	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3mdism	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3mdisn	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3mdld	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=locative Owner_Number=dual
Ps3mdlp	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=locative Owner_Number=plural
Ps3mdlsf	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3mdlsm	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3mdlsn	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3mdnd	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=nominative Owner_Number=dual
Ps3mdnp	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=nominative Owner_Number=plural
Ps3mdnsf	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3mdnsm	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3mdnsn	Pronoun Type=possessive Person=third Gender=masculine Number=dual Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3mpad	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=accusative Owner_Number=dual
Ps3mpap	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=accusative Owner_Number=plural
Ps3mpasf	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3mpasm	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3mpasn	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3mpdd	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=dative Owner_Number=dual
Ps3mpdp	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=dative Owner_Number=plural
Ps3mpdsf	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3mpdsm	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3mpdsn	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3mpgd	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=genitive Owner_Number=dual
Ps3mpgp	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=genitive Owner_Number=plural
Ps3mpgsf	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3mpgsm	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3mpgsn	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3mpid	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=instrumental Owner_Number=dual
Ps3mpip	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=instrumental Owner_Number=plural
Ps3mpisf	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3mpism	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3mpisn	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3mpld	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=locative Owner_Number=dual
Ps3mplp	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=locative Owner_Number=plural
Ps3mplsf	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3mplsm	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3mplsn	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3mpnd	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=nominative Owner_Number=dual
Ps3mpnp	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=nominative Owner_Number=plural
Ps3mpnsf	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3mpnsm	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3mpnsn	Pronoun Type=possessive Person=third Gender=masculine Number=plural Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3msad	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=accusative Owner_Number=dual
Ps3msap	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=accusative Owner_Number=plural
Ps3msasf	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3msasm	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3msasn	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3msdd	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=dative Owner_Number=dual
Ps3msdp	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=dative Owner_Number=plural
Ps3msdsf	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3msdsm	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3msdsn	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3msgd	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=genitive Owner_Number=dual
Ps3msgp	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=genitive Owner_Number=plural
Ps3msgsf	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3msgsm	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3msgsn	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3msid	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=instrumental Owner_Number=dual
Ps3msip	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=instrumental Owner_Number=plural
Ps3msisf	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3msism	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3msisn	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3msld	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=locative Owner_Number=dual
Ps3mslp	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=locative Owner_Number=plural
Ps3mslsf	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3mslsm	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3mslsn	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3msnd	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=nominative Owner_Number=dual
Ps3msnp	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=nominative Owner_Number=plural
Ps3msnsf	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3msnsm	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3msnsn	Pronoun Type=possessive Person=third Gender=masculine Number=singular Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3ndad	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=accusative Owner_Number=dual
Ps3ndap	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=accusative Owner_Number=plural
Ps3ndasf	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3ndasm	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3ndasn	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3nddd	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=dative Owner_Number=dual
Ps3nddp	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=dative Owner_Number=plural
Ps3nddsf	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3nddsm	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3nddsn	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3ndgd	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=genitive Owner_Number=dual
Ps3ndgp	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=genitive Owner_Number=plural
Ps3ndgsf	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3ndgsm	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3ndgsn	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3ndid	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=instrumental Owner_Number=dual
Ps3ndip	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=instrumental Owner_Number=plural
Ps3ndisf	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3ndism	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3ndisn	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3ndld	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=locative Owner_Number=dual
Ps3ndlp	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=locative Owner_Number=plural
Ps3ndlsf	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3ndlsm	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3ndlsn	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3ndnd	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=nominative Owner_Number=dual
Ps3ndnp	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=nominative Owner_Number=plural
Ps3ndnsf	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3ndnsm	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3ndnsn	Pronoun Type=possessive Person=third Gender=neuter Number=dual Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3npad	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=accusative Owner_Number=dual
Ps3npap	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=accusative Owner_Number=plural
Ps3npasf	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3npasm	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3npasn	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3npdd	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=dative Owner_Number=dual
Ps3npdp	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=dative Owner_Number=plural
Ps3npdsf	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3npdsm	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3npdsn	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3npgd	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=genitive Owner_Number=dual
Ps3npgp	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=genitive Owner_Number=plural
Ps3npgsf	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3npgsm	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3npgsn	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3npid	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=instrumental Owner_Number=dual
Ps3npip	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=instrumental Owner_Number=plural
Ps3npisf	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3npism	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3npisn	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3npld	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=locative Owner_Number=dual
Ps3nplp	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=locative Owner_Number=plural
Ps3nplsf	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3nplsm	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3nplsn	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3npnd	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=nominative Owner_Number=dual
Ps3npnp	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=nominative Owner_Number=plural
Ps3npnsf	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3npnsm	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3npnsn	Pronoun Type=possessive Person=third Gender=neuter Number=plural Case=nominative Owner_Number=singular Owner_Gender=neuter
Ps3nsad	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=accusative Owner_Number=dual
Ps3nsap	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=accusative Owner_Number=plural
Ps3nsasf	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=accusative Owner_Number=singular Owner_Gender=feminine
Ps3nsasm	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=accusative Owner_Number=singular Owner_Gender=masculine
Ps3nsasn	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=accusative Owner_Number=singular Owner_Gender=neuter
Ps3nsdd	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=dative Owner_Number=dual
Ps3nsdp	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=dative Owner_Number=plural
Ps3nsdsf	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=dative Owner_Number=singular Owner_Gender=feminine
Ps3nsdsm	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=dative Owner_Number=singular Owner_Gender=masculine
Ps3nsdsn	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=dative Owner_Number=singular Owner_Gender=neuter
Ps3nsgd	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=genitive Owner_Number=dual
Ps3nsgp	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=genitive Owner_Number=plural
Ps3nsgsf	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=genitive Owner_Number=singular Owner_Gender=feminine
Ps3nsgsm	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=genitive Owner_Number=singular Owner_Gender=masculine
Ps3nsgsn	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=genitive Owner_Number=singular Owner_Gender=neuter
Ps3nsid	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=instrumental Owner_Number=dual
Ps3nsip	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=instrumental Owner_Number=plural
Ps3nsisf	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=instrumental Owner_Number=singular Owner_Gender=feminine
Ps3nsism	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=instrumental Owner_Number=singular Owner_Gender=masculine
Ps3nsisn	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=instrumental Owner_Number=singular Owner_Gender=neuter
Ps3nsld	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=locative Owner_Number=dual
Ps3nslp	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=locative Owner_Number=plural
Ps3nslsf	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=locative Owner_Number=singular Owner_Gender=feminine
Ps3nslsm	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=locative Owner_Number=singular Owner_Gender=masculine
Ps3nslsn	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=locative Owner_Number=singular Owner_Gender=neuter
Ps3nsnd	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=nominative Owner_Number=dual
Ps3nsnp	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=nominative Owner_Number=plural
Ps3nsnsf	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=nominative Owner_Number=singular Owner_Gender=feminine
Ps3nsnsm	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=nominative Owner_Number=singular Owner_Gender=masculine
Ps3nsnsn	Pronoun Type=possessive Person=third Gender=neuter Number=singular Case=nominative Owner_Number=singular Owner_Gender=neuter
Px---a--b	Pronoun Type=reflexive Case=accusative Clitic=bound
Px---a	Pronoun Type=reflexive Case=accusative
Px---d	Pronoun Type=reflexive Case=dative
Px---d--y	Pronoun Type=reflexive Case=dative Clitic=yes
Px-fda	Pronoun Type=reflexive Gender=feminine Number=dual Case=accusative
Px-fdd	Pronoun Type=reflexive Gender=feminine Number=dual Case=dative
Px-fdg	Pronoun Type=reflexive Gender=feminine Number=dual Case=genitive
Px-fdi	Pronoun Type=reflexive Gender=feminine Number=dual Case=instrumental
Px-fdl	Pronoun Type=reflexive Gender=feminine Number=dual Case=locative
Px-fdn	Pronoun Type=reflexive Gender=feminine Number=dual Case=nominative
Px-fpa	Pronoun Type=reflexive Gender=feminine Number=plural Case=accusative
Px-fpd	Pronoun Type=reflexive Gender=feminine Number=plural Case=dative
Px-fpg	Pronoun Type=reflexive Gender=feminine Number=plural Case=genitive
Px-fpi	Pronoun Type=reflexive Gender=feminine Number=plural Case=instrumental
Px-fpl	Pronoun Type=reflexive Gender=feminine Number=plural Case=locative
Px-fpn	Pronoun Type=reflexive Gender=feminine Number=plural Case=nominative
Px-fsa	Pronoun Type=reflexive Gender=feminine Number=singular Case=accusative
Px-fsd	Pronoun Type=reflexive Gender=feminine Number=singular Case=dative
Px-fsg	Pronoun Type=reflexive Gender=feminine Number=singular Case=genitive
Px-fsi	Pronoun Type=reflexive Gender=feminine Number=singular Case=instrumental
Px-fsl	Pronoun Type=reflexive Gender=feminine Number=singular Case=locative
Px-fsn	Pronoun Type=reflexive Gender=feminine Number=singular Case=nominative
Px---g	Pronoun Type=reflexive Case=genitive
Px---i	Pronoun Type=reflexive Case=instrumental
Px---l	Pronoun Type=reflexive Case=locative
Px-mda	Pronoun Type=reflexive Gender=masculine Number=dual Case=accusative
Px-mdd	Pronoun Type=reflexive Gender=masculine Number=dual Case=dative
Px-mdg	Pronoun Type=reflexive Gender=masculine Number=dual Case=genitive
Px-mdi	Pronoun Type=reflexive Gender=masculine Number=dual Case=instrumental
Px-mdl	Pronoun Type=reflexive Gender=masculine Number=dual Case=locative
Px-mdn	Pronoun Type=reflexive Gender=masculine Number=dual Case=nominative
Px-mpa	Pronoun Type=reflexive Gender=masculine Number=plural Case=accusative
Px-mpd	Pronoun Type=reflexive Gender=masculine Number=plural Case=dative
Px-mpg	Pronoun Type=reflexive Gender=masculine Number=plural Case=genitive
Px-mpi	Pronoun Type=reflexive Gender=masculine Number=plural Case=instrumental
Px-mpl	Pronoun Type=reflexive Gender=masculine Number=plural Case=locative
Px-mpn	Pronoun Type=reflexive Gender=masculine Number=plural Case=nominative
Px-msa	Pronoun Type=reflexive Gender=masculine Number=singular Case=accusative
Px-msd	Pronoun Type=reflexive Gender=masculine Number=singular Case=dative
Px-msg	Pronoun Type=reflexive Gender=masculine Number=singular Case=genitive
Px-msi	Pronoun Type=reflexive Gender=masculine Number=singular Case=instrumental
Px-msl	Pronoun Type=reflexive Gender=masculine Number=singular Case=locative
Px-msn	Pronoun Type=reflexive Gender=masculine Number=singular Case=nominative
Px-nda	Pronoun Type=reflexive Gender=neuter Number=dual Case=accusative
Px-ndd	Pronoun Type=reflexive Gender=neuter Number=dual Case=dative
Px-ndg	Pronoun Type=reflexive Gender=neuter Number=dual Case=genitive
Px-ndi	Pronoun Type=reflexive Gender=neuter Number=dual Case=instrumental
Px-ndl	Pronoun Type=reflexive Gender=neuter Number=dual Case=locative
Px-ndn	Pronoun Type=reflexive Gender=neuter Number=dual Case=nominative
Px-npa	Pronoun Type=reflexive Gender=neuter Number=plural Case=accusative
Px-npd	Pronoun Type=reflexive Gender=neuter Number=plural Case=dative
Px-npg	Pronoun Type=reflexive Gender=neuter Number=plural Case=genitive
Px-npi	Pronoun Type=reflexive Gender=neuter Number=plural Case=instrumental
Px-npl	Pronoun Type=reflexive Gender=neuter Number=plural Case=locative
Px-npn	Pronoun Type=reflexive Gender=neuter Number=plural Case=nominative
Px-nsa	Pronoun Type=reflexive Gender=neuter Number=singular Case=accusative
Px-nsd	Pronoun Type=reflexive Gender=neuter Number=singular Case=dative
Px-nsg	Pronoun Type=reflexive Gender=neuter Number=singular Case=genitive
Px-nsi	Pronoun Type=reflexive Gender=neuter Number=singular Case=instrumental
Px-nsl	Pronoun Type=reflexive Gender=neuter Number=singular Case=locative
Px-nsn	Pronoun Type=reflexive Gender=neuter Number=singular Case=nominative
Px------y	Pronoun Type=reflexive Clitic=yes
Pz-fda	Pronoun Type=negative Gender=feminine Number=dual Case=accusative
Pz-fdd	Pronoun Type=negative Gender=feminine Number=dual Case=dative
Pz-fdg	Pronoun Type=negative Gender=feminine Number=dual Case=genitive
Pz-fdi	Pronoun Type=negative Gender=feminine Number=dual Case=instrumental
Pz-fdl	Pronoun Type=negative Gender=feminine Number=dual Case=locative
Pz-fdn	Pronoun Type=negative Gender=feminine Number=dual Case=nominative
Pz-fpa	Pronoun Type=negative Gender=feminine Number=plural Case=accusative
Pz-fpd	Pronoun Type=negative Gender=feminine Number=plural Case=dative
Pz-fpg	Pronoun Type=negative Gender=feminine Number=plural Case=genitive
Pz-fpi	Pronoun Type=negative Gender=feminine Number=plural Case=instrumental
Pz-fpl	Pronoun Type=negative Gender=feminine Number=plural Case=locative
Pz-fpn	Pronoun Type=negative Gender=feminine Number=plural Case=nominative
Pz-fsa	Pronoun Type=negative Gender=feminine Number=singular Case=accusative
Pz-fsd	Pronoun Type=negative Gender=feminine Number=singular Case=dative
Pz-fsg	Pronoun Type=negative Gender=feminine Number=singular Case=genitive
Pz-fsi	Pronoun Type=negative Gender=feminine Number=singular Case=instrumental
Pz-fsl	Pronoun Type=negative Gender=feminine Number=singular Case=locative
Pz-fsn	Pronoun Type=negative Gender=feminine Number=singular Case=nominative
Pz-mda	Pronoun Type=negative Gender=masculine Number=dual Case=accusative
Pz-mdd	Pronoun Type=negative Gender=masculine Number=dual Case=dative
Pz-mdg	Pronoun Type=negative Gender=masculine Number=dual Case=genitive
Pz-mdi	Pronoun Type=negative Gender=masculine Number=dual Case=instrumental
Pz-mdl	Pronoun Type=negative Gender=masculine Number=dual Case=locative
Pz-mdn	Pronoun Type=negative Gender=masculine Number=dual Case=nominative
Pz-mpa	Pronoun Type=negative Gender=masculine Number=plural Case=accusative
Pz-mpd	Pronoun Type=negative Gender=masculine Number=plural Case=dative
Pz-mpg	Pronoun Type=negative Gender=masculine Number=plural Case=genitive
Pz-mpi	Pronoun Type=negative Gender=masculine Number=plural Case=instrumental
Pz-mpl	Pronoun Type=negative Gender=masculine Number=plural Case=locative
Pz-mpn	Pronoun Type=negative Gender=masculine Number=plural Case=nominative
Pz-msa	Pronoun Type=negative Gender=masculine Number=singular Case=accusative
Pz-msd	Pronoun Type=negative Gender=masculine Number=singular Case=dative
Pz-msg	Pronoun Type=negative Gender=masculine Number=singular Case=genitive
Pz-msi	Pronoun Type=negative Gender=masculine Number=singular Case=instrumental
Pz-msl	Pronoun Type=negative Gender=masculine Number=singular Case=locative
Pz-msn	Pronoun Type=negative Gender=masculine Number=singular Case=nominative
Pz-nda	Pronoun Type=negative Gender=neuter Number=dual Case=accusative
Pz-ndd	Pronoun Type=negative Gender=neuter Number=dual Case=dative
Pz-ndg	Pronoun Type=negative Gender=neuter Number=dual Case=genitive
Pz-ndi	Pronoun Type=negative Gender=neuter Number=dual Case=instrumental
Pz-ndl	Pronoun Type=negative Gender=neuter Number=dual Case=locative
Pz-ndn	Pronoun Type=negative Gender=neuter Number=dual Case=nominative
Pz-npa	Pronoun Type=negative Gender=neuter Number=plural Case=accusative
Pz-npd	Pronoun Type=negative Gender=neuter Number=plural Case=dative
Pz-npg	Pronoun Type=negative Gender=neuter Number=plural Case=genitive
Pz-npi	Pronoun Type=negative Gender=neuter Number=plural Case=instrumental
Pz-npl	Pronoun Type=negative Gender=neuter Number=plural Case=locative
Pz-npn	Pronoun Type=negative Gender=neuter Number=plural Case=nominative
Pz-nsa	Pronoun Type=negative Gender=neuter Number=singular Case=accusative
Pz-nsd	Pronoun Type=negative Gender=neuter Number=singular Case=dative
Pz-nsg	Pronoun Type=negative Gender=neuter Number=singular Case=genitive
Pz-nsi	Pronoun Type=negative Gender=neuter Number=singular Case=instrumental
Pz-nsl	Pronoun Type=negative Gender=neuter Number=singular Case=locative
Pz-nsn	Pronoun Type=negative Gender=neuter Number=singular Case=nominative
Q	Particle
Rgc	Adverb Type=general Degree=comparative
Rgp	Adverb Type=general Degree=positive
Rgs	Adverb Type=general Degree=superlative
Rr	Adverb Type=participle
Sa	Adposition Case=accusative
Sd	Adposition Case=dative
Sg	Adposition Case=genitive
Si	Adposition Case=instrumental
Sl	Adposition Case=locative
Sn	Adposition Case=nominative
Va-c	Verb Type=auxiliary VForm=conditional
Va-c---y	Verb Type=auxiliary VForm=conditional Negative=yes
Va-f1d-n	Verb Type=auxiliary VForm=future Person=first Number=dual Negative=no
Va-f1d	Verb Type=auxiliary VForm=future Person=first Number=dual
Va-f1d-y	Verb Type=auxiliary VForm=future Person=first Number=dual Negative=yes
Va-f1p-n	Verb Type=auxiliary VForm=future Person=first Number=plural Negative=no
Va-f1p-y	Verb Type=auxiliary VForm=future Person=first Number=plural Negative=yes
Va-f1s-n	Verb Type=auxiliary VForm=future Person=first Number=singular Negative=no
Va-f1s-y	Verb Type=auxiliary VForm=future Person=first Number=singular Negative=yes
Va-f2d-n	Verb Type=auxiliary VForm=future Person=second Number=dual Negative=no
Va-f2p-n	Verb Type=auxiliary VForm=future Person=second Number=plural Negative=no
Va-f2s-n	Verb Type=auxiliary VForm=future Person=second Number=singular Negative=no
Va-f2s-y	Verb Type=auxiliary VForm=future Person=second Number=singular Negative=yes
Va-f3d-n	Verb Type=auxiliary VForm=future Person=third Number=dual Negative=no
Va-f3p-n	Verb Type=auxiliary VForm=future Person=third Number=plural Negative=no
Va-f3p-y	Verb Type=auxiliary VForm=future Person=third Number=plural Negative=yes
Va-f3s-n	Verb Type=auxiliary VForm=future Person=third Number=singular Negative=no
Va-f3s-y	Verb Type=auxiliary VForm=future Person=third Number=singular Negative=yes
Va-m1d	Verb Type=auxiliary VForm=imperative Person=first Number=dual
Va-m1p	Verb Type=auxiliary VForm=imperative Person=first Number=plural
Va-m2d	Verb Type=auxiliary VForm=imperative Person=second Number=dual
Va-m2p	Verb Type=auxiliary VForm=imperative Person=second Number=plural
Va-m2s	Verb Type=auxiliary VForm=imperative Person=second Number=singular
Va-n	Verb Type=auxiliary VForm=infinitive
Va-p-df	Verb Type=auxiliary VForm=participle Number=dual Gender=feminine
Va-p-dm	Verb Type=auxiliary VForm=participle Number=dual Gender=masculine
Va-p-dn	Verb Type=auxiliary VForm=participle Number=dual Gender=neuter
Va-p-pf	Verb Type=auxiliary VForm=participle Number=plural Gender=feminine
Va-p-pm	Verb Type=auxiliary VForm=participle Number=plural Gender=masculine
Va-p-pn	Verb Type=auxiliary VForm=participle Number=plural Gender=neuter
Va-p-sf	Verb Type=auxiliary VForm=participle Number=singular Gender=feminine
Va-p-sm	Verb Type=auxiliary VForm=participle Number=singular Gender=masculine
Va-p-sn	Verb Type=auxiliary VForm=participle Number=singular Gender=neuter
Va-r1dfn	Verb Type=auxiliary VForm=present Person=first Number=dual Gender=feminine Negative=no
Va-r1d-n	Verb Type=auxiliary VForm=present Person=first Number=dual Negative=no
Va-r1d-y	Verb Type=auxiliary VForm=present Person=first Number=dual Negative=yes
Va-r1p-n	Verb Type=auxiliary VForm=present Person=first Number=plural Negative=no
Va-r1p-y	Verb Type=auxiliary VForm=present Person=first Number=plural Negative=yes
Va-r1s-n	Verb Type=auxiliary VForm=present Person=first Number=singular Negative=no
Va-r1s-y	Verb Type=auxiliary VForm=present Person=first Number=singular Negative=yes
Va-r2d-n	Verb Type=auxiliary VForm=present Person=second Number=dual Negative=no
Va-r2d-y	Verb Type=auxiliary VForm=present Person=second Number=dual Negative=yes
Va-r2p-n	Verb Type=auxiliary VForm=present Person=second Number=plural Negative=no
Va-r2p-y	Verb Type=auxiliary VForm=present Person=second Number=plural Negative=yes
Va-r2s-n	Verb Type=auxiliary VForm=present Person=second Number=singular Negative=no
Va-r2s-y	Verb Type=auxiliary VForm=present Person=second Number=singular Negative=yes
Va-r3d-n	Verb Type=auxiliary VForm=present Person=third Number=dual Negative=no
Va-r3d-y	Verb Type=auxiliary VForm=present Person=third Number=dual Negative=yes
Va-r3p-n	Verb Type=auxiliary VForm=present Person=third Number=plural Negative=no
Va-r3p-y	Verb Type=auxiliary VForm=present Person=third Number=plural Negative=yes
Va-r3s-n	Verb Type=auxiliary VForm=present Person=third Number=singular Negative=no
Va-r3s-y	Verb Type=auxiliary VForm=present Person=third Number=singular Negative=yes
Va-u	Verb Type=auxiliary VForm=supine
Vmbf1d	Verb Type=main Aspect=biaspectual VForm=future Person=first Number=dual
Vmbf1p	Verb Type=main Aspect=biaspectual VForm=future Person=first Number=plural
Vmbf1s	Verb Type=main Aspect=biaspectual VForm=future Person=first Number=singular
Vmbf2d	Verb Type=main Aspect=biaspectual VForm=future Person=second Number=dual
Vmbf2p	Verb Type=main Aspect=biaspectual VForm=future Person=second Number=plural
Vmbf2s	Verb Type=main Aspect=biaspectual VForm=future Person=second Number=singular
Vmbf3d	Verb Type=main Aspect=biaspectual VForm=future Person=third Number=dual
Vmbf3p	Verb Type=main Aspect=biaspectual VForm=future Person=third Number=plural
Vmbf3s	Verb Type=main Aspect=biaspectual VForm=future Person=third Number=singular
Vmbm1d	Verb Type=main Aspect=biaspectual VForm=imperative Person=first Number=dual
Vmbm1p	Verb Type=main Aspect=biaspectual VForm=imperative Person=first Number=plural
Vmbm2d	Verb Type=main Aspect=biaspectual VForm=imperative Person=second Number=dual
Vmbm2p	Verb Type=main Aspect=biaspectual VForm=imperative Person=second Number=plural
Vmbm2s	Verb Type=main Aspect=biaspectual VForm=imperative Person=second Number=singular
Vmbn	Verb Type=main Aspect=biaspectual VForm=infinitive
Vmbp-df	Verb Type=main Aspect=biaspectual VForm=participle Number=dual Gender=feminine
Vmbp-dm	Verb Type=main Aspect=biaspectual VForm=participle Number=dual Gender=masculine
Vmbp-dn	Verb Type=main Aspect=biaspectual VForm=participle Number=dual Gender=neuter
Vmbp-pf	Verb Type=main Aspect=biaspectual VForm=participle Number=plural Gender=feminine
Vmbp-pm	Verb Type=main Aspect=biaspectual VForm=participle Number=plural Gender=masculine
Vmbp-pn	Verb Type=main Aspect=biaspectual VForm=participle Number=plural Gender=neuter
Vmbp-sf	Verb Type=main Aspect=biaspectual VForm=participle Number=singular Gender=feminine
Vmbp-sm	Verb Type=main Aspect=biaspectual VForm=participle Number=singular Gender=masculine
Vmbp-sn	Verb Type=main Aspect=biaspectual VForm=participle Number=singular Gender=neuter
Vmbr1df	Verb Type=main Aspect=biaspectual VForm=present Person=first Number=dual Gender=feminine
Vmbr1d	Verb Type=main Aspect=biaspectual VForm=present Person=first Number=dual
Vmbr1p	Verb Type=main Aspect=biaspectual VForm=present Person=first Number=plural
Vmbr1s	Verb Type=main Aspect=biaspectual VForm=present Person=first Number=singular
Vmbr2d	Verb Type=main Aspect=biaspectual VForm=present Person=second Number=dual
Vmbr2p	Verb Type=main Aspect=biaspectual VForm=present Person=second Number=plural
Vmbr2s	Verb Type=main Aspect=biaspectual VForm=present Person=second Number=singular
Vmbr3d	Verb Type=main Aspect=biaspectual VForm=present Person=third Number=dual
Vmbr3p	Verb Type=main Aspect=biaspectual VForm=present Person=third Number=plural
Vmbr3s	Verb Type=main Aspect=biaspectual VForm=present Person=third Number=singular
Vmbu	Verb Type=main Aspect=biaspectual VForm=supine
Vmem1d	Verb Type=main Aspect=perfective VForm=imperative Person=first Number=dual
Vmem1p	Verb Type=main Aspect=perfective VForm=imperative Person=first Number=plural
Vmem2d	Verb Type=main Aspect=perfective VForm=imperative Person=second Number=dual
Vmem2p	Verb Type=main Aspect=perfective VForm=imperative Person=second Number=plural
Vmem2s	Verb Type=main Aspect=perfective VForm=imperative Person=second Number=singular
Vmen	Verb Type=main Aspect=perfective VForm=infinitive
Vmep-df	Verb Type=main Aspect=perfective VForm=participle Number=dual Gender=feminine
Vmep-dm	Verb Type=main Aspect=perfective VForm=participle Number=dual Gender=masculine
Vmep-dn	Verb Type=main Aspect=perfective VForm=participle Number=dual Gender=neuter
Vmep-pf	Verb Type=main Aspect=perfective VForm=participle Number=plural Gender=feminine
Vmep-pm	Verb Type=main Aspect=perfective VForm=participle Number=plural Gender=masculine
Vmep-pn	Verb Type=main Aspect=perfective VForm=participle Number=plural Gender=neuter
Vmep-sf	Verb Type=main Aspect=perfective VForm=participle Number=singular Gender=feminine
Vmep-sm	Verb Type=main Aspect=perfective VForm=participle Number=singular Gender=masculine
Vmep-sn	Verb Type=main Aspect=perfective VForm=participle Number=singular Gender=neuter
Vmer1d	Verb Type=main Aspect=perfective VForm=present Person=first Number=dual
Vmer1p	Verb Type=main Aspect=perfective VForm=present Person=first Number=plural
Vmer1s	Verb Type=main Aspect=perfective VForm=present Person=first Number=singular
Vmer2d	Verb Type=main Aspect=perfective VForm=present Person=second Number=dual
Vmer2p	Verb Type=main Aspect=perfective VForm=present Person=second Number=plural
Vmer2s	Verb Type=main Aspect=perfective VForm=present Person=second Number=singular
Vmer3d	Verb Type=main Aspect=perfective VForm=present Person=third Number=dual
Vmer3p	Verb Type=main Aspect=perfective VForm=present Person=third Number=plural
Vmer3s	Verb Type=main Aspect=perfective VForm=present Person=third Number=singular
Vmeu	Verb Type=main Aspect=perfective VForm=supine
Vmpm1d	Verb Type=main Aspect=progressive VForm=imperative Person=first Number=dual
Vmpm1p	Verb Type=main Aspect=progressive VForm=imperative Person=first Number=plural
Vmpm2d	Verb Type=main Aspect=progressive VForm=imperative Person=second Number=dual
Vmpm2p	Verb Type=main Aspect=progressive VForm=imperative Person=second Number=plural
Vmpm2s	Verb Type=main Aspect=progressive VForm=imperative Person=second Number=singular
Vmpn	Verb Type=main Aspect=progressive VForm=infinitive
Vmpp-df	Verb Type=main Aspect=progressive VForm=participle Number=dual Gender=feminine
Vmpp-dm	Verb Type=main Aspect=progressive VForm=participle Number=dual Gender=masculine
Vmpp-dn	Verb Type=main Aspect=progressive VForm=participle Number=dual Gender=neuter
Vmpp-pf	Verb Type=main Aspect=progressive VForm=participle Number=plural Gender=feminine
Vmpp-pm	Verb Type=main Aspect=progressive VForm=participle Number=plural Gender=masculine
Vmpp-pn	Verb Type=main Aspect=progressive VForm=participle Number=plural Gender=neuter
Vmpp-sf	Verb Type=main Aspect=progressive VForm=participle Number=singular Gender=feminine
Vmpp-sm	Verb Type=main Aspect=progressive VForm=participle Number=singular Gender=masculine
Vmpp-sn	Verb Type=main Aspect=progressive VForm=participle Number=singular Gender=neuter
Vmpr1d-n	Verb Type=main Aspect=progressive VForm=present Person=first Number=dual Negative=no
Vmpr1d	Verb Type=main Aspect=progressive VForm=present Person=first Number=dual
Vmpr1d-y	Verb Type=main Aspect=progressive VForm=present Person=first Number=dual Negative=yes
Vmpr1p-n	Verb Type=main Aspect=progressive VForm=present Person=first Number=plural Negative=no
Vmpr1p	Verb Type=main Aspect=progressive VForm=present Person=first Number=plural
Vmpr1p-y	Verb Type=main Aspect=progressive VForm=present Person=first Number=plural Negative=yes
Vmpr1s-n	Verb Type=main Aspect=progressive VForm=present Person=first Number=singular Negative=no
Vmpr1s	Verb Type=main Aspect=progressive VForm=present Person=first Number=singular
Vmpr1s-y	Verb Type=main Aspect=progressive VForm=present Person=first Number=singular Negative=yes
Vmpr2d-n	Verb Type=main Aspect=progressive VForm=present Person=second Number=dual Negative=no
Vmpr2d	Verb Type=main Aspect=progressive VForm=present Person=second Number=dual
Vmpr2d-y	Verb Type=main Aspect=progressive VForm=present Person=second Number=dual Negative=yes
Vmpr2p-n	Verb Type=main Aspect=progressive VForm=present Person=second Number=plural Negative=no
Vmpr2p	Verb Type=main Aspect=progressive VForm=present Person=second Number=plural
Vmpr2p-y	Verb Type=main Aspect=progressive VForm=present Person=second Number=plural Negative=yes
Vmpr2s-n	Verb Type=main Aspect=progressive VForm=present Person=second Number=singular Negative=no
Vmpr2s	Verb Type=main Aspect=progressive VForm=present Person=second Number=singular
Vmpr2s-y	Verb Type=main Aspect=progressive VForm=present Person=second Number=singular Negative=yes
Vmpr3d-n	Verb Type=main Aspect=progressive VForm=present Person=third Number=dual Negative=no
Vmpr3d	Verb Type=main Aspect=progressive VForm=present Person=third Number=dual
Vmpr3d-y	Verb Type=main Aspect=progressive VForm=present Person=third Number=dual Negative=yes
Vmpr3p-n	Verb Type=main Aspect=progressive VForm=present Person=third Number=plural Negative=no
Vmpr3p	Verb Type=main Aspect=progressive VForm=present Person=third Number=plural
Vmpr3p-y	Verb Type=main Aspect=progressive VForm=present Person=third Number=plural Negative=yes
Vmpr3s-n	Verb Type=main Aspect=progressive VForm=present Person=third Number=singular Negative=no
Vmpr3s	Verb Type=main Aspect=progressive VForm=present Person=third Number=singular
Vmpr3s-y	Verb Type=main Aspect=progressive VForm=present Person=third Number=singular Negative=yes
Vmpu	Verb Type=main Aspect=progressive VForm=supine
Xa	Residual Type=at
Xe	Residual Type=emo
Xf	Residual Type=foreign
Xh	Residual Type=hashtag
Xp	Residual Type=program
X	Residual
Xt	Residual Type=typo
Xw	Residual Type=web
Y	Abbreviation
Z	Punctuation
