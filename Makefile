### Testing
test-biti:
	cut -f1-6,9-11 < Data/output_ssj500k-en.ud.syn_2.2.conllu > Data/old.tmp
	cut -f1-6,9-11 < Data/ssj500k-en.ud.syn.tbl > Data/new.tmp
	diff Data/old.tmp Data/new.tmp > Data/diff.tmp; date
	wc -l Data/diff.tmp
test-kaja:
	cat < Data/ssj500k-en.ud.tbl | bin/take-syn.pl > Data/ssj500k-en.ud.synonly.tbl
	cd Data; python ../bin/convert_dependencies.py Data/ssj500k-en.ud.synonly.tbl 2.2
test-lex:
	shuf < Data/sloleks-en_v1.2.tbl | head -1000 | bin/lex2feats.pl jos-msd2features.tbl > Data/test.lex.tbl
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/test.lex.tbl > Data/test.lex.ud.tbl
test-crp:
	${saxon} -xsl:bin/tei2ud.xsl Data/test.xml > Data/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	cd Data; ../bin/convert_dependencies.py ../Data/test.ud.tbl 2.2
test-new:
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	diff Data/test.ud.old.tbl Data/test.ud.tbl

### For real
nohup:
	date > nohup.all
	nohup time make all >> nohup.all &
all:	get format ud-mor ud-biti ud-syn split lexicon
xall:	get format ud-mor ud-biti ud-syn split lexicon

# Process lexicon
lexicon:
	cat < Data/sloleks-en_v1.2.tbl | bin/lex2feats.pl jos-msd2features.tbl > Data/sloleks.feats.tmp
	LC_ALL=C bin/jos2ud.pl lexicon jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/sloleks.feats.tmp | bin/add-biti-lexicon.pl > Data/sloleks.ud.tbl

# Split corpus into train, dev, test
split:
	cd Data; ../bin/ud-data-split.py sl_ssj-ud_v2.2.conllu

# Compute UD dependencies
ud-syn:
	cd Data; ../bin/convert_dependencies.py ../Data/ssj500k-en.ud.syn.tbl 2.2

# Fix "biti" in the both parts of the corpus, the syn. annotated and syn. unannotated one
ud-biti:
	cat < Data/ssj500k-en.ud.tmp | bin/take-syn.pl only | \
	bin/add-biti-syn.pl > Data/ssj500k-en.ud.syn.tbl
	cat < Data/ssj500k-en.ud.tmp | bin/take-syn.pl except | \
	bin/add-biti-nosyn.pl biti-as-VERB.txt > Data/ssj500k-en.ud.nosyn.tbl
	cat Data/ssj500k-en.ud.syn.tbl Data/ssj500k-en.ud.nosyn.tbl > Data/ssj500k-en.ud.tbl

# Compute UD PoS and features
ud-mor:
	LC_ALL=C bin/jos2ud.pl corpus jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/ssj500k-en.tbl > Data/ssj500k-en.ud.tmp

# Format corpus into CONLL-U
format:
	${saxon} -xi -xsl:bin/tei2ud.xsl Data/ssj500k-en.TEI/ssj500k-en.xml > Data/ssj500k-en.tbl

#Get source data from CLARIN.SI repository
get:
	mkdir -p Data
	rm -fr Data/ssj500k-en.TEI
	rm -f Data/ssj500k-en.TEI.zip
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1181/ssj500k-en.TEI.zip
	cd Data; unzip ssj500k-en.TEI.zip
	rm -f Data/sloleks-en*
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1039/sloleks-en.tbl_v1.2.zip
	cd Data; unzip sloleks-en.tbl_v1.2.zip
	rm Data/*.zip

saxon = java -jar /usr/local/bin/saxon9he.jar
