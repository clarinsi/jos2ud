<?xml version='1.0' encoding='UTF-8'?>
<!-- Convert CLARIN.SI tei:body/tei:ab/tei:s/tei:w|tei:pc annotations to CoNLL-U format -->
<!-- In the output MULTEXT-East is used, and not Universal Dependencies:
     4/UPOS  MULTEXT-East category
     5/XPOS  MULTEXT-East MSD
     6/FEATS MULTEXT-East fetures

Example:

TEI:

<body xmlns="http://www.tei-c.org/ns/1.0">
  <ab xml:id="tid.1209738757542436864">
    <s xml:id="tid.1209738757542436864.s1">
      <w ana="mte:Ps1msnp" lemma="naš">Naš</w>
      <w join="right">
	tastár
	<w ana="mte:Q" lemma="ta" norm="ta"/>
	<w join="right" ana="mte:Agpmpn" lemma="star" norm="stari"/>
      </w>
      <pc ana="mte:Z" lemma=".">.</pc>
    </s>
    <s xml:id="tid.1209738757542436864.s2">
      <w ana="mte:Ncfsn" lemma="gospa">gospa</w>
      <w ana="mte:Vmpr3s-n" lemma="imeti" norm="ima">ma</w>
      <w ana="mte:Ncmsan" lemma="pelcmontel" norm="pelcmontel" join="right">
	<w>pelc</w>
        <w join="right">montl</w>
      </w>
      <pc ana="mte:Z" lemma=".">.</pc>
    </s>
  </ab>
</body>

CoNLL-U:



-->
<xsl:stylesheet version='2.0' 
  xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="fn tei et">

  <!-- If source TEI does not have the MULTEXT-East feature-structures for decomposing MSDs into features, 
       they should be found in this file: -->
  <xsl:param name="msd-file"/>
  
  <!-- What we call the normalised form in the MISC column -->
  <xsl:param name="NormalisedForm">Style=Coll|CorrectForm=</xsl:param>
    
  <xsl:key name="id" match="tei:*" use="concat('#',@xml:id)"/>
  <xsl:key name="corresp" match="tei:*" use="substring-after(@corresp,'#')"/>

  <!-- Global variable for use of the TEI prefix replacement mechanism -->
  <xsl:variable name="prefixes">
    <xsl:choose>
      <xsl:when test="//tei:listPrefixDef">
	<xsl:copy-of select="//tei:listPrefixDef"/>
      </xsl:when>
      <!-- We just assume listPrefixDefs as they are used in CLARIN.SI TEI -->
      <xsl:otherwise>
	<listPrefixDef>
          <prefixDef ident="mte" matchPattern="(.+)" replacementPattern="#$1"/>
          <prefixDef ident="jos-syn" matchPattern="(.+)" replacementPattern="#$1"/>
          <prefixDef ident="ud-syn" matchPattern="(.+)" replacementPattern="#$1"/>
          <prefixDef ident="mwe" matchPattern="(.+)" replacementPattern="#$1"/>
          <prefixDef ident="srl" matchPattern="(.+)" replacementPattern="#$1"/>
       </listPrefixDef>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- The MSD feature library with with attribute-value pairs, like:
   <fvLib xml:lang="en">
      <fs xml:id="Ncmsn" xml:lang="en" corresp="#Somei"
          feats="#N0 #N1.c #N2.m #N3.s #N4.n"/>
      ...
   </fvLib>
   <fLib xml:lang="en">
      <f name="CATEGORY" xml:id="N0" corresp="#sl-S0" xml:lang="en">
         <symbol value="Noun"/>
      </f>
      <f name="Type" xml:id="N1.c" corresp="#sl-S1.o" xml:lang="en">
         <symbol value="common"/>
      </f>
      ...
   </fLib>
  -->
  <xsl:variable name="msds">
    <xsl:choose>
      <xsl:when test="key('id','#msds')/tei:*">
	<xsl:copy-of select="key('id','#msds')"/>
      </xsl:when>
      <xsl:when test="key('id','#msd-sl')/tei:*">
	<xsl:copy-of select="key('id','#msd-sl')"/>
      </xsl:when>
      <xsl:when test="key('id','#msds', document($msd-file))/tei:*">
	<xsl:copy-of select="key('id', '#msds', document($msd-file))"/>
      </xsl:when>
      <xsl:when test="key('id','#msd-sl', document($msd-file))/tei:*">
	<xsl:copy-of select="key('id', '#msd-sl', document($msd-file))"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>Can't find MSD library!</xsl:text>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:output encoding="utf-8" method="text"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="@*"/>
  
  <xsl:template match="/">
    <xsl:message select="concat('INFO: Processing ', replace(base-uri(), '.+/', ''))"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:ab">
    <xsl:value-of select="concat('# newdoc id = ',@xml:id, '&#10;')"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:value-of select="concat('# sent_id = ',@xml:id, '&#10;')"/>
    <xsl:variable name="text">
      <xsl:apply-templates mode="plain"/>
    </xsl:variable>
    <xsl:value-of select="concat('# text = ', $text, '&#10;')"/>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:w | tei:pc">
    <!-- 1/ID -->
    <xsl:apply-templates mode="number" select="."/>
    <xsl:text>&#9;</xsl:text>
    <!-- 2/FORM -->
    <xsl:apply-templates mode="token" select="."/>
    <xsl:text>&#9;</xsl:text>
    <!-- 3/LEMMA -->
    <xsl:choose>
      <xsl:when test="self::tei:pc and not(@lemma)">
        <xsl:value-of select="substring(@lemma, 1, 1)"/>
      </xsl:when>
      <xsl:when test="not(@lemma)">_</xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@lemma"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 4/UPOS (MULTEXT-East category) -->
    <xsl:variable name="ana" select="et:prefix-replace(@ana, $prefixes)"/>
    <xsl:choose>
      <xsl:when test="not(@ana)">_</xsl:when>
      <xsl:when test="contains(key('id', $ana, $msds)/@feats, ' ')">
	<xsl:variable name="cat" select="substring-before(key('id', $ana, $msds)/@feats, ' ')"/>
	<xsl:value-of select="key('id', $cat, $msds)/tei:symbol/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="cat" select="key('id', $ana, $msds)/@feats"/>
	<xsl:value-of select="key('id', $cat, $msds)/tei:symbol/@value"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 5/XPOS (MULTEXT-East MSD -->
    <xsl:choose>
      <xsl:when test="not(@ana)">_</xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="substring-after($ana,'#')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 6/FEATS (MULTEXT-East fetures) -->
    <xsl:variable name="feats">
      <xsl:for-each select="fn:tokenize(substring-after(key('id', $ana, $msds)/@feats,' '),' ')">
	<xsl:text>|</xsl:text>
	<xsl:value-of select="key('id',. , $msds)/@name"/>
	<xsl:text>=</xsl:text>
	<xsl:value-of select="key('id', ., $msds)/tei:symbol/@value"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(@ana)">_</xsl:when>
      <xsl:when test="normalize-space($feats)">
	<xsl:value-of select="substring-after($feats,'|')"/>
      </xsl:when>
      <xsl:otherwise>_</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 7/HEAD -->
    <xsl:text>_</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <!-- 8/DEPREL -->
    <xsl:text>_</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <!-- 9/DEPS -->
    <xsl:text>_</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <!-- 10/MISC -->
    <xsl:variable name="norm">
      <xsl:apply-templates mode="norm" select="."/>
    </xsl:variable>
    <xsl:variable name="glue">
      <xsl:call-template name="SpaceAfter">
	<xsl:with-param name="no">SpaceAfter=No</xsl:with-param>
	<xsl:with-param name="yes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($norm) and normalize-space($glue)">
	<xsl:value-of select="concat($norm, '|', $glue)"/>
      </xsl:when>
      <xsl:when test="normalize-space($norm)">
	<xsl:value-of select="$norm"/>
      </xsl:when>
      <xsl:when test="normalize-space($glue)">
	<xsl:value-of select="$glue"/>
      </xsl:when>
      <xsl:otherwise>_</xsl:otherwise>
    </xsl:choose>
    
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="tei:*[@ana]"/>
  </xsl:template>

  <xsl:template mode="plain" match="text()"/>
  <xsl:template mode="plain" match="tei:*">
    <xsl:apply-templates mode="plain"/>
  </xsl:template>
  <xsl:template mode="plain" match="tei:w | tei:pc">
    <xsl:choose>
      <!-- n-1 -->
      <xsl:when test="tei:w[@norm]/tei:w">
	<xsl:apply-templates mode="plain"/>
      </xsl:when>
      <!-- 1-n -->
      <xsl:when test="tei:w/tei:w">
	<xsl:value-of select="normalize-space(text()[1])"/>
	<xsl:call-template name="SpaceAfter">
	  <xsl:with-param name="yes">&#32;</xsl:with-param>
	</xsl:call-template>
      </xsl:when>
      <!-- 1-1 -->
      <xsl:otherwise>
	<xsl:value-of select="normalize-space(.)"/>
	<xsl:call-template name="SpaceAfter">
	  <xsl:with-param name="yes">
	    <xsl:text>&#32;</xsl:text>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Output value of ID column. 
       1-n normalised tokens are treated as syntactic words, 
       n-1 normalised tokens are treated as FORMs with spaces, eg.

	1	Naš	naš
	2-3	tastár	_
	2	ta	ta
	3	stari	star
	4	.	.
	
	1	gospa	gospa
	2	ma	imeti
	3	pelc montl	pelcmontel
	4	.	.

   -->
  <xsl:template mode="number" match="tei:*">
    <xsl:if test="not(self::tei:pc or self::tei:w)">
      <xsl:message terminate="yes">
	<xsl:value-of select="concat('ERROR: sequence number for non-token: ', text())"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="simple">
      <xsl:variable name="n">
	<xsl:number count="tei:*[self::tei:w or self::tei:pc][@ana]"
 		    level="any" from="tei:s"/>
      </xsl:variable>
      <xsl:choose>
	<xsl:when test="normalize-space($n)">
	  <xsl:value-of select="$n"/>
	</xsl:when>
	<xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--xsl:message select="concat('INFO: Simple is ', $simple, 
	' for ', ., ' (ID = ', ancestor::tei:ab/@xml:id, ')')"/-->
    <xsl:choose>
      <!-- n-1 -->
      <xsl:when test=".[@norm]/tei:*">
	<xsl:value-of select="$simple"/>
      </xsl:when>
      <!-- 1-n -->
      <xsl:when test="tei:w">
	<xsl:value-of select="$simple + 1"/>
	<xsl:text>-</xsl:text>
	<xsl:value-of select="$simple + count(tei:w | tei:pc)"/>
      </xsl:when>
      <!-- 1-1 -->
      <xsl:otherwise>
	<xsl:value-of select="$simple"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="token" match="tei:*">
    <xsl:choose>
      <!-- n-1 -->
      <xsl:when test=".[@norm]/tei:w">
	<xsl:variable name="token">
	  <xsl:apply-templates mode="plain"/>
	</xsl:variable>
	<xsl:value-of select="normalize-space($token)"/>
      </xsl:when>
      <!-- 1-1 -->
      <xsl:when test="normalize-space(.)">
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <!-- 1-n -->
      <xsl:otherwise>
	<xsl:value-of select="@norm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="norm" match="tei:*">
    <!-- Mark as colloquial, cf. https://universaldependencies.org/misc.html -->
    <!-- n-1 -->
    <xsl:choose>
      <!-- 1-n -->
      <!-- subordinate empty word with @norm: already present in the "syntactic" column, 
	   should not mark it again in MISC -->
      <xsl:when test="not(normalize-space(.))"/>
      <xsl:when test="tei:*[@norm]">
	<xsl:value-of select="$NormalisedForm"/>
	<xsl:for-each select="tei:*">
	  <xsl:value-of select="@norm"/>
	  <!--xsl:value-of select="replace(@norm, '_', '\\_')"/-->
	  <xsl:if test="following-sibling::tei:*">
	    <!--xsl:text>_</xsl:text-->
	    <xsl:text> </xsl:text>
	  </xsl:if>
	</xsl:for-each>
      </xsl:when>
      <xsl:when test="@norm">
	<xsl:value-of select="concat($NormalisedForm, @norm)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Output $no if token is @join-ed to next token, $yes otherwise -->
  <xsl:template name="SpaceAfter">
    <xsl:param name="yes">&#32;</xsl:param>
    <xsl:param name="no"/>
    <xsl:choose>
      <xsl:when test="@join = 'right' or @join='both' or
		      following::tei:*[self::tei:w or self::tei:pc][1]
		      [@join = 'left' or @join = 'both']">
	<xsl:value-of select="$no"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$yes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- If we have <listPrefix>, this untangles it -->
  <xsl:function name="et:prefix-replace">
    <xsl:param name="val"/>
    <xsl:param name="prefixes"/>
    <xsl:choose>
      <xsl:when test="contains($val, ':')">
	<xsl:variable name="prefix" select="substring-before($val, ':')"/>
	<xsl:variable name="val-in" select="substring-after($val, ':')"/>
	<xsl:variable name="match" select="$prefixes//tei:prefixDef[@ident = $prefix]/@matchPattern"/>
	<xsl:variable name="replace" select="$prefixes//tei:prefixDef[@ident = $prefix]/@replacementPattern"/>
	<xsl:value-of select="fn:replace($val-in, $match, $replace)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$val"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
