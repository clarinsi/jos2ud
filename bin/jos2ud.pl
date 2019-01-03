#!/usr/bin/perl -w
#use locale; 
use utf8;
binmode STDIN, ":utf8";
binmode STDOUT,":utf8";
binmode STDERR,":utf8";
my $type = shift or die "Need type of input ('corpus' or 'lexicon')!\n";
my $posFile = shift or die "Need PoS mapping file!\n";
my $featFile = shift or die "Need feature mapping file!\n";
my (@pos_map, @feat_map);

open POS, $posFile or die "Can't open $posFile!\n";
binmode POS,"utf8";
while (<POS>) {
    chomp;
    next if /^#/ or not /\t/;
    s/\t#.*//;
    die "Spaces not allowed in line:\n$_\n" if / /;
    $i++;
    push @tmp, $_;
}
close POS;
#mapping table priority sorted
@pos_map = sort @tmp;
undef @tmp;

open FEAT, $featFile or die "Can't open $featFile!\n";
binmode FEAT, ":utf8";
while (<FEAT>) {
    chomp;
    next if /^#/ or not /\t/;
    s/\t#.*//;
    die "Spaces not allowed in line:\n$_\n" if / /;
    $i++;
    push @tmp, $_;
}
close FEAT;
#mapping table priority sorted
@feat_map = sort @tmp;
undef @tmp;

if ($type eq 'corpus') {
    $/ = "\n\n";
    while (<>){
	@lines = split /\n/;
	$comments=0;
	foreach $line (@lines) {
	    if ($line=~/^#/) {
		$comments++;
		print $line, "\n";
		next;
	    }
	    if (not $line=~/\t/) {
		print $line, "\n";
		next;
	    }
	    my ($n, $tok, $lemma, $cat, $msd, 
		$feats, $dep, $rel, $deps, $misc) = split /\t/, $line;
	    if ($dep > 0) {
		$head = $lines[$dep+$comments-1];
	    }
	    else {$head = ''}
	    if ($feats eq '_') {$feats = ''};
	    #Convert PoS
	    $ud_cat = pos_jos2ud($lemma, $cat, $feats, $rel, $head);
	    print STDERR "ERROR: Out of cat array for '$cat + $lemma + $feats' in:\n$_\n\n"
		unless $ud_cat;
	    $ud_feats = feats_jos2ud($lemma, $cat, $feats, $ud_cat);
	    print STDERR "ERROR: Out of feature array with '$cat + $feats' in: $line\n"
		unless $ud_feats;
	    if ($dep == -1) {
		$ud_head = -1;
		$ud_deprel = '-';
	    }
	    else {
		$ud_head = 0;
		$ud_deprel = 'root';
		$misc .= "|Dep=$dep|Rel=$rel";
	    }
	    $misc =~ s/^_?\|//;
	    
	    print join("\t",  
		       ($n, $tok, $lemma, 
			$ud_cat, $msd, $ud_feats, 
			$ud_head, $ud_deprel, $deps, $misc)),  "\n";
	}
	print "\n";
    }
}
elsif ($type eq 'lexicon') {
    my ($cat, $feats);
    while (<>){
	chomp;
	my ($word, $lemma, $rest, $all_feats) = /^([^\t]+)\t([^\t]+)\t(.+)\t([^\t]+)$/;
	if ($all_feats =~ / /) {
	    ($cat, $feats) = $all_feats =~ /(.+?) (.+)/; 
	}
	else {
	    $cat = $all_feats;
	    $feats = ''
	}
	$head = '';
	$ud_cat = pos_jos2ud($lemma, $cat, $feats, '', '');
	print STDERR "ERROR: Out of cat array for '$cat + $lemma + $feats' in:\n$_\n\n"
	    unless $ud_cat;
	$ud_feats = feats_jos2ud($lemma, $cat, $feats, $ud_cat);
	print STDERR "ERROR: Out of feature array with '$cat + $feats' in: $_\n"
	    unless $ud_feats;
	$ud_feats =~ s/\|/ /g;
	$ud_all_feats = "$ud_cat $ud_feats";
	print join("\t",  
		   $word, $lemma, $rest, 
		   $all_feats, $ud_all_feats) . "\n";
    }
}
else {
    die "Type of input should be 'corpus' or 'lexicon'!\n"
}

sub match_re {
    my $str = shift;
    my $re = shift;
    my $qre = $re;
    $re =~ s/^\*/*./g; 
    $re =~ s/([^\\]\*)/$1./g; 
    $qre = quotemeta $re;
    $qre =~ s/\\\\\\/\\/g; 
    $qre =~ s/\\\*\\\./.*/g;
    if ($str =~ /^$qre$/) {return 1}
    else {return 0}
}
sub match_feats {
    my $f = shift;
    my $fre = shift;
    my %f;
    if ($fre eq '*') {return 1}
    else {
	foreach my $f (split /[\| ]/, $f) {$f{$f}++}
	my $ok = 1;
	foreach my $f (split /\|/, $fre) {
	    $ok = 0 unless exists $f{$f}
	}
	return $ok
    }
}
sub match_dep {
    my $feats = shift;
    my $rel = shift;
    my $head = shift;
    my $match = shift;
    my %f1;
    my %f2;
    my @agrfeats;
    if ($match eq '*') {return 1}
    else {
	#head token
	my ($n, $htok, $hlemma, $hcat, $hmsd, $hfeats) = split /\t/, $head;
	#mapping for dependency a la: Atr/Noun/agr(Gender,Number,Case)
	my ($mrel, $mcat, $magr) = split m|/|, $match;
	if ($magr) {
	    my ($magrfeats)=$magr=~/agr\((.+)\)/;
	    @agrfeats = split /,\s*/, $magrfeats;
	}
	#print STDERR "INFO: Testing dep on $match for $head\n";
	if    ($rel ne $mrel) {return 0}
	elsif (not $hcat or $hcat ne $mcat) {return 0}
	elsif (@agrfeats) {
	    my $ok = 1;
	    foreach my $f (split /\|/, $feats) {
		my ($att, $val) = split /=/, $f;
		$f1{$att}=$val;
	    }
	    foreach my $f (split /\|/, $hfeats) {
		my ($att, $val) = split /=/, $f;
		$f2{$att} = $val;
	    }
	    foreach my $att (@agrfeats) {
		#Both words have feature, but it doesnt agree
		if (exists $f1{$att} && exists $f2{$att} && $f1{$att} ne $f2{$att}) {
		    #print STDERR "INFO: agreement fail, fake DET\n";
		    $ok = 0
		}
	    }
	    ##print STDERR "INFO: DET status $ok\n";
	    return $ok
	}
	else {return 1}
    }
}
sub pos_jos2ud {
    my $pos_map = scalar @pos_map;
    my $lemma = shift;
    my $jos_cat = shift;
    my $jos_feats = shift;
    my $jos_rel = shift;
    my $jos_head = shift;
    my $cont = 1;
    my $i = 0;
    my $ud_cat;
    while ($cont) {
	if ($i >= $pos_map) {
	    $cont = 0;
	}
	else {
	    my ($prio,$m_lemma,$m_cat,$m_feats,$m_deps,$m_cat_ud) = split /\t+/, $pos_map[$i];
	    #print STDERR join("*", $lemma, $jos_cat, $jos_feats, $jos_rel, '///', $m_lemma, $m_feats, $m_cat_ud), "\n";
	    if (match_re($lemma, $m_lemma) && match_re($jos_cat, $m_cat) 
		&& match_feats($jos_feats, $m_feats) 
		&& match_dep($jos_feats, $jos_rel, $jos_head, $m_deps)) {
		$ud_cat = $m_cat_ud;
		$cont = 0;
	    }
	    $i++;
	}
    }
    return $ud_cat;
}
sub feats_jos2ud {
    my $feat_map = scalar @feat_map;
    my $lemma = shift;
    my $jos_cat = shift;
    my $jos_feats = shift;
    my $ud_cat = shift;
    my $cont = 1;
    my $i = 0;
    my $ud_feats;

    ##Do we have to strip them off, one by one? Or doesn't it matter? Maybe for sanity?
    my $tmp_feats = $jos_feats;
    $tmp_feats = '*' unless $tmp_feats; #So tokens with no features also get processed!
    my @m_feats_ud = ();
    ##print STDERR "INFO: Starting work on $lemma\n";
    while ($cont) {
	if ($tmp_feats =~ m/^\|*$/) {
	    $cont = 0;
	    ##print STDERR "INFO: No feats\n";
	}
	elsif ($i >= $feat_map) {
	    $cont = 0;
	}
	else {
	    my ($prio,$m_lemma,$m_cat,$m_feat,$m_ud_cat,$m_feat_ud) = split /\t+/, $feat_map[$i];
	    ##print STDERR "INFO: matching $lemma to $feat_map[$i]\n";
	    if (match_re($lemma, $m_lemma) && match_re($jos_cat, $m_cat) 
		&& match_feats($jos_feats, $m_feat)
		&& match_re($ud_cat, $m_ud_cat)) {
		##print STDERR "MATCH!\n";
		if ($tmp_feats eq '*') {$tmp_feats = ''}
		elsif ($m_feat ne '*') {$tmp_feats =~ s/$m_feat//}
		my @tmp = split /\|/, $m_feat_ud;
		push(@m_feats_ud, @tmp) unless $m_feat_ud eq '-';
	    }
	    $i++;
	}
    }
    #@m_feats_ud = sort @m_feats_ud;
    #have to lower case features before sorting
    my %sorted;
    foreach my $f (@m_feats_ud) {
	$sorted{lc $f} = $f
    }
    @m_feats_ud = ();
    foreach my $f (sort keys %sorted) {
	push @m_feats_ud, $sorted{$f}
    }
    $ud_feats = join("|", @m_feats_ud);
    $ud_feats = '_' unless $ud_feats;
    return $ud_feats
}
