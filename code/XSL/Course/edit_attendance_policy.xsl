<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
<xsl:output method="text"/>
    <xsl:include href="../Common/flow.xsl"/>
    <xsl:template match="course">
        <xsl:apply-templates select="attendance-policy"/>
    </xsl:template>
    <xsl:template match="attendance-policy">
        <xsl:if test=".!=''">
            <xsl:apply-templates/>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>