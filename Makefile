test:
	$s -xsl:bin/tei2ud.xsl Data/test.xml > Data/test.tbl
	LC_ALL=C bin/jos2ud.pl jos2ud-pos.tbl jos2ud-features.tbl < Data/test.tbl > Data/test.ud.tbl
	cd UD; ../bin/convert_dependencies.py ../Data/test.ud.tbl 2.2
nohup:
	nohup time make all > nohup.all &
all:	format ud-mor ud-syn
xall:	get format ud-mor ud-syn
ud-syn:
	rm -fr UD; mkdir UD
	cd UD; ../bin/convert_dependencies.py ../Data/ssj500k-en.ud.tbl 2.2
ud-mor:
	LC_ALL=C bin/jos2ud.pl jos2ud-pos.tbl jos2ud-features.tbl \
	< Data/ssj500k-en.tbl > Data/ssj500k-en.ud.tbl
format:
	$s -xi -xsl:bin/tei2ud.xsl Data/ssj500k-en.TEI/ssj500k-en.xml > Data/ssj500k-en.tbl
get:
	rm -fr Data/ssj500k-en.TEI
	rm -f Data/ssj500k-en.TEI.zip
	cd Data; wget https://www.clarin.si/repository/xmlui/bitstream/handle/11356/1181/ssj500k-en.TEI.zip
	cd Data; unzip ssj500k-en.TEI.zip

s = java -jar /usr/local/bin/saxon9he.jar
