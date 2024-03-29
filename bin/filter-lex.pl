#!/usr/bin/perl
# Filter corpus derived lexicon for MFida
use warnings;
use utf8;
use POSIX;
binmode STDIN, 'utf8';
binmode STDOUT, 'utf8';
binmode STDERR, 'utf8';
while (<DATA>) {
    chomp;
    $msd{$_}++
}
while (<>) {
    $all++;
    s/\cM//;
    next unless /\t/;
    chomp;
    next if / /;
    my ($token, $norm, $lemma, $msd, $freq) 
        = split /\t/;
    next unless exists($msd{$msd});
    next if $freq < 2;
    print join("\t", $token, $lemma, $msd, $freq) . "\n";
    $ok++;
}
print STDERR "INFO: read $all items, of these $ok OK = " .
    floor(10000*$ok/$all)*100 . "%\n"
__DATA__
Agcfda
Agcfdd
Agcfdg
Agcfdi
Agcfdl
Agcfdn
Agcfpa
Agcfpd
Agcfpg
Agcfpi
Agcfpl
Agcfpn
Agcfsa
Agcfsd
Agcfsg
Agcfsi
Agcfsl
Agcfsn
Agcmda
Agcmdd
Agcmdg
Agcmdi
Agcmdl
Agcmdn
Agcmpa
Agcmpd
Agcmpg
Agcmpi
Agcmpl
Agcmpn
Agcmsa
Agcmsay
Agcmsd
Agcmsg
Agcmsi
Agcmsl
Agcmsny
Agcnda
Agcndd
Agcndg
Agcndi
Agcndl
Agcndn
Agcnpa
Agcnpd
Agcnpg
Agcnpi
Agcnpl
Agcnpn
Agcnsa
Agcnsd
Agcnsg
Agcnsi
Agcnsl
Agcnsn
Agpfda
Agpfdd
Agpfdg
Agpfdi
Agpfdl
Agpfdn
Agpfpa
Agpfpd
Agpfpg
Agpfpi
Agpfpl
Agpfpn
Agpfsa
Agpfsd
Agpfsg
Agpfsi
Agpfsl
Agpfsn
Agpmda
Agpmdd
Agpmdg
Agpmdi
Agpmdl
Agpmdn
Agpmpa
Agpmpd
Agpmpg
Agpmpi
Agpmpl
Agpmpn
Agpmsa
Agpmsan
Agpmsay
Agpmsd
Agpmsg
Agpmsi
Agpmsl
Agpmsnn
Agpmsny
Agpnda
Agpndd
Agpndg
Agpndi
Agpndl
Agpndn
Agpnpa
Agpnpd
Agpnpg
Agpnpi
Agpnpl
Agpnpn
Agpnsa
Agpnsd
Agpnsg
Agpnsi
Agpnsl
Agpnsn
Agsfda
Agsfdd
Agsfdg
Agsfdi
Agsfdl
Agsfdn
Agsfpa
Agsfpd
Agsfpg
Agsfpi
Agsfpl
Agsfpn
Agsfsa
Agsfsd
Agsfsg
Agsfsi
Agsfsl
Agsfsn
Agsmda
Agsmdd
Agsmdg
Agsmdi
Agsmdl
Agsmdn
Agsmpa
Agsmpd
Agsmpg
Agsmpi
Agsmpl
Agsmpn
Agsmsa
Agsmsay
Agsmsd
Agsmsg
Agsmsi
Agsmsl
Agsmsny
Agsnda
Agsndd
Agsndg
Agsndi
Agsndl
Agsndn
Agsnpa
Agsnpd
Agsnpg
Agsnpi
Agsnpl
Agsnpn
Agsnsa
Agsnsd
Agsnsg
Agsnsi
Agsnsl
Agsnsn
Appfda
Appfdd
Appfdg
Appfdi
Appfdl
Appfdn
Appfpa
Appfpd
Appfpg
Appfpi
Appfpl
Appfpn
Appfsa
Appfsd
Appfsg
Appfsi
Appfsl
Appfsn
Appmda
Appmdd
Appmdg
Appmdi
Appmdl
Appmdn
Appmpa
Appmpd
Appmpg
Appmpi
Appmpl
Appmpn
Appmsa
Appmsan
Appmsay
Appmsd
Appmsg
Appmsi
Appmsl
Appmsnn
Appmsny
Appnda
Appndd
Appndg
Appndi
Appndl
Appndn
Appnpa
Appnpd
Appnpg
Appnpi
Appnpl
Appnpn
Appnsa
Appnsd
Appnsg
Appnsi
Appnsl
Appnsn
Aspfda
Aspfdd
Aspfdg
Aspfdi
Aspfdl
Aspfdn
Aspfpa
Aspfpd
Aspfpg
Aspfpi
Aspfpl
Aspfpn
Aspfsa
Aspfsd
Aspfsg
Aspfsi
Aspfsl
Aspfsn
Aspmda
Aspmdd
Aspmdg
Aspmdi
Aspmdl
Aspmdn
Aspmpa
Aspmpd
Aspmpg
Aspmpi
Aspmpl
Aspmpn
Aspmsa
Aspmsan
Aspmsd
Aspmsg
Aspmsi
Aspmsl
Aspmsnn
Aspnda
Aspndd
Aspndg
Aspndi
Aspndl
Aspndn
Aspnpa
Aspnpd
Aspnpg
Aspnpi
Aspnpl
Aspnpn
Aspnsa
Aspnsd
Aspnsg
Aspnsi
Aspnsl
Aspnsn
Cc
Cs
I
Mdc
Mdo
Mlcfda
Mlcfdd
Mlcfdg
Mlcfdi
Mlcfdl
Mlcfdn
Mlcfpa
Mlcfpd
Mlcfpg
Mlcfpi
Mlcfpl
Mlcfpn
Mlcmda
Mlcmdd
Mlcmdg
Mlcmdi
Mlcmdl
Mlcmdn
Mlcmpa
Mlcmpd
Mlcmpg
Mlcmpi
Mlcmpl
Mlcmpn
Mlcnda
Mlcndd
Mlcndg
Mlcndi
Mlcndl
Mlcndn
Mlcnpa
Mlcnpd
Mlcnpg
Mlcnpi
Mlcnpl
Mlcnpn
Mlc-pa
Mlc-pd
Mlc-pg
Mlc-pi
Mlc-pl
Mlc-pn
Mlofda
Mlofdd
Mlofdg
Mlofdi
Mlofdl
Mlofdn
Mlofpa
Mlofpd
Mlofpg
Mlofpi
Mlofpl
Mlofpn
Mlofsa
Mlofsd
Mlofsg
Mlofsi
Mlofsl
Mlofsn
Mlomda
Mlomdd
Mlomdg
Mlomdi
Mlomdl
Mlomdn
Mlompa
Mlompd
Mlompg
Mlompi
Mlompl
Mlompn
Mlomsa
Mlomsd
Mlomsg
Mlomsi
Mlomsl
Mlomsn
Mlonda
Mlondd
Mlondg
Mlondi
Mlondl
Mlondn
Mlonpa
Mlonpd
Mlonpg
Mlonpi
Mlonpl
Mlonpn
Mlonsa
Mlonsd
Mlonsg
Mlonsi
Mlonsl
Mlonsn
Mlpfda
Mlpfdd
Mlpfdg
Mlpfdi
Mlpfdl
Mlpfdn
Mlpfpa
Mlpfpd
Mlpfpg
Mlpfpi
Mlpfpl
Mlpfpn
Mlpfsa
Mlpfsd
Mlpfsg
Mlpfsi
Mlpfsl
Mlpfsn
Mlpmda
Mlpmdd
Mlpmdg
Mlpmdi
Mlpmdl
Mlpmdn
Mlpmpa
Mlpmpd
Mlpmpg
Mlpmpi
Mlpmpl
Mlpmpn
Mlpmsa
Mlpmsan
Mlpmsay
Mlpmsd
Mlpmsg
Mlpmsi
Mlpmsl
Mlpmsn
Mlpmsnn
Mlpmsny
Mlpnda
Mlpndd
Mlpndg
Mlpndi
Mlpndl
Mlpndn
Mlpnpa
Mlpnpd
Mlpnpg
Mlpnpi
Mlpnpl
Mlpnpn
Mlpnsa
Mlpnsd
Mlpnsg
Mlpnsi
Mlpnsl
Mlpnsn
Mlsfda
Mlsfdd
Mlsfdg
Mlsfdi
Mlsfdl
Mlsfdn
Mlsfpa
Mlsfpd
Mlsfpg
Mlsfpi
Mlsfpl
Mlsfpn
Mlsfsa
Mlsfsd
Mlsfsg
Mlsfsi
Mlsfsl
Mlsfsn
Mlsmda
Mlsmdd
Mlsmdg
Mlsmdi
Mlsmdl
Mlsmdn
Mlsmpa
Mlsmpd
Mlsmpg
Mlsmpi
Mlsmpl
Mlsmpn
Mlsmsa
Mlsmsan
Mlsmsay
Mlsmsd
Mlsmsg
Mlsmsi
Mlsmsl
Mlsmsnn
Mlsmsny
Mlsnda
Mlsndd
Mlsndg
Mlsndi
Mlsndl
Mlsndn
Mlsnpa
Mlsnpd
Mlsnpg
Mlsnpi
Mlsnpl
Mlsnpn
Mlsnsa
Mlsnsd
Mlsnsg
Mlsnsi
Mlsnsl
Mlsnsn
Mrc
Mro
Ncfda
Ncfdd
Ncfdg
Ncfdi
Ncfdl
Ncfdn
Ncfpa
Ncfpd
Ncfpg
Ncfpi
Ncfpl
Ncfpn
Ncfsa
Ncfsd
Ncfsg
Ncfsi
Ncfsl
Ncfsn
Ncmda
Ncmdd
Ncmdg
Ncmdi
Ncmdl
Ncmdn
Ncmpa
Ncmpd
Ncmpg
Ncmpi
Ncmpl
Ncmpn
Ncmsan
Ncmsay
Ncmsd
Ncmsg
Ncmsi
Ncmsl
Ncmsn
Ncnda
Ncndd
Ncndg
Ncndi
Ncndl
Ncndn
Ncnpa
Ncnpd
Ncnpg
Ncnpi
Ncnpl
Ncnpn
Ncnsa
Ncnsd
Ncnsg
Ncnsi
Ncnsl
Ncnsn
Npfda
Npfdd
Npfdg
Npfdi
Npfdl
Npfdn
Npfpa
Npfpd
Npfpg
Npfpi
Npfpl
Npfpn
Npfsa
Npfsd
Npfsg
Npfsi
Npfsl
Npfsn
Npmda
Npmdd
Npmdg
Npmdi
Npmdl
Npmdn
Npmpa
Npmpd
Npmpg
Npmpi
Npmpl
Npmpn
Npmsan
Npmsay
Npmsd
Npmsg
Npmsi
Npmsl
Npmsn
Npnpa
Npnpd
Npnpg
Npnpi
Npnpl
Npnpn
Npnsa
Npnsd
Npnsg
Npnsi
Npnsl
Npnsn
Pd-fda
Pd-fdd
Pd-fdg
Pd-fdi
Pd-fdl
Pd-fdn
Pd-fpa
Pd-fpd
Pd-fpg
Pd-fpi
Pd-fpl
Pd-fpn
Pd-fsa
Pd-fsd
Pd-fsg
Pd-fsi
Pd-fsl
Pd-fsn
Pd-mda
Pd-mdd
Pd-mdg
Pd-mdi
Pd-mdl
Pd-mdn
Pd-mpa
Pd-mpd
Pd-mpg
Pd-mpi
Pd-mpl
Pd-mpn
Pd-msa
Pd-msd
Pd-msg
Pd-msi
Pd-msl
Pd-msn
Pd-nda
Pd-ndd
Pd-ndg
Pd-ndi
Pd-ndl
Pd-ndn
Pd-npa
Pd-npd
Pd-npg
Pd-npi
Pd-npl
Pd-npn
Pd-nsa
Pd-nsd
Pd-nsg
Pd-nsi
Pd-nsl
Pd-nsn
Pg-fda
Pg-fdd
Pg-fdg
Pg-fdi
Pg-fdl
Pg-fdn
Pg-fpa
Pg-fpd
Pg-fpg
Pg-fpi
Pg-fpl
Pg-fpn
Pg-fsa
Pg-fsd
Pg-fsg
Pg-fsi
Pg-fsl
Pg-fsn
Pg-mda
Pg-mdd
Pg-mdg
Pg-mdi
Pg-mdl
Pg-mdn
Pg-mpa
Pg-mpd
Pg-mpg
Pg-mpi
Pg-mpl
Pg-mpn
Pg-msa
Pg-msd
Pg-msg
Pg-msi
Pg-msl
Pg-msn
Pg-nda
Pg-ndd
Pg-ndg
Pg-ndi
Pg-ndl
Pg-ndn
Pg-npa
Pg-npd
Pg-npg
Pg-npi
Pg-npl
Pg-npn
Pg-nsa
Pg-nsd
Pg-nsg
Pg-nsi
Pg-nsl
Pg-nsn
Pi-fda
Pi-fdd
Pi-fdg
Pi-fdi
Pi-fdl
Pi-fdn
Pi-fpa
Pi-fpd
Pi-fpg
Pi-fpi
Pi-fpl
Pi-fpn
Pi-fsa
Pi-fsd
Pi-fsg
Pi-fsi
Pi-fsl
Pi-fsn
Pi-mda
Pi-mdd
Pi-mdg
Pi-mdi
Pi-mdl
Pi-mdn
Pi-mpa
Pi-mpd
Pi-mpg
Pi-mpi
Pi-mpl
Pi-mpn
Pi-msa
Pi-msd
Pi-msg
Pi-msi
Pi-msl
Pi-msn
Pi-nda
Pi-ndd
Pi-ndg
Pi-ndi
Pi-ndl
Pi-ndn
Pi-npa
Pi-npd
Pi-npg
Pi-npi
Pi-npl
Pi-npn
Pi-nsa
Pi-nsd
Pi-nsg
Pi-nsi
Pi-nsl
Pi-nsn
Pp1-da
Pp1-dd
Pp1-dg
Pp1-di
Pp1-dl
Pp1fdn
Pp1fpn
Pp1mdn
Pp1mpn
Pp1-pa
Pp1-pd
Pp1-pg
Pp1-pi
Pp1-pl
Pp1-sa
Pp1-sa--b
Pp1-sa--y
Pp1-sd
Pp1-sd--y
Pp1-sg
Pp1-sg--y
Pp1-si
Pp1-sl
Pp1-sn
Pp2-da
Pp2-dd
Pp2-dg
Pp2-di
Pp2-dl
Pp2fdn
Pp2fpn
Pp2mdn
Pp2mpn
Pp2ndn
Pp2npn
Pp2-pa
Pp2-pd
Pp2-pg
Pp2-pi
Pp2-pl
Pp2-sa
Pp2-sa--b
Pp2-sa--y
Pp2-sd
Pp2-sd--y
Pp2-sg
Pp2-sg--y
Pp2-si
Pp2-sl
Pp2-sn
Pp3fda
Pp3fda--b
Pp3fda--y
Pp3fdd
Pp3fdd--y
Pp3fdg
Pp3fdg--y
Pp3fdi
Pp3fdl
Pp3fdn
Pp3fpa
Pp3fpa--b
Pp3fpa--y
Pp3fpd
Pp3fpd--y
Pp3fpg
Pp3fpg--y
Pp3fpi
Pp3fpl
Pp3fpn
Pp3fsa
Pp3fsa--b
Pp3fsa--y
Pp3fsd
Pp3fsd--y
Pp3fsg
Pp3fsg--y
Pp3fsi
Pp3fsl
Pp3fsn
Pp3mda
Pp3mda--b
Pp3mda--y
Pp3mdd
Pp3mdd--y
Pp3mdg
Pp3mdg--y
Pp3mdi
Pp3mdl
Pp3mdn
Pp3mpa
Pp3mpa--b
Pp3mpa--y
Pp3mpd
Pp3mpd--y
Pp3mpg
Pp3mpg--y
Pp3mpi
Pp3mpl
Pp3mpn
Pp3msa
Pp3msa--b
Pp3msa--y
Pp3msd
Pp3msd--y
Pp3msg
Pp3msg--y
Pp3msi
Pp3msl
Pp3msn
Pp3nda
Pp3nda--b
Pp3nda--y
Pp3ndd
Pp3ndd--y
Pp3ndg
Pp3ndg--y
Pp3ndi
Pp3ndl
Pp3ndn
Pp3npa
Pp3npa--b
Pp3npa--y
Pp3npd
Pp3npd--y
Pp3npg
Pp3npg--y
Pp3npi
Pp3npl
Pp3npn
Pp3nsa
Pp3nsa--b
Pp3nsa--y
Pp3nsd
Pp3nsd--y
Pp3nsg
Pp3nsg--y
Pp3nsi
Pp3nsl
Pp3nsn
Pq-fda
Pq-fdd
Pq-fdg
Pq-fdi
Pq-fdl
Pq-fdn
Pq-fpa
Pq-fpd
Pq-fpg
Pq-fpi
Pq-fpl
Pq-fpn
Pq-fsa
Pq-fsd
Pq-fsg
Pq-fsi
Pq-fsl
Pq-fsn
Pq-mda
Pq-mdd
Pq-mdg
Pq-mdi
Pq-mdl
Pq-mdn
Pq-mpa
Pq-mpd
Pq-mpg
Pq-mpi
Pq-mpl
Pq-mpn
Pq-msa
Pq-msd
Pq-msg
Pq-msi
Pq-msl
Pq-msn
Pq-nda
Pq-ndd
Pq-ndg
Pq-ndi
Pq-ndl
Pq-ndn
Pq-npa
Pq-npd
Pq-npg
Pq-npi
Pq-npl
Pq-npn
Pq-nsa
Pq-nsd
Pq-nsg
Pq-nsi
Pq-nsl
Pq-nsn
Pr
Pr-fda
Pr-fdd
Pr-fdg
Pr-fdi
Pr-fdl
Pr-fdn
Pr-fpa
Pr-fpd
Pr-fpg
Pr-fpi
Pr-fpl
Pr-fpn
Pr-fsa
Pr-fsd
Pr-fsg
Pr-fsi
Pr-fsl
Pr-fsn
Pr-mda
Pr-mdd
Pr-mdg
Pr-mdi
Pr-mdl
Pr-mdn
Pr-mpa
Pr-mpd
Pr-mpg
Pr-mpi
Pr-mpl
Pr-mpn
Pr-msa
Pr-msd
Pr-msg
Pr-msi
Pr-msl
Pr-msn
Pr-nda
Pr-ndd
Pr-ndg
Pr-ndi
Pr-ndl
Pr-ndn
Pr-npa
Pr-npd
Pr-npg
Pr-npi
Pr-npl
Pr-npn
Pr-nsa
Pr-nsd
Pr-nsg
Pr-nsi
Pr-nsl
Pr-nsn
Pr----sm
Ps1fdad
Ps1fdap
Ps1fdas
Ps1fddd
Ps1fddp
Ps1fdds
Ps1fdgd
Ps1fdgp
Ps1fdgs
Ps1fdid
Ps1fdip
Ps1fdis
Ps1fdld
Ps1fdlp
Ps1fdls
Ps1fdnd
Ps1fdnp
Ps1fdns
Ps1fpad
Ps1fpap
Ps1fpas
Ps1fpdd
Ps1fpdp
Ps1fpds
Ps1fpgd
Ps1fpgp
Ps1fpgs
Ps1fpid
Ps1fpip
Ps1fpis
Ps1fpld
Ps1fplp
Ps1fpls
Ps1fpnd
Ps1fpnp
Ps1fpns
Ps1fsad
Ps1fsap
Ps1fsas
Ps1fsdd
Ps1fsdp
Ps1fsds
Ps1fsgd
Ps1fsgp
Ps1fsgs
Ps1fsid
Ps1fsip
Ps1fsis
Ps1fsld
Ps1fslp
Ps1fsls
Ps1fsnd
Ps1fsnp
Ps1fsns
Ps1mdad
Ps1mdap
Ps1mdas
Ps1mddd
Ps1mddp
Ps1mdds
Ps1mdgd
Ps1mdgp
Ps1mdgs
Ps1mdid
Ps1mdip
Ps1mdis
Ps1mdld
Ps1mdlp
Ps1mdls
Ps1mdnd
Ps1mdnp
Ps1mdns
Ps1mpad
Ps1mpap
Ps1mpas
Ps1mpdd
Ps1mpdp
Ps1mpds
Ps1mpgd
Ps1mpgp
Ps1mpgs
Ps1mpid
Ps1mpip
Ps1mpis
Ps1mpld
Ps1mplp
Ps1mpls
Ps1mpnd
Ps1mpnp
Ps1mpns
Ps1msad
Ps1msap
Ps1msas
Ps1msdd
Ps1msdp
Ps1msds
Ps1msgd
Ps1msgp
Ps1msgs
Ps1msid
Ps1msip
Ps1msis
Ps1msld
Ps1mslp
Ps1msls
Ps1msnd
Ps1msnp
Ps1msns
Ps1ndad
Ps1ndap
Ps1ndas
Ps1nddd
Ps1nddp
Ps1ndds
Ps1ndgd
Ps1ndgp
Ps1ndgs
Ps1ndid
Ps1ndip
Ps1ndis
Ps1ndld
Ps1ndlp
Ps1ndls
Ps1ndnd
Ps1ndnp
Ps1ndns
Ps1npad
Ps1npap
Ps1npas
Ps1npdd
Ps1npdp
Ps1npds
Ps1npgd
Ps1npgp
Ps1npgs
Ps1npid
Ps1npip
Ps1npis
Ps1npld
Ps1nplp
Ps1npls
Ps1npnd
Ps1npnp
Ps1npns
Ps1nsad
Ps1nsap
Ps1nsas
Ps1nsdd
Ps1nsdp
Ps1nsds
Ps1nsgd
Ps1nsgp
Ps1nsgs
Ps1nsid
Ps1nsip
Ps1nsis
Ps1nsld
Ps1nslp
Ps1nsls
Ps1nsnd
Ps1nsnp
Ps1nsns
Ps2fdad
Ps2fdap
Ps2fdas
Ps2fddd
Ps2fddp
Ps2fdds
Ps2fdgd
Ps2fdgp
Ps2fdgs
Ps2fdid
Ps2fdip
Ps2fdis
Ps2fdld
Ps2fdlp
Ps2fdls
Ps2fdnd
Ps2fdnp
Ps2fdns
Ps2fpad
Ps2fpap
Ps2fpas
Ps2fpdd
Ps2fpdp
Ps2fpds
Ps2fpgd
Ps2fpgp
Ps2fpgs
Ps2fpid
Ps2fpip
Ps2fpis
Ps2fpld
Ps2fplp
Ps2fpls
Ps2fpnd
Ps2fpnp
Ps2fpns
Ps2fsad
Ps2fsap
Ps2fsas
Ps2fsdd
Ps2fsdp
Ps2fsds
Ps2fsgd
Ps2fsgp
Ps2fsgs
Ps2fsid
Ps2fsip
Ps2fsis
Ps2fsld
Ps2fslp
Ps2fsls
Ps2fsnd
Ps2fsnp
Ps2fsns
Ps2mdad
Ps2mdap
Ps2mdas
Ps2mddd
Ps2mddp
Ps2mdds
Ps2mdgd
Ps2mdgp
Ps2mdgs
Ps2mdid
Ps2mdip
Ps2mdis
Ps2mdld
Ps2mdlp
Ps2mdls
Ps2mdnd
Ps2mdnp
Ps2mdns
Ps2mpad
Ps2mpap
Ps2mpas
Ps2mpdd
Ps2mpdp
Ps2mpds
Ps2mpgd
Ps2mpgp
Ps2mpgs
Ps2mpid
Ps2mpip
Ps2mpis
Ps2mpld
Ps2mplp
Ps2mpls
Ps2mpnd
Ps2mpnp
Ps2mpns
Ps2msad
Ps2msap
Ps2msas
Ps2msdd
Ps2msdp
Ps2msds
Ps2msgd
Ps2msgp
Ps2msgs
Ps2msid
Ps2msip
Ps2msis
Ps2msld
Ps2mslp
Ps2msls
Ps2msnd
Ps2msnp
Ps2msns
Ps2ndad
Ps2ndap
Ps2ndas
Ps2nddd
Ps2nddp
Ps2ndds
Ps2ndgd
Ps2ndgp
Ps2ndgs
Ps2ndid
Ps2ndip
Ps2ndis
Ps2ndld
Ps2ndlp
Ps2ndls
Ps2ndnd
Ps2ndnp
Ps2ndns
Ps2npad
Ps2npap
Ps2npas
Ps2npdd
Ps2npdp
Ps2npds
Ps2npgd
Ps2npgp
Ps2npgs
Ps2npid
Ps2npip
Ps2npis
Ps2npld
Ps2nplp
Ps2npls
Ps2npnd
Ps2npnp
Ps2npns
Ps2nsad
Ps2nsap
Ps2nsas
Ps2nsdd
Ps2nsdp
Ps2nsds
Ps2nsgd
Ps2nsgp
Ps2nsgs
Ps2nsid
Ps2nsip
Ps2nsis
Ps2nsld
Ps2nslp
Ps2nsls
Ps2nsnd
Ps2nsnp
Ps2nsns
Ps3fdad
Ps3fdap
Ps3fdasf
Ps3fdasm
Ps3fdasn
Ps3fddd
Ps3fddp
Ps3fddsf
Ps3fddsm
Ps3fddsn
Ps3fdgd
Ps3fdgp
Ps3fdgsf
Ps3fdgsm
Ps3fdgsn
Ps3fdid
Ps3fdip
Ps3fdisf
Ps3fdism
Ps3fdisn
Ps3fdld
Ps3fdlp
Ps3fdlsf
Ps3fdlsm
Ps3fdlsn
Ps3fdnd
Ps3fdnp
Ps3fdnsf
Ps3fdnsm
Ps3fdnsn
Ps3fpad
Ps3fpap
Ps3fpasf
Ps3fpasm
Ps3fpasn
Ps3fpdd
Ps3fpdp
Ps3fpdsf
Ps3fpdsm
Ps3fpdsn
Ps3fpgd
Ps3fpgp
Ps3fpgsf
Ps3fpgsm
Ps3fpgsn
Ps3fpid
Ps3fpip
Ps3fpisf
Ps3fpism
Ps3fpisn
Ps3fpld
Ps3fplp
Ps3fplsf
Ps3fplsm
Ps3fplsn
Ps3fpnd
Ps3fpnp
Ps3fpnsf
Ps3fpnsm
Ps3fpnsn
Ps3fsad
Ps3fsap
Ps3fsasf
Ps3fsasm
Ps3fsasn
Ps3fsdd
Ps3fsdp
Ps3fsdsf
Ps3fsdsm
Ps3fsdsn
Ps3fsgd
Ps3fsgp
Ps3fsgsf
Ps3fsgsm
Ps3fsgsn
Ps3fsid
Ps3fsip
Ps3fsisf
Ps3fsism
Ps3fsisn
Ps3fsld
Ps3fslp
Ps3fslsf
Ps3fslsm
Ps3fslsn
Ps3fsnd
Ps3fsnp
Ps3fsnsf
Ps3fsnsm
Ps3fsnsn
Ps3mdad
Ps3mdap
Ps3mdasf
Ps3mdasm
Ps3mdasn
Ps3mddd
Ps3mddp
Ps3mddsf
Ps3mddsm
Ps3mddsn
Ps3mdgd
Ps3mdgp
Ps3mdgsf
Ps3mdgsm
Ps3mdgsn
Ps3mdid
Ps3mdip
Ps3mdisf
Ps3mdism
Ps3mdisn
Ps3mdld
Ps3mdlp
Ps3mdlsf
Ps3mdlsm
Ps3mdlsn
Ps3mdnd
Ps3mdnp
Ps3mdnsf
Ps3mdnsm
Ps3mdnsn
Ps3mpad
Ps3mpap
Ps3mpasf
Ps3mpasm
Ps3mpasn
Ps3mpdd
Ps3mpdp
Ps3mpdsf
Ps3mpdsm
Ps3mpdsn
Ps3mpgd
Ps3mpgp
Ps3mpgsf
Ps3mpgsm
Ps3mpgsn
Ps3mpid
Ps3mpip
Ps3mpisf
Ps3mpism
Ps3mpisn
Ps3mpld
Ps3mplp
Ps3mplsf
Ps3mplsm
Ps3mplsn
Ps3mpnd
Ps3mpnp
Ps3mpnsf
Ps3mpnsm
Ps3mpnsn
Ps3msad
Ps3msap
Ps3msasf
Ps3msasm
Ps3msasn
Ps3msdd
Ps3msdp
Ps3msdsf
Ps3msdsm
Ps3msdsn
Ps3msgd
Ps3msgp
Ps3msgsf
Ps3msgsm
Ps3msgsn
Ps3msid
Ps3msip
Ps3msisf
Ps3msism
Ps3msisn
Ps3msld
Ps3mslp
Ps3mslsf
Ps3mslsm
Ps3mslsn
Ps3msnd
Ps3msnp
Ps3msnsf
Ps3msnsm
Ps3msnsn
Ps3ndad
Ps3ndap
Ps3ndasf
Ps3ndasm
Ps3ndasn
Ps3nddd
Ps3nddp
Ps3nddsf
Ps3nddsm
Ps3nddsn
Ps3ndgd
Ps3ndgp
Ps3ndgsf
Ps3ndgsm
Ps3ndgsn
Ps3ndid
Ps3ndip
Ps3ndisf
Ps3ndism
Ps3ndisn
Ps3ndld
Ps3ndlp
Ps3ndlsf
Ps3ndlsm
Ps3ndlsn
Ps3ndnd
Ps3ndnp
Ps3ndnsf
Ps3ndnsm
Ps3ndnsn
Ps3npad
Ps3npap
Ps3npasf
Ps3npasm
Ps3npasn
Ps3npdd
Ps3npdp
Ps3npdsf
Ps3npdsm
Ps3npdsn
Ps3npgd
Ps3npgp
Ps3npgsf
Ps3npgsm
Ps3npgsn
Ps3npid
Ps3npip
Ps3npisf
Ps3npism
Ps3npisn
Ps3npld
Ps3nplp
Ps3nplsf
Ps3nplsm
Ps3nplsn
Ps3npnd
Ps3npnp
Ps3npnsf
Ps3npnsm
Ps3npnsn
Ps3nsad
Ps3nsap
Ps3nsasf
Ps3nsasm
Ps3nsasn
Ps3nsdd
Ps3nsdp
Ps3nsdsf
Ps3nsdsm
Ps3nsdsn
Ps3nsgd
Ps3nsgp
Ps3nsgsf
Ps3nsgsm
Ps3nsgsn
Ps3nsid
Ps3nsip
Ps3nsisf
Ps3nsism
Ps3nsisn
Ps3nsld
Ps3nslp
Ps3nslsf
Ps3nslsm
Ps3nslsn
Ps3nsnd
Ps3nsnp
Ps3nsnsf
Ps3nsnsm
Ps3nsnsn
Px---a
Px---a--b
Px---d
Px---d--y
Px-fda
Px-fdd
Px-fdg
Px-fdi
Px-fdl
Px-fdn
Px-fpa
Px-fpd
Px-fpg
Px-fpi
Px-fpl
Px-fpn
Px-fsa
Px-fsd
Px-fsg
Px-fsi
Px-fsl
Px-fsn
Px---g
Px---i
Px---l
Px-mda
Px-mdd
Px-mdg
Px-mdi
Px-mdl
Px-mdn
Px-mpa
Px-mpd
Px-mpg
Px-mpi
Px-mpl
Px-mpn
Px-msa
Px-msd
Px-msg
Px-msi
Px-msl
Px-msn
Px-nda
Px-ndd
Px-ndg
Px-ndi
Px-ndl
Px-ndn
Px-npa
Px-npd
Px-npg
Px-npi
Px-npl
Px-npn
Px-nsa
Px-nsd
Px-nsg
Px-nsi
Px-nsl
Px-nsn
Px------y
Pz-fda
Pz-fdd
Pz-fdg
Pz-fdi
Pz-fdl
Pz-fdn
Pz-fpa
Pz-fpd
Pz-fpg
Pz-fpi
Pz-fpl
Pz-fpn
Pz-fsa
Pz-fsd
Pz-fsg
Pz-fsi
Pz-fsl
Pz-fsn
Pz-mda
Pz-mdd
Pz-mdg
Pz-mdi
Pz-mdl
Pz-mdn
Pz-mpa
Pz-mpd
Pz-mpg
Pz-mpi
Pz-mpl
Pz-mpn
Pz-msa
Pz-msd
Pz-msg
Pz-msi
Pz-msl
Pz-msn
Pz-nda
Pz-ndd
Pz-ndg
Pz-ndi
Pz-ndl
Pz-ndn
Pz-npa
Pz-npd
Pz-npg
Pz-npi
Pz-npl
Pz-npn
Pz-nsa
Pz-nsd
Pz-nsg
Pz-nsi
Pz-nsl
Pz-nsn
Q
Rgc
Rgp
Rgs
Rr
Sa
Sd
Sg
Si
Sl
Sn
Va-c
Va-c---y
Va-f1d
Va-f1d-n
Va-f1d-y
Va-f1p-n
Va-f1p-y
Va-f1s-n
Va-f1s-y
Va-f2d-n
Va-f2p-n
Va-f2s-n
Va-f2s-y
Va-f3d-n
Va-f3p-n
Va-f3p-y
Va-f3s-n
Va-f3s-y
Va-m1d
Va-m1p
Va-m2d
Va-m2p
Va-m2s
Va-n
Va-p-df
Va-p-dm
Va-p-dn
Va-p-pf
Va-p-pm
Va-p-pn
Va-p-sf
Va-p-sm
Va-p-sn
Va-r1dfn
Va-r1d-n
Va-r1d-y
Va-r1p-n
Va-r1p-y
Va-r1s-n
Va-r1s-y
Va-r2d-n
Va-r2d-y
Va-r2p-n
Va-r2p-y
Va-r2s-n
Va-r2s-y
Va-r3d-n
Va-r3d-y
Va-r3p-n
Va-r3p-y
Va-r3s-n
Va-r3s-y
Va-u
Vmbf1d
Vmbf1p
Vmbf1s
Vmbf2d
Vmbf2p
Vmbf2s
Vmbf3d
Vmbf3p
Vmbf3s
Vmbm1d
Vmbm1p
Vmbm2d
Vmbm2p
Vmbm2s
Vmbn
Vmbp-df
Vmbp-dm
Vmbp-dn
Vmbp-pf
Vmbp-pm
Vmbp-pn
Vmbp-sf
Vmbp-sm
Vmbp-sn
Vmbr1d
Vmbr1df
Vmbr1p
Vmbr1s
Vmbr2d
Vmbr2p
Vmbr2s
Vmbr3d
Vmbr3p
Vmbr3s
Vmbu
Vmem1d
Vmem1p
Vmem2d
Vmem2p
Vmem2s
Vmen
Vmep-df
Vmep-dm
Vmep-dn
Vmep-pf
Vmep-pm
Vmep-pn
Vmep-sf
Vmep-sm
Vmep-sn
Vmer1d
Vmer1p
Vmer1s
Vmer2d
Vmer2p
Vmer2s
Vmer3d
Vmer3p
Vmer3s
Vmeu
Vmpm1d
Vmpm1p
Vmpm2d
Vmpm2p
Vmpm2s
Vmpn
Vmpp-df
Vmpp-dm
Vmpp-dn
Vmpp-pf
Vmpp-pm
Vmpp-pn
Vmpp-sf
Vmpp-sm
Vmpp-sn
Vmpr1d
Vmpr1d-n
Vmpr1d-y
Vmpr1p
Vmpr1p-n
Vmpr1p-y
Vmpr1s
Vmpr1s-n
Vmpr1s-y
Vmpr2d
Vmpr2d-n
Vmpr2d-y
Vmpr2p
Vmpr2p-n
Vmpr2p-y
Vmpr2s
Vmpr2s-n
Vmpr2s-y
Vmpr3d
Vmpr3d-n
Vmpr3d-y
Vmpr3p
Vmpr3p-n
Vmpr3p-y
Vmpr3s
Vmpr3s-n
Vmpr3s-y
Vmpu
X
Xa
Xe
Xf
Xh
Xp
Xt
Xw
Y
Z
