<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="html" omit-xml-declaration="yes"/>

  <xsl:include href="structure.xsl"/>

<xsl:template match="header"/>

<xsl:template match="content">
  <html>
    <head>
      <title><xsl:value-of select="header/title"/></title>
      <link ref="stylesheet" href="http://tusk.tufts.edu/HSCML/Display/hscmlhtml.css" type="text/css" />
    </head>
    <xsl:apply-templates />
  </html>
</xsl:template>

<xsl:template match="body">
  <body>
    <ul>
      <xsl:for-each select="descendant::section-level-1/section-title">
        <li><a href="#{../@id}"><xsl:value-of select="."/></a></li>
      </xsl:for-each>
    </ul>
    <xsl:apply-templates/>
    <div><b>Course:</b><a href="/hsdb4/course/{//header/course-ref/@course-id}"><xsl:value-of select="//header/course-ref"/></a></div>
    <div class="copyright"><xsl:value-of select="//header/copyright/copyright-text"/></div>
    <ul>
      <xsl:for-each select="//header/contact-person">
        <li><xsl:element name="a">
	  <xsl:attribute name="href"><xsl:text>/view/user/</xsl:text><xsl:value-of select="."/></xsl:attribute>
          <xsl:value-of select="@friendly-name" />
          </xsl:element>
        </li>
      </xsl:for-each>
    </ul>
  </body>
</xsl:template>

</xsl:stylesheet>
