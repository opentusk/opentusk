<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:include href="../Common/flow.xsl"/>

    <xsl:template match="course">
	<xsl:value-of select="course-other" disable-output-escaping ="yes"/>
    </xsl:template>
</xsl:stylesheet>
