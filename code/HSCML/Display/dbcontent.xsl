<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="html" omit-xml-declaration="yes"/>

  <xsl:include href="structure.xsl"/>

  <xsl:template match="brief-header"/>
  <xsl:template match="associated-data"/>
  <xsl:template match="body">
    <html><body>
    <ul>
      <xsl:for-each select="descendant::section-level-1/section-title">
        <li><a href="#{../@id}"><xsl:value-of select="."/></a></li>
      </xsl:for-each>
    </ul>
    <xsl:apply-templates/>
  </body></html>
</xsl:template>
</xsl:stylesheet>
    