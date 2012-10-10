<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:include href="../Common/flow.xsl"/>

    <xsl:template match="course">
        <xsl:apply-templates select="./tutoring-services"/>
    </xsl:template>

    <xsl:template match="tutoring-services">
        <xsl:if test=".!=''">
            <xsl:apply-templates/>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>