<?xml version="1.0" encoding="utf-8"?>
<!--
 Copyright 2012 Tufts University

 Licensed under the Educational Community License, Version 1.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.opensource.org/licenses/ecl1.php

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
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
