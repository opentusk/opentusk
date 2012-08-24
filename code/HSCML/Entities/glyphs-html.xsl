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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="html"/>

  <!-- Take the whole thing, and wrap it in HTML and a table. -->
  <xsl:template match="/">
    <html>
      <body bgcolor="#FFFFFF">
        <table width="80%" border="1" cellspacing="0">
          <tr>
            <th>Name</th>
            <th>Code</th>
            <th>Named<br/>Entity</th>
            <th>Numbered<br/>Entity</th>
            <th>PNG<br/>Glyph</th>
            <th>HTML</th>
          </tr>
          <xsl:apply-templates/>
        </table>
      </body>
    </html>
  </xsl:template>

  <!-- This takes a glyph element and makes it a row in the table. -->
  <xsl:template match="glyph">
    <tr align="center">
      <td><xsl:value-of select="./name"/></td>
      <td>U+<xsl:value-of select="@code"/></td>
      <td><xsl:text disable-output-escaping="yes">&#38;</xsl:text><xsl:value-of select="./name"/>;</td>
      <td><xsl:text disable-output-escaping="yes">&#38;#x</xsl:text><xsl:value-of select="@code"/>;</td>
      <td><xsl:apply-templates select="./glyph-image"/></td>
      <td><xsl:apply-templates select="./glyph-image" mode="code"/></td>
    </tr>
  </xsl:template>

  <!-- This turns a glyph-image into an actual img element. -->
  <xsl:template match="glyph-image">
    <xsl:element name="img">
      <xsl:attribute name="src">http://hsdb.hsl.tufts.edu/<xsl:value-of select="@src"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
      <xsl:attribute name="alt"><xsl:value-of select="../name"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <!-- This turns a glyph-image into some pre-formatted HTML code that one
       could include in HTML that refers to the image in question. -->
  <xsl:template match="glyph-image" mode="code">
    <pre>&lt;img src="<xsl:value-of select="@src"/>" width="<xsl:value-of select="@width"/>" height="<xsl:value-of select="@height"/>" alt="<xsl:value-of select="../name"/>"/&gt;</pre>
  </xsl:template>

</xsl:stylesheet>
