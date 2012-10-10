<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:include href="../Common/flow.xsl"/>

    <xsl:template match="course">
        <xsl:apply-templates select="student-evaluation"/>
    </xsl:template>

    <xsl:template match="student-evaluation">
	<xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
