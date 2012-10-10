<?xml version="1.0"?>
<xsl:stylesheet	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"/>

  <xsl:template match="/body">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="section-level-1">
    <div class="section-level-1">
      <xsl:call-template name="aLink"/>
      <h1 class="section-level-1">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"></xsl:when>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="I. "/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. "/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h1>
      <xsl:call-template name="aSummary"/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-2">
    <div class="section-level-2">
      <xsl:call-template name="aLink"/>
      <h2 class="section-level-2">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"></xsl:when>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="A. " level="single" count="section-level-1|section-level-2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h2>
      <xsl:call-template name="aSummary"/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-3">
    <div class="section-level-3">
      <xsl:call-template name="aLink"/>
      <h3 class="section-level-3">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"></xsl:when>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="1. " level="single" count="section-level-1|section-level-2|section-level-3"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h3>
      <xsl:call-template name="aSummary"/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-4">
    <div class="section-level-4">
      <xsl:call-template name="aLink"/>
      <h4 class="section-level-4">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"></xsl:when>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="a. " level="single" count="section-level-1|section-level-2|section-level-3|section-level-4"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h4>
      <xsl:call-template name="aSummary"/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-5">
    <div class="section-level-5">
      <xsl:call-template name="aLink"/>
      <h5 class="section-level-5">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='numbered']"></xsl:when>
	  <xsl:when test="ancestor::body[@levelstyle='outline']">
	       <xsl:number format="i. " level="single" count="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5"/>
	  </xsl:when>
	  <xsl:otherwise>
	       <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5"/>
	  </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h5>
      <xsl:call-template name="aSummary"/>
    </div>
  </xsl:template>

  <xsl:template match="section-title"/>
  
  <xsl:template match="section-title" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="aSummary">
    <xsl:apply-templates select="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5|keyword|nugget|summary|topic-sentence|warning|para|enumerated-list|itemized-list|list-item"/>
  </xsl:template>

  <xsl:template match="para|list-item">
	<xsl:apply-templates select="keyword|nugget|summary|topic-sentence|warning"/>
  </xsl:template>

  <xsl:template match="keyword|nugget|summary|topic-sentence|warning">
    <p><span><xsl:call-template name="aClass"/><xsl:apply-templates/></span></p>
  </xsl:template>

  <xsl:template match="umls-concept[@status='verified']">
    <a>	
    <xsl:call-template name="aClass"/>
    <xsl:attribute name="href">
      <xsl:text>/hsdb4/concept/</xsl:text>
      <xsl:value-of select="@concept-id"/>
    </xsl:attribute>
    <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="objective-item">
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:text>/hsdb4/objective/</xsl:text>
        <xsl:value-of select="@objective-id"/>
      </xsl:attribute>				
      <xsl:apply-templates/>				
    </a>
  </xsl:template>
    
  <xsl:template name="aClass">
    <xsl:attribute name="class">
      <xsl:value-of select="name()"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="aLink">
    <a name="{@id}"></a>
  </xsl:template>  

</xsl:stylesheet>

