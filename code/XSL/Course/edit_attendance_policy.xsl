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
<xsl:output method="text"/>
    <xsl:include href="../Common/flow.xsl"/>
    <xsl:template match="course">
        <xsl:apply-templates select="attendance-policy"/>
    </xsl:template>
    <xsl:template match="attendance-policy">
        <xsl:if test=".!=''">
            <xsl:apply-templates/>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>