<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <xsl:apply-templates select="./grading-policy"/>
    </xsl:template>

    <xsl:template match="grading-policy">
        <xsl:if test="descendant::grading-item">
            <table width="75%" align="center" class="tusk" cellspacing="0">
	        <tr class="header">
	            <td class="header-left">Item</td>
		    <td class="header-center">Percentage</td>
	        </tr>
	        <xsl:for-each select="grading-item">
			<xsl:variable name="row">
				<xsl:choose>
					<xsl:when test="position() mod 2  = 1">
						<xsl:text>even</xsl:text>
					</xsl:when>
					<xsl:when test="position() mod 2 = 0">
						<xsl:text>odd</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<tr class="{$row}">
		        <td class="layers-left"><xsl:value-of select="."/></td>
		        <td class="layers-center"><xsl:value-of select="@weight"/></td>
		    </tr>
	        </xsl:for-each>
	    </table>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>
