<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <h3 class="title">Objectives</h3>
        <xsl:apply-templates select="./learning-objective-list"/>
    </xsl:template>

    <xsl:template match="learning-objective-list">
        <xsl:if test="descendant::objective-ref">
            <ul>
	        <xsl:for-each select="./objective-ref">
	            <li><xsl:value-of select="." disable-output-escaping ="yes"/></li>
    	        </xsl:for-each>
	    </ul>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>
