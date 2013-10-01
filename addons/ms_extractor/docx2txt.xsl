<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
	
  <xsl:output method="text" />
  
  <xsl:template match="/">
    <xsl:apply-templates select="//w:body" />
  </xsl:template>

  <xsl:template match="w:body">
	<xsl:apply-templates />
  </xsl:template>

  <xsl:template match="w:p">
	<xsl:value-of select="' '"/>
	<xsl:apply-templates select="w:r" />
  </xsl:template>

  <xsl:template match="w:r">	
	<xsl:for-each select="w:t">
		<xsl:value-of select="." />
	</xsl:for-each>
  </xsl:template>

</xsl:stylesheet>