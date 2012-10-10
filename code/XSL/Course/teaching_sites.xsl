<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <h3 class="title">Teaching Sites</h3>
        <xsl:apply-templates select="./teaching-site-list"/>
    </xsl:template>

    <xsl:template match="teaching-site-list">
        <xsl:if test="descendant::teaching-site">
	    <table cellpadding="8">
	        <tr>
	            <td><h4 class="title">Name</h4></td>
		    <td><h4 class="title">Location</h4></td>
	        </tr>
	        <xsl:for-each select="./teaching-site">
	            <tr>
		        <td>
			    <xsl:value-of select="./site-name"/>
		        </td>
			<td>
			    <xsl:value-of select="./site-location"/>
			</td>
		    </tr>
    	        </xsl:for-each>
	    </table>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>
