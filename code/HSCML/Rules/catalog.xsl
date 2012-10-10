<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="text"/>
  <xsl:strip-space elements="DtdList Dtd"/>
  <xsl:template match="/"><xsl:apply-templates match="Dtd"/></xsl:template>
  <xsl:template match="Dtd">PUBLIC "-//<xsl:value-of select="Descriptor/@organization"/>//<xsl:value-of select="Descriptor"/>//<xsl:value-of select="Descriptor/@language"/>" "<xsl:value-of select="@filename"/>"
</xsl:template>
</xsl:stylesheet>