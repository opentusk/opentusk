<xsl:comment>
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
</xsl:comment>


<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <h3 class="title">Reading List</h3>
        <xsl:apply-templates select="reading-list"/>
    </xsl:template>

    <xsl:template match="reading-list">
	    <table width="100%" cellpadding="5">
	        <tr>
		    <td><b>Item</b></td>
		    <td><b>Type</b></td>
		    <td><b>Required</b></td>
		    <td><b>On Reserve</b></td>
		    <td><b>Call Number</b></td>
		</tr>
	        <xsl:for-each select="reading-item">
		<tr>
		    <td>
		        <xsl:choose>
		            <xsl:when test="@type='URL'">
			        <a href="{@url}"><xsl:value-of select="." disable-output-escaping ="yes"/></a>
			    </xsl:when>
			    <xsl:when test="@type='Medline'">
			        <a href="http://gateway.ovid.com/ovidweb.cgi?T=JS&amp;ID=tfh409&amp;PASSWORD=tufts03&amp;MODE=ovid&amp;PAGE=fulltext&amp;D=ovft&amp;AN={@url}&amp;LOGOUT=y&amp;FIGS=full&amp;NEWS=N"><xsl:value-of select="."/></a>
			    </xsl:when>
			    <xsl:otherwise>
			        <xsl:value-of select="." disable-output-escaping="yes" />
			    </xsl:otherwise>
		        </xsl:choose>
		    </td>
		    <td><xsl:value-of select="@type"/></td>
		    <td><xsl:value-of select="@required"/></td>
		    <td><xsl:value-of select="@on-reserve"/></td>
		    <td><xsl:value-of select="@call-number"/></td>
		</tr>		
		</xsl:for-each>
	    </table>
    </xsl:template>

</xsl:stylesheet>
