test-valid:
	python3 bin/tools/validate.py --lang sl --level 1 Origin/ssj500k-en.ud.syn.tbl
	python3 bin/tools/validate.py --lang sl --level 2 Origin/ssj500k-en.ud.syn.tbl

### Testing
test-janes:
	${saxon} -xsl:bin/tei2conllu.xsl Origin/test.xml > Origin/test.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl < Origin/test.tbl > Origin/test.ud.tbl
	bin/add-biti-nosyn.pl Map/JanesTag-biti-as-VERB.txt < Origin/test.ud.tbl > Origin/test.biti.tbl
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
	shuf < Origin/sloleks-en_v1.2.tbl | head -1000 | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Origin/test.lex.tbl
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/test.lex.tbl > Origin/test.lex.ud.tbl
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
ssj:	get-ssj format-ssj ud-mor-ssj ud-biti-ssj ud-syn-ssj ud-val-ssj ud-split-ssj
janes:	get-janes format-janes ud-mor-janes

eltec:
	bin/excel2ud.pl Origin/sloleks-en_v1.2.tbl \
	< Origin/SLV_5000-AB2.txt > Origin/SLV_5000.tbl 2> Origin/SLV_5000-err1.txt
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/SLV_5000.tbl > Origin/SLV_5000.ud.tbl
	bin/compare2ud.pl Origin/SLV_5000.ud.tbl \
	< Origin/SLV_5000-AB2.txt 2> Origin/SLV_5000-err2.txt # > Origin/SLV_5000-AB3.txt 

# Process lexicon
sloleks:
	cp ~/Project/SSJ/Lexicon/SloLeks-2.0/sloleks_clarin_2.0-en.tbl Origin
	cat < Origin/sloleks_clarin_2.0-en.tbl | bin/lex2feats.pl Map/jos-msd2features.tbl \
	> Origin/sloleks.feats.tmp
	LC_ALL=C bin/jos2ud.pl lexicon Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/sloleks.feats.tmp | bin/add-biti-lexicon.pl > Origin/sloleks.ud.tbl

# Split corpus into train, dev, test
ud-split-ssj:
	cd Origin; ../bin/ud-data-split.py sl_ssj-ud_v2.2.conllu

ud-val-ssj:
	python3 bin/tools/validate.py --lang sl --level 1 Origin/ssj500k-en.ud.syn.tbl
	python3 bin/tools/validate.py --lang sl --level 2 Origin/ssj500k-en.ud.syn.tbl
# Compute UD dependencies
ud-syn-ssj:
	cd Origin; ../bin/convert_dependencies.py ../Origin/ssj500k-en.ud.syn.tbl 2.2

# Fix "biti" in the both parts of the corpus, the syn. annotated and syn. unannotated one
ud-biti-ssj:
	cat < Origin/ssj500k-en.ud.tmp | bin/take-syn.pl only | \
	bin/add-biti-syn.pl > Origin/ssj500k-en.ud.syn.tbl
	cat < Origin/ssj500k-en.ud.tmp | bin/take-syn.pl except | \
	bin/add-biti-nosyn.pl Map/ssj500k-biti-as-VERB.txt > Origin/ssj500k-en.ud.nosyn.tbl
	cat Origin/ssj500k-en.ud.syn.tbl Origin/ssj500k-en.ud.nosyn.tbl > Origin/ssj500k-en.ud.tbl

# Compute UD PoS and features
ud-mor-janes:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/janes.tag.tbl > Origin/janes.tag.ud.tmp
	bin/add-biti-nosyn.pl Map/JanesTag-biti-as-VERB.txt < Origin/janes.tag.ud.tmp > Origin/janes.tag.ud.tbl
ud-mor-ssj:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/ssj500k-en.tbl > Origin/ssj500k-en.ud.tmp
ud-mor-jos:
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/jos1M-en.tbl > Origin/jos1M-en.ud.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/jos1M-en_ssj500k_yes.tbl > Origin/jos1M-en_ssj500k_yes.ud.tbl
	LC_ALL=C bin/jos2ud.pl corpus Map/jos2ud-pos.tbl Map/jos2ud-features.tbl \
	< Origin/jos1M-en_ssj500k_no.tbl > Origin/jos1M-en_ssj500k_no.ud.tbl

# Format corpus into CONLL-U
format-janes:
	${saxon} -xsl:bin/tei2conllu.xsl Origin/janes.tag-single.xml > Origin/janes.tag.tbl
format-ssj:
	#${saxon} -xi -xsl:bin/tei2conllu.xsl Origin/ssj500k.all.xml > Origin/ssj500k-en.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl Origin/${ssj-500k}/ssj500k-en.xml > Origin/ssj500k-en.tbl
format-jos:
	${saxon} -xi -xsl:bin/tei2conllu.xsl Origin/jos1M-en.xml > Origin/jos1M-en.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl Origin/jos1M-en_ssj500k_yes.xml > Origin/jos1M-en_ssj500k_yes.tbl
	${saxon} -xi -xsl:bin/tei2conllu.xsl Origin/jos1M-en_ssj500k_no.xml  > Origin/jos1M-en_ssj500k_no.tbl

JANES = /home/tomaz/Resources/JANES/Janes/Originsets/Janes-Tag_2.1
get-janes:
	cp ${JANES}/TEI/janes.tag-single.xml Origin/
	cp ${JANES}/UD/janes.biti.tbl Map/JanesTag-biti-as-VERB.txt

CLARIN.SI = https://www.clarin.si/repository/xmlui/bitstream/handle
ssj-500k  = ssj500k-en.TEI
get-ssj:
	#cp /home/tomaz/Project/SSJ/Ucni/ssj500k.2.2/Master/ssj500k.all.xml Origin
	rm -f Origin/${ssj-500k}.zip; rm -fr Origin/${ssj-500k}/
	cd Origin/; wget ${CLARIN.SI}/11356/1210/${ssj-500k}.zip
	cd Origin/; unzip ${ssj-500k}.zip; rm ${ssj-500k}.zip

get-jos:
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en.xml Origin
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en_ssj500k_yes.xml Origin
	cp /home/tomaz/Resources/CLARIN/jos1M/Fix/jos1M-en_ssj500k_no.xml Origin

xget-ssj500k:
	cd Origin; wget ${CLARIN.SI}/11356/1039/sloleks-en.tbl_v1.2.zip
	cd Origin; unzip sloleks-en.tbl_v1.2.zip
	rm Origin/*.zip

saxon = java -jar /usr/share/java/saxon.jar
#saxon = java -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl -Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl net.sf.saxon.Transform
