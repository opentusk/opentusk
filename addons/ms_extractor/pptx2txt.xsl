<xsl:stylesheet 
	xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" 
	xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" 
	xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

	<xsl:output method="text"/>	
	
	<xsl:template match="a:r">
		<xsl:value-of select="' '"/>
		<xsl:for-each select="a:t">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>


