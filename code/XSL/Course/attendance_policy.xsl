<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:include href="../Common/flow.xsl"/>

    <xsl:template match="course">
        <h3 class="title">Attendance Policy</h3>
        <xsl:apply-templates select="attendance-policy"/>
    </xsl:template>

    <xsl:template match="attendance-policy">
	<xsl:value-of select="." disable-output-escaping ="yes"/>
    </xsl:template>
</xsl:stylesheet>
