<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output mode="xml" />

<xsl:template match="text()" />

<xsl:template match="hsdb-graphic">	
	<CONTENTID>
		<xsl:attribute name="image-class">
			<xsl:value-of select="@image-class"/>
		</xsl:attribute>
		<xsl:value-of select="@content-id" />
	</CONTENTID>
</xsl:template>

<xsl:template match="/">
<CONTENTLIST><xsl:apply-templates /></CONTENTLIST>
</xsl:template>

</xsl:stylesheet>
