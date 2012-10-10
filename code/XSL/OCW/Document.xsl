<?xml version="1.0"?>
<xsl:stylesheet	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html"/>

  <xsl:param name="CONTENTID" />

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
    <div id="{@id}" class="section-level-1">
      <xsl:call-template name="aLink"/>
      <h1 class="section-level-1">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"/>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="I. "/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. "/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h1>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-2">
    <div id="{@id}" class="section-level-2">
      <xsl:call-template name="aLink"/>
      <h2 class="section-level-2">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"/>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="A. " level="single" count="section-level-1|section-level-2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h2>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-3">
    <div id="{@id}" class="section-level-3">
      <xsl:call-template name="aLink"/>
      <h3 class="section-level-3">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"/>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="1. " level="single" count="section-level-1|section-level-2|section-level-3"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h3>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-4">
    <div id="{@id}" class="section-level-4">
      <xsl:call-template name="aLink"/>
      <h4 class="section-level-4">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='naked']"/>
          <xsl:when test="ancestor::body[@levelstyle='outline']">
            <xsl:number format="a. " level="single" count="section-level-1|section-level-2|section-level-3|section-level-4"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h4>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="section-level-5">
    <div id="{@id}" class="section-level-5">
      <xsl:call-template name="aLink"/>
      <h5 class="section-level-5">
        <xsl:choose>
          <xsl:when test="ancestor::body[@levelstyle='numbered']"/>
	  <xsl:when test="ancestor::body[@levelstyle='outline']">
	       <xsl:number format="i. " level="single" count="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5"/>
	  </xsl:when>
	  <xsl:otherwise>
	       <xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5"/>
	  </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="section-title" mode="show"/>
      </h5>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="section-title"/>
  
  <xsl:template match="section-title" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="itemized-list">
    <div><xsl:apply-templates select="list-title" mode="show"/></div>
    <ul>
      <xsl:call-template name="aClass"/>
      <xsl:call-template name="aList"/>
    </ul>			
  </xsl:template>
  
  <xsl:template match="enumerated-list">
    <div><xsl:apply-templates select="list-title" mode="show"/></div>
    <ol>
      <xsl:call-template name="aClass"/>
      <xsl:call-template name="aList"/>
    </ol>			
  </xsl:template>
  
  <xsl:template match="definition-list">
    <div><xsl:apply-templates select="list-title" mode="show"/></div>
    <dl>
      <xsl:call-template name="aClass"/>
      <xsl:apply-templates/>
    </dl>			
  </xsl:template>
  
  <xsl:template match="definition-data">
    <dd><xsl:apply-templates/></dd>
  </xsl:template>
  
  <xsl:template match="definition-term">
    <dt><xsl:apply-templates/></dt>
  </xsl:template>
  
  <xsl:template match="list-title"/>
  
  <xsl:template match="list-title" mode="show">
    <xsl:call-template name="aClass"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="para">
    <xsl:call-template name="aLink"/>
    <p>

      <xsl:if test="child::hsdb-graphic/attribute::align">
        <xsl:attribute name="style">
          <xsl:text>text-align:</xsl:text><xsl:value-of select="child::hsdb-graphic/attribute::align"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:call-template name="aClass"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="keyword|nugget|index-item|span|summary|topic-sentence|warning|strong|emph|foreign|species|media|data-ref|place-ref|biblio-ref|chapter">
    <span><xsl:call-template name="aClass"/><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="super">
	<sup><xsl:apply-templates/></sup>
  </xsl:template>	

  <xsl:template match="pagebreak">
	<div class="pagebreak"></div>
  </xsl:template>	

  

  <xsl:template match="sub">
	<sub><xsl:apply-templates/></sub>
  </xsl:template>	
  
  <xsl:template match="block-quote|equation">
    <div>
      <xsl:call-template name="aClass"/>
      <xsl:if test="@align">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="linebreak">
	<br/>
  </xsl:template>
  
  <xsl:template match="table">
    <xsl:call-template name="aLink"/>
    <table>
      <xsl:call-template name="aTableAtts"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match="tr">
    <tr>
      <xsl:call-template name="aTableAtts"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="td">
    <td class="data">
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

  <xsl:template match="hsdb-cite-content">
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:value-of select="@content-id"/>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="@node-id"/>
      </xsl:attribute>
      <xsl:apply-templates/>				
    </a>
  </xsl:template>

  <xsl:template match="hsdb-cite-include">
    <div>
      <xsl:call-template name="aClass"/>
      <xsl:variable name="url">
        <xsl:text>http://tusk.tufts.edu/view/hscml?content_id=</xsl:text>
        <xsl:value-of select="@content-id"/>
        <xsl:text>&amp;node_id=</xsl:text>
        <xsl:value-of select="@node-ids"/>
      </xsl:variable>
      <xsl:apply-templates select="document($url)"/>
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:text>/hsdb4/content/</xsl:text>
        <xsl:value-of select="@content-id"/>
      </xsl:attribute>
      <xsl:value-of select="@label"/>
    </a> - <xsl:value-of select="@copyright-holder"/>
    </div>
  </xsl:template>

  <xsl:template match="web-cite">
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:value-of select="@uri"/>
      </xsl:attribute>				
      <xsl:choose>
        <xsl:when test="starts-with(@uri,'http://')"> 
          <xsl:attribute name="target">
            <xsl:text>_blank</xsl:text>
          </xsl:attribute>				
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>				
    </a>
  </xsl:template>
  
  <xsl:template match="hsdb-graphic">
      <xsl:call-template name="aImage"/>
      <xsl:apply-templates/>				
  </xsl:template>

  <xsl:template match="figure|graphic|caption">
    <div>
      <xsl:call-template name="aClass"/>
      <xsl:if test="@align">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>							
    </div>
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
  
  <xsl:template match="web-graphic">
    <div>
      <xsl:call-template name="aClass"/>
      <img>
        <xsl:attribute name="src">
          <xsl:value-of select="@uri"/>
        </xsl:attribute>							
	<xsl:if test="normalize-space(@height) != ''">
		<xsl:attribute name="height">
		  <xsl:value-of select="@height"/>
		</xsl:attribute>							
	</xsl:if>
	<xsl:if test="normalize-space(@width) != ''">
		<xsl:attribute name="width">
		  <xsl:value-of select="@width"/>
		</xsl:attribute>							
	</xsl:if>
        <xsl:attribute name="alt">
          <xsl:value-of select="@description"/>
        </xsl:attribute>							
        <xsl:if test="@align">
          <xsl:attribute name="align">
            <xsl:value-of select="@align"/>
          </xsl:attribute>
        </xsl:if>
      </img>
    </div>
  </xsl:template>

  <xsl:template match="img">
      <img>
        <xsl:attribute name="src">
          <xsl:value-of select="@src"/>
        </xsl:attribute>							
        <xsl:attribute name="height">
          <xsl:value-of select="@height"/>
        </xsl:attribute>							
        <xsl:attribute name="width">
          <xsl:value-of select="@width"/>
        </xsl:attribute>							
        <xsl:attribute name="alt">
          <xsl:value-of select="@alt"/>
        </xsl:attribute>							
      </img>
  </xsl:template>
  
  <xsl:template match="user-ref">
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:text>/view/user/</xsl:text>
        <xsl:value-of select="@user-id"/>
      </xsl:attribute>							
      <xsl:apply-templates/>				
    </a>
  </xsl:template>
  
  
  <xsl:template match="non-user-ref">
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:text>/hsdb4/nonuser/</xsl:text>
        <xsl:value-of select="@non-user-id"/>
      </xsl:attribute>							
      <xsl:apply-templates/>				
    </a>
  </xsl:template>
  
  <xsl:template match="course-ref">
    <a>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="href">
        <xsl:text>/hsdb4/course/</xsl:text>
        <xsl:value-of select="@school"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="@course_id"/>
      </xsl:attribute>							
      <xsl:apply-templates/>
    </a>						
  </xsl:template>
  
  <xsl:template name="aImage">
    <img>
      <xsl:call-template name="aClass"/>
      <xsl:attribute name="src"><xsl:value-of select="$CONTENTID"/>/<xsl:value-of select="@content-id"/>_medium.jpg</xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="@description"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="@description"/>
      </xsl:attribute>
      <xsl:attribute name="border">
        <xsl:text>0</xsl:text>
      </xsl:attribute>
    </img>
  </xsl:template>
  
  <xsl:template name="aLink">
	<xsl:if test="@id">
	    <a name="{@id}"></a>
	</xsl:if>
  </xsl:template>
  
  <xsl:template name="aClass">
    <xsl:attribute name="class">
      <xsl:value-of select="name()"/>
      <xsl:if test="@class">-<xsl:value-of select="@class"/></xsl:if>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template name="aList">
    <xsl:for-each select="list-item">
      <li>
        <xsl:apply-templates/>
      </li>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="aTableAtts">
    <xsl:for-each select="@width|@border|@cellspacing|@cellpadding|@rowspan|@colspan|@align|@valign">
      <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="conversion-note"/>
  <xsl:template match="conversion-exception"/>
  <xsl:template match="message"/>
</xsl:stylesheet>

