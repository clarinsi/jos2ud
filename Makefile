### Testing
test-janes:
	${saxon} -xsl:bin/tei2conllu.xsl Data/test.xml > Data/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	bin/add-biti-nosyn.pl Map/JanesTag-biti-as-VERB.txt < Data/test.ud.tbl > Data/test.biti.tbl
test-dist3:
	bin/compare2ud.pl Data/SLV_5000.ud.tbl < Data/SLV_5000-AB2.txt > Data/SLV_5000-AB3.txt 
test-dist2:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/SLV_5000.tbl > Data/SLV_5000.ud.tbl
test-dist1:
	bin/excel2ud.pl Data/sloleks-en_v1.2.tbl \
	< Data/SLV_5000-AB2.txt > Data/SLV_5000.tbl 2> Data/SLV_5000-err1.txt
test-biti:
	cut -f1-6,9-11 < Data/output_ssj500k-en.ud.syn_2.2.conllu > Data/old.tmp
	cut -f1-6,9-11 < Data/ssj500k-en.ud.syn.tbl > Data/new.tmp
	diff Data/old.tmp Data/new.tmp > Data/diff.tmp; date
	wc -l Data/diff.tmp
test-kaja:
	cat < Data/ssj500k-en.ud.tbl | bin/take-syn.pl > Data/ssj500k-en.ud.synonly.tbl
	cd Data; python ../bin/convert_dependencies.py Data/ssj500k-en.ud.synonly.tbl 2.2
test-lex:
	shuf < Data/sloleks-en_v1.2.tbl | head -1000 | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Data/test.lex.tbl
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/test.lex.tbl > Data/test.lex.ud.tbl
test-crp:
	${saxon} -xsl:bin/tei2conllu.xsl Data/test.xml > Data/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	cd Data; ../bin/convert_dependencies.py ../Data/test.ud.tbl 2.2
test-new:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	diff Data/test.ud.old.tbl Data/test.ud.tbl

### For real
nohup:
	date > nohup.all
	nohup time make all >> nohup.all &
all:	janes
xall:	ssj sloleks jos janes

dist:	get-dist format-dist ud-mor-dist
jos:	get-jos format-jos ud-mor-jos
ssj:	get-ssj format-ssj ud-mor-ssj ud-biti-ssj ud-syn-ssj ud-split-ssj
janes:	get-janes format-janes ud-mor-janes

eltec:
	bin/excel2ud.pl Data/sloleks-en_v1.2.tbl \
	< Data/SLV_5000-AB2.txt > Data/SLV_5000.tbl 2> Data/SLV_5000-err1.txt
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/SLV_5000.tbl > Data/SLV_5000.ud.tbl
	bin/compare2ud.pl Data/SLV_5000.ud.tbl \
	< Data/SLV_5000-AB2.txt 2> Data/SLV_5000-err2.txt # > Data/SLV_5000-AB3.txt 

# Process lexicon
sloleks:
	cp ~/Project/SSJ/Lexicon/SloLeks-2.0/sloleks_clarin_2.0-en.tbl Data
	cat < Data/sloleks_clarin_2.0-en.tbl | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Data/sloleks.feats.tmp
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/sloleks.feats.tmp | bin/add-biti-lexicon.pl > Data/sloleks.ud.tbl

# Split corpus into train, dev, test
ud-split-ssj:
	cd Data; ../bin/ud-data-split.py sl_ssj-ud_v2.2.conllu

# Compute UD dependencies
ud-syn-ssj:
	cd Data; ../bin/convert_dependencies.py ../Data/ssj500k-en.ud.syn.tbl 2.2

# Fix "biti" in the both parts of the corpus, the syn. annotated and syn. unannotated one
ud-biti-ssj:
	cat < Data/ssj500k-en.ud.tmp | bin/take-syn.pl only | \
	bin/add-biti-syn.pl > Data/ssj500k-en.ud.syn.tbl
	cat < Data/ssj500k-en.ud.tmp | bin/take-syn.pl except | \
	bin/add-biti-nosyn.pl Map/ssj500k-biti-as-VERB.txt > Data/ssj500k-en.ud.nosyn.tbl
	cat Data/ssj500k-en.ud.syn.tbl Data/ssj500k-en.ud.nosyn.tbl > Data/ssj500k-en.ud.tbl

# Compute UD PoS and features
ud-mor-janes:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/janes.tag.tbl > Data/janes.tag.ud.tmp
	bin/add-biti-nosyn.pl Map/JanesTag-biti-as-VERB.txt < Data/janes.tag.ud.tmp > Data/janes.tag.ud.tbl
ud-mor-ssj:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/ssj500k-en.tbl > Data/ssj500k-en.ud.tmp
ud-mor-jos:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/jos1M-en.tbl > Data/jos1M-en.ud.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/jos1M-en_ssj500k_yes.tbl > Data/jos1M-en_ssj500k_yes.ud.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Data/jos1M-en_ssj500k_no.tbl > Data/jos1M-en_ssj500k_no.ud.tbl

# Format corpus into CONLL-U
format-janes:
	${saxon} -xsl:bin/tei2conllu.xsl Data/janes.tag-single.xml > Data/janes.tag.tbl
format-ssj:
	${saxon} -xi -xsl:bin/tei2conllu.xsl Data/ssj500k.all.xml > Data/ssj500k-en.tbl
format-jos:
	${saxon} -xi -xsl:bin/tei2conllu.xsl Data/jos1M-en.xml > Data/jos1M-en.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl Data/jos1M-en_ssj500k_yes.xml > Data/jos1M-en_ssj500k_yes.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl Data/jos1M-en_ssj500k_no.xml  > Data/jos1M-en_ssj500k_no.tbl

JANES = /home/tomaz/Resources/JANES/Janes/Datasets/Janes-Tag_2.1
get-janes:
	cp ${JANES}/TEI/janes.tag-single.xml Data/
	cp ${JANES}/UD/janes.biti.tbl Map/JanesTag-biti-as-VERB.txt
get-ssj:
	cp /home/tomaz/Project/SSJ/Ucni/ssj500k.2.2/Master/ssj500k.all.xml Data
get-jos:
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en.xml Data
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en_ssj500k_yes.xml Data
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en_ssj500k_no.xml Data

#Get source data from CLARIN.SI repository
xxxget:
	mkdir -p Data
	rm -fr Data/ssj500k-en.TEI
	rm -f Data/ssj500k-en.TEI.zip
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1181/ssj500k-en.TEI.zip
	cd Data; unzip ssj500k-en.TEI.zip
	rm -f Data/sloleks-en*
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1039/sloleks-en.tbl_v1.2.zip
	cd Data; unzip sloleks-en.tbl_v1.2.zip
	rm Data/*.zip

#saxon = java -jar /usr/local/bin/saxon9he.jar
#saxon = java -jar /home/tomaz/bin/saxon9he.jar
saxon = java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform
