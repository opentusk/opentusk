<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <h3 class="title">Equipment List</h3>
        <xsl:apply-templates select="equipment-list"/>
    </xsl:template>

    <xsl:template match="equipment-list">
        <ul>
        <xsl:for-each select="equipment">
	    <li><xsl:value-of select="." disable-output-escaping ="yes"/></li>
	</xsl:for-each>
	</ul>
    </xsl:template>
</xsl:stylesheet>
