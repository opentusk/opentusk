<?xml version="1.0"?>
<xsl:stylesheet	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"/>

  <xsl:template match="/body">
  <xsl:if test="boolean(descendant::keyword) or boolean(descendant::nugget) or boolean(descendant::summary) or boolean(descendant::topic-sentence)">
<div class="colorkey">
<table border="0" cellspacing="5" cellpadding="0" width="200" class="yellowbg-padding">
        <tr>
                <td colspan="2" align="center"><strong class="bluetext">Color Key</strong></td>
        </tr>
        <tr>
                <td align="center" width="4%" class="keyword"></td>
                <td align="left" valign="top" width="60%">Important key words or phrases.</td>
        </tr>
        <tr>
                <td align="center" width="4%" class="nugget"></td>
                <td align="left" valign="top" width="60%">
                        Important concepts or main ideas.
                </td></tr>
        </table>
</div>
</xsl:if>

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
      <xsl:choose>
         <xsl:when test="position() = last()">
	      <xsl:call-template name="aComplete"/>
         </xsl:when>
	 <xsl:otherwise>
	      <xsl:call-template name="aSummary"/>
         </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-2">
	<xsl:param name="display">0</xsl:param>
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
      <xsl:choose>
         <xsl:when test="$display = 1">
	      <xsl:call-template name="aComplete"/>
         </xsl:when>
	 <xsl:otherwise>
	      <xsl:call-template name="aSummary"/>
         </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-3">
	<xsl:param name="display">0</xsl:param>
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
      <xsl:choose>
         <xsl:when test="$display = 1">
	      <xsl:call-template name="aComplete"/>
         </xsl:when>
	 <xsl:otherwise>
	      <xsl:call-template name="aSummary"/>
         </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-4">
	<xsl:param name="display">0</xsl:param>
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
      <xsl:choose>
         <xsl:when test="$display = 1">
	      <xsl:call-template name="aComplete"/>
         </xsl:when>
	 <xsl:otherwise>
	      <xsl:call-template name="aSummary"/>
         </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-5">
	<xsl:param name="display">0</xsl:param>
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
      <xsl:choose>
         <xsl:when test="$display = 1">
	      <xsl:call-template name="aComplete"/>
         </xsl:when>
	 <xsl:otherwise>
	      <xsl:call-template name="aSummary"/>
         </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="section-title"/>
  
  <xsl:template match="section-title" mode="show">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template name="aSummary">
    <xsl:apply-templates select="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5|keyword|nugget|summary|topic-sentence|warning|para|enumerated-list|itemized-list|list-item|table|td|tr|th"/>
  </xsl:template>

  <xsl:template name="aComplete">
    <xsl:apply-templates select="section-level-2|section-level-3|para|itemized-list|enumerated-list">
	<xsl:with-param name="display" select="1" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="enumerated-list">
	<xsl:param name="display">0</xsl:param>
	<xsl:if test="$display = 1">
	    <ol>
	      <xsl:call-template name="aClass"/>
	      <xsl:call-template name="aList"/>
	    </ol>
	</xsl:if>    
  </xsl:template>

  <xsl:template match="itemized-list">
	<xsl:param name="display">0</xsl:param>
	<xsl:if test="$display = 1">
	    <ul>
	      <xsl:call-template name="aClass"/>
	      <xsl:call-template name="aList"/>
	    </ul>
	</xsl:if>    
  </xsl:template>

  <xsl:template match="para">
	<xsl:param name="display" />
	<xsl:choose>
		<xsl:when test="$display = 1">
		    <xsl:call-template name="aLink"/>
		    <p>
		      <xsl:call-template name="aClass"/>
		      <xsl:apply-templates/>
		    </p>
		</xsl:when>	
		<xsl:otherwise>
			<xsl:apply-templates select="keyword|nugget|summary|topic-sentence|warning"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>


  <xsl:template match="table">
      <xsl:choose>
	      <xsl:when test="descendant::hsdb-graphic" />
	      <xsl:otherwise> 
		    <xsl:call-template name="aLink"/>
		    <table>
		      <xsl:call-template name="aTableAtts"/>
		      <xsl:apply-templates/>
		    </table>
	      </xsl:otherwise>
       </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tr">
    <tr>
      <xsl:call-template name="aTableAtts"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="td">
    <td>
      <xsl:call-template name="aTableAtts"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="th">
    <td class="head">
      <xsl:call-template name="aTableAtts"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template name="aTableAtts">
    <xsl:for-each select="@width|@border|@cellspacing|@cellpadding|@rowspan|@colspan|@align|@valign">
      <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="aList">
    <xsl:for-each select="list-item">
      <li>
        <xsl:apply-templates/>
      </li>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="caption" />

  <xsl:template match="keyword|nugget|summary|topic-sentence|warning">
    <xsl:choose>
	    <xsl:when test="parent::section-title">
		<span><xsl:call-template name="aClass"/><xsl:apply-templates/></span>
	    </xsl:when>
	    <xsl:when test="ancestor::table">
		<span><xsl:call-template name="aClass"/><xsl:apply-templates/></span>
	    </xsl:when>
	    <xsl:otherwise>
		    <p><span><xsl:call-template name="aClass"/><xsl:apply-templates/></span></p>
	    </xsl:otherwise>
    </xsl:choose>
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

