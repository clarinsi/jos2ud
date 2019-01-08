# test-snip:
# 	cat < Data/ssj500k-en.ud.tbl | bin/take-syn.pl > Data/ssj500k-en.ud.synonly.tbl
test-ne:
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/test.feats.tbl | bin/add-biti-lexicon.pl > Data/test.ud.lex
biti:
	cat < Data/ssj500k-en.ud.tmp | bin/add-biti-corpus.pl Data/biti-as-VERB.txt > Data/test-en.ud.tbl
test-lex:
	shuf < Data/sloleks-en.tbl | head -1000 | bin/lex2feats.pl jos-msd2features.tbl > Data/test.lex.tbl
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/test.lex.tbl > Data/test.lex.ud.tbl
test-crp:
	$s -xsl:bin/tei2ud.xsl Data/test.xml > Data/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	cd UD; ../bin/convert_dependencies.py ../Data/test.ud.tbl 2.2
test-new:
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	diff Data/test.ud.old.tbl Data/test.ud.tbl

nohup:
	date > nohup.all
	nohup time make all >> nohup.all &
all:	lexicon
xall:	get format ud-mor ud-syn lexicon

lexicon:
	cat < Data/sloleks-en.tbl | bin/lex2feats.pl jos-msd2features.tbl > Data/sloleks.feats.tbl
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/sloleks.feats.tbl | bin/add-biti-lexicon.pl > Data/sloleks.ud.tbl
ud-syn:
	rm -fr UD; mkdir UD
	cd UD; ../bin/convert_dependencies.py ../Data/ssj500k-en.ud.tbl 2.2
ud-mor:
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/ssj500k-en.tbl > Data/ssj500k-en.ud.tmp
	bin/add-biti-corpus.pl Data/biti-as-VERB.txt < Data/ssj500k-en.ud.tmp > Data/ssj500k-en.ud.tbl
format:
	$s -xi -xsl:bin/tei2ud.xsl Data/ssj500k-en.TEI/ssj500k-en.xml > Data/ssj500k-en.tbl
get:
	rm -fr Data/ssj500k-en.TEI
	rm -f Data/ssj500k-en.TEI.zip
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1181/ssj500k-en.TEI.zip
	cd Data; unzip ssj500k-en.TEI.zip

s = java -jar /usr/local/bin/saxon9he.jar
