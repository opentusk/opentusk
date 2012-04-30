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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="html" omit-xml-declaration="yes"/>

  <xsl:include href="inline.xsl"/>

  <xsl:template match="para">
    <p class="para"><a name="{@id}"/><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="itemized-list">
    <ul class="itemized-list"><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="enumerated-list">
    <ol class="enumerated-list"><xsl:apply-templates/></ol>
  </xsl:template>

  <xsl:template match="list-item">
    <li class="list-item"><xsl:apply-templates/></li>
  </xsl:template>

  <xsl:template match="definition-list">
    <dl class="definition-list"><xsl:apply-templates/></dl>
  </xsl:template>

  <xsl:template match="defintion-term">
    <dt class="definition-term"><xsl:apply-templates/></dt>
  </xsl:template>

  <xsl:template match="definition-data">
    <dd class="definition-data"><xsl:apply-templates/></dd>
  </xsl:template>

  <xsl:template match="table|tr|td|th">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5|section-level-6">
    <a name="{@id}"></a>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="section-level-1/section-title[1]">
    <h2 class="section-level-1"><xsl:apply-templates/></h2>
  </xsl:template>

  <xsl:template match="section-level-2/section-title[2]">
    <h3 class="section-level-2"><xsl:apply-templates/></h3>
  </xsl:template>

  <xsl:template match="section-title"/>

  <xsl:template match="equation">
    <div class="equation"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="img">
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>