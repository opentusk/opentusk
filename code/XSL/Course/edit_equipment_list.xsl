<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <xsl:apply-templates select="equipment-list"/>
    </xsl:template>

    <xsl:template match="equipment-list">
	<table width="75%" align="center" class="tusk">
		<tr>
			<td>
			        <ul>
			        <xsl:for-each select="equipment">
				    <li><xsl:value-of select="."/></li>
				</xsl:for-each>
				</ul>
			</td>
		</tr>
	</table>
    </xsl:template>
</xsl:stylesheet>