dlex:
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/sloleks.feats.tmp | bin/add-biti-lexicon.pl > Data/sloleks.ud.tbl
test-split:
	bin/ud-data-split.py Data/sl_ssj-ud_v2.2.conllu
test-biti2:
	cut -f1-6,9-11 < Data/output_ssj500k-en.ud.syn_2.2.conllu > Data/old.tmp
	cut -f1-6,9-11 < Data/ssj500k-en.ud.syn.tbl > Data/new.tmp
	diff Data/old.tmp Data/new.tmp > Data/diff.tmp; date
	wc -l Data/diff.tmp
test-biti:
	cut -f1-4 < Data/output_ssj500k-en.ud.syn_2.2.conllu > Data/old.tmp
	bin/add-biti-syn.pl < Data/ssj500k-en.ud.syn.tmp > Data/ssj500k-en.ud1.tmp
	cut -f1-4 < Data/ssj500k-en.ud1.tmp > Data/new.tmp
	diff Data/old.tmp Data/new.tmp > Data/diff.tmp; date
	wc -l Data/diff.tmp
test-kaja:
	cat < Data/ssj500k-en.ud.tbl | bin/take-syn.pl > Data/ssj500k-en.ud.synonly.tbl
	cd Data; python ../bin/convert_dependencies.py Data/ssj500k-en.ud.synonly.tbl 2.2
test-lex:
	shuf < Data/sloleks-en.tbl | head -1000 | bin/lex2feats.pl jos-msd2features.tbl > Data/test.lex.tbl
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/test.lex.tbl > Data/test.lex.ud.tbl
test-crp:
	$s -xsl:bin/tei2ud.xsl Data/test.xml > Data/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	cd Data; ../bin/convert_dependencies.py ../Data/test.ud.tbl 2.2
test-new:
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	diff Data/test.ud.old.tbl Data/test.ud.tbl

nohup:
	date > nohup.all
	nohup time make all >> nohup.all &
all:	lexicon
xall:	get format ud-mor ud-biti ud-syn lexicon

lexicon:
	cat < Data/sloleks-en.tbl | bin/lex2feats.pl jos-msd2features.tbl > Data/sloleks.feats.tmp
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/sloleks.feats.tmp | bin/add-biti-lexicon.pl > Data/sloleks.ud.tbl
ud-syn:
	cd Data; ../bin/convert_dependencies.py ../Data/ssj500k-en.ud.syn.tbl 2.2
ud-biti:
	cat < Data/ssj500k-en.ud.tmp | bin/take-syn.pl only | \
	bin/add-biti-syn.pl > Data/ssj500k-en.ud.syn.tbl
	cat < Data/ssj500k-en.ud.tmp | bin/take-syn.pl except | \
	bin/add-biti-nosyn.pl Data/biti-as-VERB.txt > Data/ssj500k-en.ud.nosyn.tbl
	cat Data/ssj500k-en.ud.syn.tbl Data/ssj500k-en.ud.nosyn.tbl > Data/ssj500k-en.ud.tbl
ud-mor:
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/ssj500k-en.tbl > Data/ssj500k-en.ud.tmp

format:
	${s} -xi -xsl:bin/tei2ud.xsl Data/ssj500k-en.TEI/ssj500k-en.xml > Data/ssj500k-en.tbl

#Get source data from CLARIN.SI repository
get:
	rm -fr Data/ssj500k-en.TEI
	rm -f Data/ssj500k-en.TEI.zip
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1181/ssj500k-en.TEI.zip
	cd Data; unzip ssj500k-en.TEI.zip

s = java -jar /usr/local/bin/saxon9he.jar
