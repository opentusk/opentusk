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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:template match="umls-concept">
    <a class="umls-concept" href="/hsdb4/concept/{@concept-id}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="hsdb-cite-content">
    <a class="hsdb-cite-content" href="/hsdb4/content/{@content-id}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="hsdb-graphic">
    <div class="hsdb-graphic">
      <xsl:element name="a">
        <xsl:choose>
          <xsl:when test="@link=popup">
            <xsl:attribute name="href">javascript:window.open('/hsdb4/content/<xsl:value-of select="@content-id"/>')</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="href">/hsdb4/content/<xsl:value-of select="@content-id"/></xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:element name="img">
          <xsl:attribute name="src">
            <xsl:choose>
              <xsl:when test="@image-class=full">/data/<xsl:value-of select="@content-id"/></xsl:when>
              <xsl:when test="@image-class=half">/small_data/<xsl:value-of select="@content-id"/></xsl:when>
              <xsl:otherwise>/thumbnail/<xsl:value-of select="@content-id"/></xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
          <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
          <xsl:attribute name="alt"><xsl:value-of select="@description"/></xsl:attribute>
        </xsl:element>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="hsdb-graphc[@link=none]">
    <div class="hsdb-graphic">
      <xsl:element name="img">
        <xsl:attribute name="src">
          <xsl:choose>
            <xsl:when test="@image-class=full">/data/<xsl:value-of select="@content-id"/></xsl:when>
            <xsl:when test="@image-class=half">/small_data/<xsl:value-of select="@content-id"/></xsl:when>
            <xsl:otherwise>/thumbnail/<xsl:value-of select="@content-id"/></xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
        <xsl:attribute name="alt"><xsl:value-of select="@description"/></xsl:attribute>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template match="web-cite">
     <a class="web-cite-content" href="{@uri}">
       <xsl:apply-templates/>
     </a>
   </xsl:template>

   <xsl:template match="index-item">
     <span class="index-item"><xsl:apply-templates/></span>
   </xsl:template>

   <xsl:template match="objective-item">
     <a class="objective-item" href="/hsdb4/objective/{@objective-id}">
       <xsl:apply-templates/>
     </a>
   </xsl:template>

   <xsl:template match="web-graphic">
     <div class="web-graphic">
       <img src="{@uri}" width="{@width}" height="{@height} " 
         alt="{@description}" />
     </div>
   </xsl:template>

   <xsl:template match="user-ref">
     <a class="user-ref" href="/view/user/{@user-id}">
       <xsl:apply-templates/>
     </a>
   </xsl:template>

   <xsl:template match="non-user-ref">
     <a class="non-user-ref" href="/view/user/{@non-user-id}">
       <xsl:apply-templates/>
     </a>
   </xsl:template>

   <xsl:template match="span">
     <span style="@{style}"><xsl:apply-templates /></span>
   </xsl:template>

   <xsl:template match="strong">
     <b class="strong"><xsl:apply-templates /></b>
   </xsl:template>

   <xsl:template match="emph|foreign|species|media">
     <i class="{name()}"><xsl:apply-templates /></i>
   </xsl:template>

   <xsl:template match="super">
     <sup class="super"><xsl:apply-templates /></sup>
   </xsl:template>

   <xsl:template match="sub">
     <sub class="sub"><xsl:apply-templates /></sub>
   </xsl:template>

   <xsl:template match="keyword|summary|topic-sentence">
     <span class="{name()}"><xsl:apply-templates /></span>
   </xsl:template>

   <xsl:template match="place-ref|date-ref|biblio-ref">
     <xsl:apply-templates />
   </xsl:template>
</xsl:stylesheet>
