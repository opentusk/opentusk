<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="html" encoding="iso-8859-1"/>

  <xsl:template match="/">
    <html>
      <body bgcolor="#FFFFFF">
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="text">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="emph"><em><xsl:apply-templates/></em></xsl:template>
  <xsl:template match="strong"><b><xsl:apply-templates/></b></xsl:template>
  <xsl:template match="break"><br/></xsl:template>

</xsl:stylesheet>
