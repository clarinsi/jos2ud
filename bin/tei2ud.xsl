<?xml version='1.0' encoding='UTF-8'?>
<!-- Convert CLARIN TEI format to Universal Dependencies format -->
<!-- This is only a format conversion, output linguistic features are not UD! -->
<xsl:stylesheet version='2.0' 
  xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="fn tei et">

  <!-- In the source Punctuation might not have an MSD -->
  <xsl:param name="punct-tag">Z</xsl:param>
  <xsl:param name="punct-name">Punctuation</xsl:param>

  <xsl:key name="id" match="tei:*" use="concat('#',@xml:id)"/>
  <xsl:key name="corresp" match="tei:*" use="substring-after(@corresp,'#')"/>

  <!-- TEI prefix replacement mechanism -->
  <xsl:variable name="prefixes" select="//tei:listPrefixDef"/>

  <!-- The MSD (PoS tag) feature library -->
  <xsl:variable name="msds" select="key('id','#msds')"/>

  <xsl:output encoding="utf-8" method="text"/>
  
  <xsl:strip-space elements="*"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//tei:s"/> 
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:value-of select="concat('# sent_id = ',@xml:id, '&#10;')"/>
    <xsl:variable name="text">
      <xsl:apply-templates mode="plain"/>
    </xsl:variable>
    <xsl:value-of select="concat('# text = ', normalize-space($text), '&#10;')"/>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template mode="plain" match="text()"/>
  <xsl:template mode="plain" match="tei:*">
    <xsl:apply-templates mode="plain"/>
  </xsl:template>
  <xsl:template mode="plain" match="tei:choice">
    <!-- Output normalised tokens only -->
    <xsl:apply-templates mode="plain" select="tei:reg"/>
  </xsl:template>
  <xsl:template mode="plain" match="tei:c">
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <xsl:template mode="plain" match="tei:w | tei:pc">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="tei:choice">
    <xsl:apply-templates select="tei:reg"/>
  </xsl:template>

  <xsl:template match="tei:w | tei:pc">
    <!-- 1/ID -->
    <xsl:apply-templates mode="number" select="."/>
    <xsl:text>&#9;</xsl:text>
    <!-- 2/FORM -->
    <xsl:if test="contains(text(),' ')">
      <xsl:message>
	<xsl:value-of select="concat('ERROR: tokens contains space: ', text())"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="text()"/>
    <xsl:text>&#9;</xsl:text>
    <!-- 3/LEMMA -->
    <xsl:choose>
      <xsl:when test="self::tei:pc and not(@lemma)">
	<xsl:value-of select="text()"/>
      </xsl:when>
      <xsl:when test="not(@lemma)">
	<xsl:message terminate="yes">
	  <xsl:value-of select="concat('ERROR: no lemma for token: ', text())"/>
	</xsl:message>
      </xsl:when>
      <xsl:when test="contains(@lemma,' ')">
	<xsl:message terminate="yes">
	  <xsl:value-of select="concat('ERROR: lemma contains space: ', @lemma)"/>
	</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@lemma"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <xsl:variable name="ana" select="et:prefix-replace(@ana, $prefixes)"/>
    <!-- 4/CPOSTAG -->
    <xsl:choose>
      <xsl:when test="self::tei:pc and not(@ana)">
        <xsl:value-of select="$punct-name"/>
      </xsl:when>
      <xsl:when test="contains(key('id',$ana)/@feats,' ')">
	<xsl:variable name="cat" select="substring-before(key('id',$ana)/@feats,' ')"/>
	<xsl:value-of select="key('id',$cat,$msds)/tei:symbol/@value"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="cat" select="key('id',$ana)/@feats"/>
	<xsl:value-of select="key('id',$cat,$msds)/tei:symbol/@value"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 5/POSTAG -->
    <xsl:choose>
      <xsl:when test="self::tei:pc and not(@ana)">
        <xsl:value-of select="$punct-tag"/>
      </xsl:when>
      <xsl:when test="not(@ana)">
      <xsl:message terminate="yes">
	<xsl:value-of select="concat('ERROR: no msd for token: ', text())"/>
      </xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="substring-after($ana,'#')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 6/FEATS -->
    <xsl:variable name="feats">
      <xsl:for-each select="fn:tokenize(substring-after(key('id',$ana)/@feats,' '),' ')">
	<xsl:text>|</xsl:text>
	<xsl:value-of select="key('id',.,$msds)/@name"/>
	<xsl:text>=</xsl:text>
	<xsl:value-of select="key('id',.,$msds)/tei:symbol/@value"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="normalize-space($feats)">
	<xsl:value-of select="substring-after($feats,'|')"/>
      </xsl:when>
      <xsl:otherwise>_</xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 7/HEAD -->
    <xsl:variable name="Syntax"
		  select="key('corresp',ancestor::tei:s[1]/@xml:id)[@type='syntax']"/>
    <xsl:choose>
      <xsl:when test="$Syntax//tei:link">
	<xsl:call-template name="head">
	  <xsl:with-param name="links" select="$Syntax"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 8/DEPREL -->
    <xsl:choose>
      <xsl:when test="$Syntax//tei:link">
	<xsl:call-template name="rel">
	  <xsl:with-param name="links" select="$Syntax"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#9;</xsl:text>
    <!-- 9/DEPS -->
    <xsl:text>_</xsl:text>
    <xsl:text>&#9;</xsl:text>
    <!-- 10/MISC -->
    <xsl:choose>
      <xsl:when test="not(
		      following::tei:*[1][self::tei:c] or
		      (not(following::tei:*[self::tei:w or self::tei:pc])
		      and
		      (../following::tei:*[1][self::tei:c] or
		      not(../following-sibling::tei:*))
		      ))">
	<xsl:text>SpaceAfter=No</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>_</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Return the number of the head token -->
  <xsl:template name="head">
    <xsl:param name="links"/>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="link" select="$links//tei:link[fn:matches(@target,concat(' #',$id,'$'))]"/>
    <xsl:variable name="head_id" select="substring-before($link/@target,' ')"/>
    <xsl:choose>
      <xsl:when test="key('id',$head_id)/name()= 's'">0</xsl:when>
      <xsl:when test="key('id',$head_id)[name()='pc' or name()='w']">
	<xsl:apply-templates mode="number" select="key('id',$head_id)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:value-of select="concat('ERROR: in link cant find head ', $head_id, ' for id ', $id)"/>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="number" match="tei:*">
    <xsl:if test="not(self::tei:pc or self::tei:w)">
      <xsl:message terminate="yes">
	<xsl:value-of select="concat('ERROR: sequence number for non-token: ', text())"/>
      </xsl:message>
    </xsl:if>
    <!-- Ignore origs! -->
    <xsl:number count="tei:w[not(parent::tei:orig)] | tei:pc[not(parent::tei:orig)]"
 		level="any" from="tei:s"/>
  </xsl:template>

  <!-- Return the name of the syntactic relation -->
  <xsl:template name="rel">
    <xsl:param name="links"/>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="link" select="$links//tei:link[fn:matches(@target,concat(' #',$id,'$'))]"/>
    <xsl:variable name="ana" select="et:prefix-replace($link/@ana, $prefixes)"/>
    <xsl:value-of select="substring-after($link/$ana,'#')"/>
  </xsl:template>

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
