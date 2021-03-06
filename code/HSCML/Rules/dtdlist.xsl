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

  <xsl:template match="/">
    <html>
      <head>
        <title>HSDB DTD Catalog</title>
        <link rel="stylesheet" type="text/css" href="/style/hsdb4.css"/>
      </head>
      <body bgcolor="#FFFFFF">
        <h1 class="title">HSDB DTD Catalog</h1>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Dtd">
    <h3 class="title"><a name="{@filename}" href="{@filename}"><xsl:value-of select="@filename"/></a></h3>
    <p><xsl:value-of select="Text"/></p>
    <xsl:if test="doctype">
      <h4 class="title">Doctypes</h4>
      <div style="font-size: 85%;"><xsl:apply-templates select="doctype"/></div>
    </xsl:if>
    <xsl:if test="depends">
      <p class="footer"><b>Depends on: </b><xsl:apply-templates select="depends"/></p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="doctype">
    <pre>&lt;!DOCTYPE <xsl:value-of select="."/> PUBLIC "-//<xsl:value-of select="../Descriptor/@organization"/>//<xsl:value-of select="../Descriptor"/>//<xsl:value-of select="../Descriptor/@language"/>" "http://www.hsdb.tufts.edu/DTD/<xsl:value-of select="../@filename"/>"&gt;</pre>
  </xsl:template>

  <xsl:template match="depends">
    <a href="#{@filename}"><xsl:value-of select="@filename"/></a>
    <xsl:if test="@dependency='prereq'">
      <xsl:text> (pre)</xsl:text>
    </xsl:if>
    <xsl:text>, </xsl:text>
  </xsl:template>

</xsl:stylesheet>
