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


<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:include href="inline.xsl"/>

   <xsl:template match="para">
     <p class="para"><xsl:apply-templates /></p>
   </xsl:template>

   <xsl:template match="img">
     <xsl:element name="img">
	<xsl:attribute name="src"><xsl:value-of select="@src"/></xsl:attribute>
     </xsl:element>
     <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="table|tr|th|td">
     <xsl:element name="{name()}">
       <xsl:call-template name="aTableAtts"/>
       <xsl:apply-templates/>
     </xsl:element>
   </xsl:template>

   <xsl:template match="enumerated-list">
     <ol><xsl:apply-templates /></ol>
   </xsl:template>

   <xsl:template match="itemized-list">
     <ul><xsl:apply-templates /></ul>
   </xsl:template>

   <xsl:template match="list-item">
     <li><xsl:apply-templates /></li>
   </xsl:template>

   <xsl:template name="aTableAtts">
     <xsl:for-each select="@width|@border|@cellspacing|@cellpadding|@rowspan|@colspan|@align|@valign">
       <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
     </xsl:for-each>
   </xsl:template>

   <xsl:template match="pagebreak">
     <hr />
   </xsl:template>

</xsl:stylesheet>
