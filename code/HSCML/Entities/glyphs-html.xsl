<?xml version="1.0" encoding="utf-8"?>
<!-- Stylesheet for making an HTML reference table out of our character
     lists.

     Run like:
       xsltproc glyphs-html.xsl glyphs.xml > glyphs.html
     
     Tarik Alkasab <tarik.alkasab@neurosci.tufts.edu>
     $Revision: 1.1 $
     $Date: 2001-08-25 04:01:53 $
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
