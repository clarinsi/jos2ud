suk-senticore:
	#dos2unix Origin/SUK-SentiCore/SUK-SentiCoref-*.tsv
	ls Origin/SUK-SentiCore/SUK-SentiCoref-*.tsv | $P --jobs 10 \
	'bin/conllu-senti2tei.pl < {} > {.}.xml'
	ls Origin/SUK-SentiCore/SUK-SentiCoref-*.xml | $P --jobs 10 \
	'${saxon} msd-file=../Map/ssj500k.back.xml -xsl:bin/tei2conllu.xsl {} > {.}.tbl'
	ls Origin/SUK-SentiCore/SUK-SentiCoref-*.tbl | $P --jobs 10 \
	'LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < {} > {.}.conllu'
	python3 bin/tools/validate.py --lang sl --level 1 Origin/Slobench/*.conllu
	# python3 bin/tools/validate.py --lang sl --level 2 Origin/Slobench/*.conllu
suk-senticore-test:
	#dos2unix Origin/SUK-SentiCore/SUK-SentiCoref-10009.tsv
	bin/conllu-senti2tei.pl < Origin/SUK-SentiCore/SUK-SentiCoref-10009.tsv > Origin/SUK-SentiCore/SUK-SentiCoref-10009.xml
	${saxon} msd-file=../Map/ssj500k.back.xml -xsl:bin/tei2conllu.xsl \
	Origin/SUK-SentiCore/SUK-SentiCoref-10009.xml > Origin/SUK-SentiCore/SUK-SentiCoref-10009.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/SUK-SentiCore/SUK-SentiCoref-10009.tbl > Origin/SUK-SentiCore/SUK-SentiCoref-10009.conllu
	python3 bin/tools/validate.py --lang sl --level 1 Origin/SUK-SentiCore/SUK-SentiCoref-10009.conllu

suk-ambiga:
	dos2unix Origin/SUK-Ambiga/SUK-Ambiga_MANUAL-LEMMA-MSD_2022-10-10.tsv
	bin/conllu-ambiga2tei.pl \
	< Origin/SUK-Ambiga/SUK-Ambiga_MANUAL-LEMMA-MSD_2022-10-10.tsv > Origin/SUK-Ambiga/SUK-Ambiga_UD_2022-10-11.tsv
	${saxon} msd-file=../Map/ssj500k.back.xml -xsl:bin/tei2conllu.xsl \
	Origin/SUK-Ambiga/SUK-Ambiga_UD_2022-10-11.tsv > Origin/SUK-Ambiga/SUK-Ambiga_UD_2022-10-11.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/SUK-Ambiga/SUK-Ambiga_UD_2022-10-11.tbl > Origin/SUK-Ambiga/SUK-Ambiga_UD_2022-10-11.conllu
	python3 bin/tools/validate.py --lang sl --level 1 Origin/SUK-Ambiga/SUK-Ambiga_UD_2022-10-11.conllu
suk-ambiga-test:
	#dos2unix Origin/SUK-Ambiga/Ambiga_test.tsv
	bin/conllu2ambiga2tei.pl < Origin/SUK-Ambiga/Ambiga_test.tsv > Origin/SUK-Ambiga/Ambiga_test.xml
	${saxon} msd-file=../Map/ssj500k.back.xml -xsl:bin/tei2conllu.xsl \
	Origin/SUK-Ambiga/Ambiga_test.xml > Origin/SUK-Ambiga/Ambiga_test.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/SUK-Ambiga/Ambiga_test.tbl > Origin/SUK-Ambiga/Ambiga_test.conllu
	python3 bin/tools/validate.py --lang sl --level 1 Origin/SUK-Ambiga/Ambiga_test.conllu

check-feats:
	bin/slolex2shortlex.pl < Origin/Sloleks/sloleks.ud.tbl | sort | uniq > Origin/Sloleks/sloleks.short.lex
	bin/conllu2shortlex.pl < Origin/manually-corrected_sl_ssj-ud_v2.2_2.5.conllu \
	| sort | uniq > Origin/ssj500k/ssj500k.short.lex
	cut -f1-4 Origin/Sloleks/sloleks.short.lex | uniq -d
	cut -f1-4 Origin/ssj500k/ssj500k.short.lex | uniq -d
	bin/cmpshortlex.pl Origin/ssj500k/ssj500k.short.lex Origin/Sloleks/sloleks.short.lex
kaja3-test:
	bin/conllu-senti2tei.pl < Origin/Slobench/senticoref_10020.tsv \
	> Origin/Slobench/senticoref_10020.xml
	${saxon} msd-file=../Map/ssj500k.back.xml \
	-xsl:bin/tei2conllu.xsl Origin/Slobench/senticoref_10020.xml \
	> Origin/Slobench/senticoref_10020.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/Slobench/senticoref_10020.tbl > Origin/Slobench/senticoref_10020.conllu
	python3 bin/tools/validate.py --lang sl --level 1 Origin/Slobench/senticoref_10020.conllu
	# python3 bin/tools/validate.py --lang sl --level 2 Origin/Slobench/senticoref_10020.conllu
kaja3:
	dos2unix Origin/Slobench/senticoref_*.tsv
	ls Origin/Slobench/senticoref_*.tsv | $P --jobs 10 \
	'bin/conllu-senti2tei.pl < {} > {.}.xml'
	ls Origin/Slobench/senticoref_*.xml | $P --jobs 10 \
	'${saxon} msd-file=../Map/ssj500k.back.xml -xsl:bin/tei2conllu.xsl {} > {.}.tbl'
	ls Origin/Slobench/senticoref_*.tbl | $P --jobs 10 \
	'LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < {} > {.}.conllu'
	python3 bin/tools/validate.py --lang sl --level 1 Origin/Slobench/*.conllu
	# python3 bin/tools/validate.py --lang sl --level 2 Origin/Slobench/*.conllu
kaja2:
	bin/conllu2tei.pl < Origin/ELEXIS-WSD/ELEXIS-WSD-SL_RSDO_corr-KD_no-UPOS.tsv \
	> Origin/ELEXIS-WSD/ELEXIS-WSD-SL_RSDO_corr-KD_no-UPOS.xml
	${saxon} msd-file=../Map/ssj500k.back.xml \
	-xsl:bin/tei2conllu.xsl Origin/ELEXIS-WSD/ELEXIS-WSD-SL_RSDO_corr-KD_no-UPOS.xml \
	> Origin/ELEXIS-WSD/ELEXIS-WSD-SL_RSDO_corr-KD_no-UPOS.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/ELEXIS-WSD/ELEXIS-WSD-SL_RSDO_corr-KD_no-UPOS.tbl \
	> Origin/ELEXIS-WSD/ELEXIS-WSD-SL_RSDO_corr-KD_no-UPOS.conllu
kaja1:
	bin/conllu2tei.pl < Origin/ELEXIS-WSD/ELEXIS-WSD-SL_SPACEAFTER_UPOS.tsv \
	> Origin/ELEXIS-WSD/ELEXIS-WSD-SL_SPACEAFTER_UPOS.xml
	${saxon} msd-file=../Map/ssj500k.back.xml \
	-xsl:bin/tei2conllu.xsl Origin/ELEXIS-WSD/ELEXIS-WSD-SL_SPACEAFTER_UPOS.xml \
	> Origin/ELEXIS-WSD/ELEXIS-WSD-SL_SPACEAFTER_UPOS.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/ELEXIS-WSD/ELEXIS-WSD-SL_SPACEAFTER_UPOS.tbl \
	> Origin/ELEXIS-WSD/ELEXIS-WSD-SL_SPACEAFTER_UPOS.conllu

test-ssj:
	${saxon} -xi -xsl:bin/tei2conllu.xsl Origin/test.xml > Origin/test.tbl
test-valid:
	python3 bin/tools/validate.py --lang sl --level 1 Origin/ssj500k-en.ud.syn.tbl
	python3 bin/tools/validate.py --lang sl --level 2 Origin/ssj500k-en.ud.syn.tbl

### Testing
test-janes:
	${saxon} -xsl:bin/tei2conllu.xsl Origin/Janes-Tag/test.xml > Origin/Janes-Tag/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/Janes-Tag/test.tbl > Origin/Janes-Tag/test.ud.tbl
	bin/add-biti-nosyn.pl Map/JanesTag-biti-as-VERB.txt \
	< Origin/Janes-Tag/test.ud.tbl > Origin/Janes-Tag/test.biti.tbl
test-dist3:
	bin/compare2ud.pl Origin/SLV_5000.ud.tbl < Origin/SLV_5000-AB2.txt > Origin/SLV_5000-AB3.txt 
test-dist2:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/SLV_5000.tbl > Origin/SLV_5000.ud.tbl
test-dist1:
	bin/excel2ud.pl Origin/sloleks-en_v1.2.tbl \
	< Origin/SLV_5000-AB2.txt > Origin/SLV_5000.tbl 2> Origin/SLV_5000-err1.txt
test-biti:
	cut -f1-6,9-11 < Origin/output_ssj500k-en.ud.syn_2.2.conllu > Origin/old.tmp
	cut -f1-6,9-11 < Origin/ssj500k-en.ud.syn.tbl > Origin/new.tmp
	diff Origin/old.tmp Origin/new.tmp > Origin/diff.tmp; date
	wc -l Origin/diff.tmp
test-kaja:
	cat < Origin/ssj500k-en.ud.tbl | bin/take-syn.pl > Origin/ssj500k-en.ud.synonly.tbl
	cd Origin; python ../bin/convert_dependencies.py Origin/ssj500k-en.ud.synonly.tbl 2.2
test-lex:
	#grep '	več	Rgc	' < Origin/sloleks-en_v1.2.tbl | bin/lex2feats.pl Map/jos-msd2features.tbl \
	#> Origin/test.lex.tbl
	shuf < Origin/Sloleks/sloleks-en_v1.2.tbl | head -1000 | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Origin/Sloleks/test.lex.tbl
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/Sloleks/test.lex.tbl > Origin/Sloleks/test.lex.ud.tbl
test-crp:
	${saxon} -xsl:bin/tei2conllu.xsl Origin/test.xml > Origin/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < Origin/test.tbl > Origin/test.ud.tbl
	cd Origin; ../bin/convert_dependencies.py ../Origin/test.ud.tbl 2.2
test-new:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < Origin/test.tbl > Origin/test.ud.tbl
	diff Origin/test.ud.old.tbl Origin/test.ud.tbl

### For real
nohup:
	date > nohup.all
	nohup time make all >> nohup.all &
all:	ssj
xall:	ssj sloleks jos janes

dist:	get-dist format-dist ud-mor-dist
jos:	get-jos format-jos ud-mor-jos
ssj:	format-ssj ud-mor-ssj ud-biti-ssj ud-syn-ssj ud-split-ssj ud-val-ssj
xssj:	get-ssj format-ssj ud-mor-ssj ud-biti-ssj ud-syn-ssj ud-split-ssj ud-val-ssj
janes:	get-janes format-janes ud-mor-janes

eltec:
	bin/excel2ud.pl Origin/Sloleks/sloleks-en_v1.2.tbl \
	< Origin/SLV_5000-AB2.txt > Origin/SLV_5000.tbl 2> Origin/SLV_5000-err1.txt
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/SLV_5000.tbl > Origin/SLV_5000.ud.tbl
	bin/compare2ud.pl Origin/SLV_5000.ud.tbl \
	< Origin/SLV_5000-AB2.txt 2> Origin/SLV_5000-err2.txt # > Origin/SLV_5000-AB3.txt 

# Process lexicons
mfidaleks:
	zcat ~/Project/SSJ/MetaFida/mfida01.wfl.gz | bin/filter-lex.pl > Origin/MFida/mfida01-lex.tbl
	cat < Origin/MFida/mfida01-lex.tbl | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Origin/MFida/mfida-lex.feats.tmp
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/MFida/mfida-lex.feats.tmp | bin/add-biti-lexicon.pl > Origin/MFida/mfida-lex.ud.tbl
sloleks:
	cp ~/Project/SSJ/Lexicon/SloLeks-2.0/sloleks_clarin_2.0-en.tbl Origin/Sloleks
	cat < Origin/Sloleks/sloleks_clarin_2.0-en.tbl | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Origin/Sloleks/sloleks.feats.tmp
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/Sloleks/sloleks.feats.tmp | bin/add-biti-lexicon.pl > Origin/Sloleks/sloleks.ud.tbl

ud-val-ssj:
	python3 bin/tools/validate.py --lang sl --level 1 Origin/sl_ssj-ud-*.conllu
	python3 bin/tools/validate.py --lang sl --level 2 Origin/sl_ssj-ud-*.conllu

# Split corpus into train, dev, test
ud-split-ssj:
	cd Origin/ssj500k; ../bin/ud-data-split.py manually-corrected_sl_ssj-ud_v2.2_2.5.conllu

# Compute UD dependencies
ud-syn-ssj:
	cd Origin/ssj500k; ../bin/convert_dependencies.py ssj500k-en.ud.syn.tbl 2.2
	cd Origin/ssj500k; ../bin/correct_dependencies.py sl_ssj-ud_v2.2.conllu 2.5

# Fix "biti" in the both parts of the corpus, the syn. annotated and syn. unannotated one
ud-biti-ssj:
	cat < Origin/ssj500k/ssj500k-en.ud.tmp | bin/take-syn.pl only | \
	bin/add-biti-syn.pl > Origin/ssj500k/ssj500k-en.ud.syn.tbl
	cat < Origin/ssj500k/ssj500k-en.ud.tmp | bin/take-syn.pl except | \
	bin/add-biti-nosyn.pl Map/ssj500k-biti-as-VERB.txt > Origin/ssj500k/ssj500k-en.ud.nosyn.tbl
	cat Origin/ssj500k/ssj500k-en.ud.syn.tbl Origin/ssj500k/ssj500k-en.ud.nosyn.tbl \
	> Origin/ssj500k/ssj500k-en.ud.tbl

# Compute UD PoS and features
ud-mor-janes:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/Janes-Tag/janes.tag.tbl > Origin/Janes-Tag/janes.tag.ud.tmp
	bin/add-biti-nosyn.pl Map/JanesTag-biti-as-VERB.txt \
	< Origin/Janes-Tag/janes.tag.ud.tmp > Origin/Janes-Tag/janes.tag.ud.tbl
ud-mor-ssj:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/ssj500k/ssj500k-en.tbl > Origin/ssj500k/ssj500k-en.ud.tmp
ud-mor-jos:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/jos1M/jos1M-en.tbl > Origin/jos1M/jos1M-en.ud.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/jos1M/jos1M-en_ssj500k_yes.tbl > Origin/jos1M/jos1M-en_ssj500k_yes.ud.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/jos1M/jos1M-en_ssj500k_no.tbl > Origin/jos1M/jos1M-en_ssj500k_no.ud.tbl

# Format corpus into CONLL-U
format-janes:
	${saxon} -xsl:bin/tei2conllu.xsl \
	Origin/Janes-Tag/janes.tag-single.xml > Origin/Janes-Tag/janes.tag.tbl
format-ssj:
	${saxon} -xi -xsl:bin/tei2conllu.xsl \
	Origin/ssj500k/ssj500k-en.TEI/ssj500k-en.xml > Origin/ssj500k/ssj500k-en.tbl
format-jos:
	${saxon} -xi -xsl:bin/tei2conllu.xsl \
	Origin/jos1M/jos1M-en.xml > Origin/jos1M/jos1M-en.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl \
	Origin/jos1M/jos1M-en_ssj500k_yes.xml > Origin/jos1M/jos1M-en_ssj500k_yes.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl \
	Origin/jos1M/jos1M-en_ssj500k_no.xml  > Origin/jos1M/jos1M-en_ssj500k_no.tbl

JANES = /home/tomaz/Resources/JANES/Janes/Originsets/Janes-Tag_2.1
get-janes:
	cp ${JANES}/TEI/janes.tag-single.xml Origin/Janes-Tag/
	cp ${JANES}/UD/janes.biti.tbl Map/JanesTag-biti-as-VERB.txt

CLARIN.SI = https://www.clarin.si/repository/xmlui/bitstream/handle
get-ssj:
	#cp /home/tomaz/Project/SSJ/Ucni/ssj500k.2.2/Master/ssj500k.all.xml Origin
	rm -f Origin/ssj500k/ssj500k-en.TEI.zip; rm -fr Origin/ssj500k/ssj500k-en.TEI/
	cd Origin/ssj500k/; wget ${CLARIN.SI}/11356/1210/ssj500k-en.TEI.zip
	cd Origin/ssj500k/; unzip ssj500k-en.TEI.zip; rm ssj500k-en.TEI.zip

get-jos:
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en.xml Origin/jos1M
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en_ssj500k_yes.xml Origin/jos1M
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en_ssj500k_no.xml Origin/jos1M

xget-ssj500k:
	cd Origin; wget ${CLARIN.SI}/11356/1039/sloleks-en.tbl_v1.2.zip
	cd Origin/Sloleks/; unzip sloleks-en.tbl_v1.2.zip
	rm Origin/*.zip


#####################################################
saxon = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
