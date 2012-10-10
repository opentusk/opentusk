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
        <h3 class="title">Grading Policy</h3>
        <xsl:apply-templates select="./grading-policy"/>
    </xsl:template>

    <xsl:template match="grading-policy">
        <xsl:if test="descendant::grading-item">
            <table cellpadding="8">
	        <tr>
	            <td><h4 class="title">Item</h4></td>
		    <td><h4 class="title">Weight</h4></td>
	        </tr>
	        <xsl:for-each select="grading-item">
	            <tr>
		        <td><xsl:value-of select="." disable-output-escaping ="yes"/></td>
		        <td><xsl:value-of select="@weight"/></td>
		    </tr>
	        </xsl:for-each>
	    </table>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>
