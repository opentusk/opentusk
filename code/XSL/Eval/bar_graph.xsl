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

  <xsl:param name="WIDTH">340</xsl:param>
  <xsl:param name="BARHEIGHT">13</xsl:param>
  <xsl:param name="FONTHEIGHT">11</xsl:param>
  <xsl:param name="SVGURL">/evalgraph</xsl:param>
  <xsl:param name="TEXTWIDTH">210</xsl:param>
  <xsl:param name="STATWIDTH">150</xsl:param>
  <xsl:param name="MEANX">33</xsl:param>
  <xsl:param name="SDX">66</xsl:param>
  <xsl:param name="NX">88</xsl:param>
  <xsl:param name="NAX">110</xsl:param>
  <xsl:param name="MERGED_ID">0</xsl:param>
  <xsl:param name="NUMHEIGHT">10</xsl:param>
  <xsl:param name="NUMFONTHEIGHT">7</xsl:param>

  <xsl:template name="axislines">
    <xsl:param name="count">1</xsl:param>
    <xsl:param name="num_steps">5</xsl:param>
    <xsl:param name="height">0.1</xsl:param>
    <xsl:if test="$count &lt; $num_steps - 1">
      <path d="M {$count} 0 v {$height}"/>
      <xsl:call-template name="axislines">
        <xsl:with-param name="count" select="$count + 1"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="height" select="$height"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="svgembed">
    <xsl:param name="question_id">null</xsl:param>
    <xsl:param name="school">
      <xsl:value-of select="/Eval_Results/eval_header/@school"/>
    </xsl:param>
    <xsl:param name="eval_id">
      <xsl:value-of select="/Eval_Results/eval_header/@eval_id"/>
    </xsl:param>
    <xsl:variable name="parent_id">
      <xsl:choose>
        <xsl:when test="$MERGED_ID = '0'"><xsl:value-of select="$eval_id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$MERGED_ID"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="singlebargraph">
		<b>Mean:</b>

		<span id="eval_question_{$question_id}" class="graphSpan">Loading graph...</span>

	</div>
    </xsl:template>
    
  <xsl:template name="groupsvgembed">
    <xsl:param name="question_id">null</xsl:param>
    <xsl:param name="num_questions"/>
    <xsl:param name="school" select="/Eval_Results/eval_header/@school"/>
    <xsl:param name="eval_id" select="/Eval_Results/eval_header/@eval_id"/>
    <xsl:variable name="width" select="$WIDTH + $TEXTWIDTH + $STATWIDTH"/>
    <xsl:variable name="height" select="$FONTHEIGHT + 2 + $NUMHEIGHT + $num_questions * ($BARHEIGHT + 2)"/>
    <xsl:variable name="parent_id">
      <xsl:choose>
        <xsl:when test="$MERGED_ID = '0'"><xsl:value-of select="$eval_id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$MERGED_ID"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="singlebargraph">
		<b>Mean:</b>
		<span id="eval_question_{$question_id}" class="graphSpan">Loading graph...</span>
	</div>
    </xsl:template>

  <xsl:template name="catsvgembed">
    <xsl:param name="question_id">null</xsl:param>
    <xsl:param name="num_cats"/>
    <xsl:param name="school" select="/Eval_Results/eval_header/@school"/>
    <xsl:param name="eval_id" select="/Eval_Results/eval_header/@eval_id"/>
    <xsl:variable name="width" select="$WIDTH + $TEXTWIDTH + $STATWIDTH"/>
    <xsl:variable name="height" select="$FONTHEIGHT + 2 + $NUMHEIGHT + $num_cats * ($BARHEIGHT + 2)"/>
    <xsl:variable name="parent_id">
      <xsl:choose>
        <xsl:when test="$MERGED_ID = '0'"><xsl:value-of select="$eval_id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$MERGED_ID"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="singlebargraph">
		<b>Mean:</b>
		<span id="eval_question_{$question_id}" class="graphSpan">Loading graph...</span>
	</div>
    </xsl:template>

  <xsl:template name="hbargraphgroup">
    <xsl:param name="questionXml"/>
    <xsl:param name="num_steps">5</xsl:param>
    <xsl:param name="value">2</xsl:param>
    <xsl:param name="title">Bar Graph</xsl:param>
    <xsl:param name="question_id">null</xsl:param>
    <xsl:param name="offset">0</xsl:param>
    <xsl:param name="num_questions"/>
    <xsl:param name="barcolor">#66f</xsl:param>
    <xsl:variable name="headResult" select="."/>
    <xsl:variable name="height" select="$FONTHEIGHT + $NUMHEIGHT + 2 + $num_questions * ($BARHEIGHT + 2)"/>
    <svg xmlns:xlink="http://www.w3.org/1999/xlink" width="{$WIDTH + $TEXTWIDTH + $STATWIDTH}" height="{$height}">
      <defs>
        <xsl:variable name="height" select="$num_questions * 0.14"/>
        <symbol id="graphbox" viewBox="0 0 {$num_steps - 1} {$height}" preserveAspectRatio="none">
          <g style="stroke: black; stroke-width: 0.005; fill: none">
            <rect width="{$num_steps - 1}" height="{$height}" x="0" y="0" style="stroke-width: 0.01"/>
            <xsl:call-template name="axislines">
              <xsl:with-param name="num_steps" select="$num_steps"/>
              <xsl:with-param name="height" select="$height"/>
            </xsl:call-template>
            <path d="M {$offset} 0.02 v .1 h {$value - $offset} v -.1 z" style="fill: {$barcolor}; fill-opacity: 0.7"/>
            <xsl:for-each select="$questionXml/following-sibling::EvalQuestionRef">
              <xsl:variable name="thisQuestionId" select="@eval_question_id"/>
              <xsl:variable name="thisValue" select="$headResult/following-sibling::Question_Results[@eval_question_id=$thisQuestionId]/ResponseGroup[1]/ResponseStatistics/mean"/>
              <path d="M {$offset} {0.02 + position() * 0.14} v .1 h {$thisValue - $offset - 1} v -.1 z" style="fill: {$barcolor}; fill-opacity: 0.7"/>
              <xsl:if test="$offset &gt; 0 and ($offset - $value) &lt; 0.07 and ($offset - $value) &gt; -0.07">
                <path d="M {$offset} {0.02 + position() * 0.14} l 0.07 0.05 l -0.07 0.05 l -0.07 -0.05 z" style="fill: black; fill-opacity: 0.3;"/>
              </xsl:if>
            </xsl:for-each>
          </g>
        </symbol>
      </defs>
      <title><xsl:value-of select="$title"/></title>
      <desc>School: <xsl:value-of select="/Eval_Results/@school"/>, 
      Eval: <xsl:value-of select="/Eval_Results/@eval_id"/>, 
      EvalQuestion: <xsl:value-of select="$question_id"/></desc>
      <use xlink:href="#graphbox" x="{$TEXTWIDTH}" y="{$FONTHEIGHT + 2}" width="{$WIDTH}" height="{$num_questions * ($BARHEIGHT + 2)}"/>
      <g style="font-size:{$FONTHEIGHT} ; font-family:sans-serif">
        <text x="{$TEXTWIDTH}" y="{$FONTHEIGHT + 1}" style="text-anchor: start">
          <xsl:value-of select="$questionXml//low_text"/>
        </text>
        <text x="{$TEXTWIDTH + ($WIDTH div 2)}" y="{$FONTHEIGHT + 1}" style="text-anchor:middle">
          <xsl:value-of select="$questionXml//mid_text"/>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">
          <xsl:value-of select="$questionXml//high_text"/>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH + $MEANX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">Mean</text>
        <text x="{$TEXTWIDTH + $WIDTH + $SDX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">SD</text>
        <text x="{$TEXTWIDTH + $WIDTH + $NX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">N</text>
        <text x="{$TEXTWIDTH + $WIDTH + $NAX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">NA</text>
        <text x="{$TEXTWIDTH - 5}" y="{$FONTHEIGHT + 2 + $BARHEIGHT}" style="text-anchor: end">
          <xsl:value-of select="$questionXml//question_text"/>
        </text>
        <text x="1" y="{$FONTHEIGHT + 2 + $BARHEIGHT}" style="text-anchor: start">
          <xsl:value-of select="$questionXml/question_label"/><xsl:text>. </xsl:text>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH + $MEANX}" y="{$FONTHEIGHT + 2 + $BARHEIGHT}" style="text-anchor: end">
          <xsl:variable name="mean" select="ResponseGroup[1]/ResponseStatistics/mean"/>
          <xsl:choose>
            <xsl:when test="$mean"><xsl:value-of select="$mean"/></xsl:when>
            <xsl:otherwise>--</xsl:otherwise>
          </xsl:choose>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH + $SDX}" y="{$FONTHEIGHT + 2 + $BARHEIGHT}" style="text-anchor: end">
          <xsl:variable name="sd" select="ResponseGroup[1]/ResponseStatistics/standard_deviation"/>
          <xsl:choose>
            <xsl:when test="$sd"><xsl:value-of select="$sd"/></xsl:when>
            <xsl:otherwise>--</xsl:otherwise>
          </xsl:choose>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH + $NX}" y="{$FONTHEIGHT + 2 + $BARHEIGHT}" style="text-anchor: end">
          <xsl:value-of select="ResponseGroup[1]/ResponseStatistics/response_count"/>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH + $NAX}" y="{$FONTHEIGHT + 2 + $BARHEIGHT}" style="text-anchor: end">
          <xsl:value-of select="ResponseGroup[1]/ResponseStatistics/na_response_count"/>
        </text>
        <xsl:for-each select="$questionXml/following-sibling::EvalQuestionRef">
          <xsl:variable name="thisQuestionId" select="@eval_question_id"/>
          <xsl:variable name="thisStats" select="$headResult/following-sibling::Question_Results[@eval_question_id=$thisQuestionId]/ResponseGroup[1]/ResponseStatistics"/>
          <xsl:variable name="thisN" select="$thisStats/response_count"/>
          <xsl:variable name="thisMean" select="$thisStats/mean"/>
          <xsl:variable name="thisNA" select="$thisStats/na_response_count"/>
          <xsl:variable name="thisSD" select="$thisStats/standard_deviation"/>
          <xsl:variable name="thisText" select="QuestionRef/question_text"/>
          <xsl:variable name="thisLabel" select="question_label"/>
          <text x="1" y="{$FONTHEIGHT + ($BARHEIGHT + 2) * (position() + 1)}" style="text-anchor: start">
            <xsl:value-of select="$thisLabel"/><xsl:text>. </xsl:text>
          </text>
          <text x="{$TEXTWIDTH - 5}" y="{$FONTHEIGHT + ($BARHEIGHT + 2) * (position() + 1)}" style="text-anchor: end">
            <xsl:value-of select="$thisText"/>
          </text>
          <text x="{$TEXTWIDTH + $WIDTH + $MEANX}" y="{$FONTHEIGHT + ($BARHEIGHT + 2) * (position() + 1)}" style="text-anchor: end">
            <xsl:choose>
              <xsl:when test="$thisMean"><xsl:value-of select="$thisMean"/></xsl:when>
              <xsl:otherwise>--</xsl:otherwise>
            </xsl:choose>
          </text>
          <text x="{$TEXTWIDTH + $WIDTH + $SDX}" y="{$FONTHEIGHT + ($BARHEIGHT + 2) * (position() + 1)}" style="text-anchor: end">
            <xsl:choose>
              <xsl:when test="$thisSD"><xsl:value-of select="$thisSD"/></xsl:when>
              <xsl:otherwise>--</xsl:otherwise>
            </xsl:choose>
          </text>
          <text x="{$TEXTWIDTH + $WIDTH + $NX}" y="{$FONTHEIGHT + ($BARHEIGHT + 2) * (position() + 1)}" style="text-anchor: end">
            <xsl:value-of select="$thisN"/>
          </text>
          <text x="{$TEXTWIDTH + $WIDTH + $NAX}" y="{$FONTHEIGHT + ($BARHEIGHT + 2) * (position() + 1)}" style="text-anchor: end">
            <xsl:value-of select="$thisNA"/>
          </text>
        </xsl:for-each>
      </g>
      <xsl:call-template name="numbers">
        <xsl:with-param name="yvalue" select="$height - 1"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="xoffset" select="$TEXTWIDTH"/>
      </xsl:call-template>
    </svg>
  </xsl:template>

  <xsl:template name="drawBarCat">
    <xsl:param name="respGroup"/>
    <xsl:param name="offset">0</xsl:param>
    <xsl:param name="yvalue">0.02</xsl:param>
    <xsl:param name="addToValue"/>
    <xsl:variable name="value" select="$respGroup/ResponseStatistics/mean - 1"/>
    <xsl:variable name="barcolor">
      <xsl:choose>
        <xsl:when test="$offset = 0">#66f</xsl:when>
        <xsl:when test="$value &gt; $offset">#6f6</xsl:when>
        <xsl:when test="$value &lt; $offset">#f66</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:comment>Offset: <xsl:value-of select="$offset"/>; Value: <xsl:value-of select="$value"/></xsl:comment>
    <path d="M {$offset} {$yvalue} v .1 h {$value - $offset} v -.1 z" style="fill: {$barcolor}; fill-opacity: 0.7"/>
    <xsl:if test="$offset &gt; 0 and ($offset - $value) &lt; 0.07 and ($offset - $value) &gt; -0.07">
      <path d="M {$value} {$yvalue} l 0.07 0.05 l -0.07 0.05 l -0.07 -0.05 z" 
        style="fill: black; fill-opacity: 0.3"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="drawTextCat">
    <xsl:param name="respGroup"/>
    <xsl:param name="yvalue" select="$FONTHEIGHT + 2 + $BARHEIGHT"/>
    <xsl:variable name="groupLabel">
      <xsl:choose>
        <xsl:when test="$respGroup/grouping_value"><xsl:value-of select="$respGroup/grouping_value"/></xsl:when>
        <xsl:otherwise>ALL</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <text x="{$TEXTWIDTH - 5}" y="{$yvalue}" style="text-anchor: end">
      <xsl:value-of select="$groupLabel"/>
    </text>
    <text x="{$TEXTWIDTH + $WIDTH + $MEANX}" y="{$yvalue}" style="text-anchor: end">
      <xsl:variable name="mean" select="$respGroup/ResponseStatistics/mean"/>
      <xsl:choose>
        <xsl:when test="$mean"><xsl:value-of select="$mean"/></xsl:when>
        <xsl:otherwise>--</xsl:otherwise>
      </xsl:choose>
    </text>
    <text x="{$TEXTWIDTH + $WIDTH + $SDX}" y="{$yvalue}" style="text-anchor: end">
      <xsl:variable name="sd" select="$respGroup/ResponseStatistics/standard_deviation"/>
      <xsl:choose>
        <xsl:when test="$sd"><xsl:value-of select="$sd"/></xsl:when>
        <xsl:otherwise>--</xsl:otherwise>
      </xsl:choose>
    </text>
    <text x="{$TEXTWIDTH + $WIDTH + $NX}" y="{$yvalue}" style="text-anchor: end">
      <xsl:value-of select="$respGroup/ResponseStatistics/response_count"/>
    </text>
    <text x="{$TEXTWIDTH + $WIDTH + $NAX}" y="{$yvalue}" style="text-anchor: end">
      <xsl:value-of select="$respGroup/ResponseStatistics/na_response_count"/>
    </text>
  </xsl:template>

  <xsl:template name="hbargraphcat">
    <xsl:param name="questionXml"/>
    <xsl:param name="num_steps">5</xsl:param>
    <xsl:param name="title">Bar Graph</xsl:param>
    <xsl:param name="question_id">null</xsl:param>
    <xsl:param name="offset">0</xsl:param>
    <xsl:param name="num_cats"/>
    <xsl:variable name="height" select="$num_cats * 0.14" />
    <svg xmlns:xlink="http://www.w3.org/1999/xlink" width="{$WIDTH + $TEXTWIDTH + $STATWIDTH}" height="{$height}">
      <defs>
        <symbol id="graphbox" viewBox="0 0 {$num_steps - 1} {$height}" preserveAspectRatio="none">
          <g style="stroke: black; stroke-width: 0.005; fill: none">
            <rect width="{$num_steps - 1}" height="{$height}" x="0" y="0" style="stroke-width: 0.01"/>
            <!-- Now, draw axis lines -->
            <xsl:call-template name="axislines">
              <xsl:with-param name="num_steps" select="$num_steps"/>
              <xsl:with-param name="height" select="$height"/>
            </xsl:call-template>
            <!-- Now, draw the top-level bar -->
            <xsl:if test="$num_cats &gt; 1">
              <xsl:call-template name="drawBarCat">
                <xsl:with-param name="respGroup" select="ResponseGroup[1]"/>
                <xsl:with-param name="offset" select="$offset"/>
                <xsl:with-param name="yvalue" select="0.02 + ($num_cats - 1) * 0.14"/>
              </xsl:call-template>
            </xsl:if>
            <!-- Now, draw the rest of them -->
            <xsl:for-each select="Categorization/ResponseGroup">
              <xsl:call-template name="drawBarCat">
                <xsl:with-param name="respGroup" select="."/>
                <xsl:with-param name="offset" select="$offset"/>
                <xsl:with-param name="yvalue" select="0.02 + (position() - 1) * 0.14"/>
              </xsl:call-template>
            </xsl:for-each>
          </g>
        </symbol>
      </defs>
      <title><xsl:value-of select="$title"/></title>
      <desc>School: <xsl:value-of select="/Eval_Results/@school"/>, 
      Eval: <xsl:value-of select="/Eval_Results/@eval_id"/>, 
      EvalQuestion: <xsl:value-of select="$question_id"/></desc>
      <use xlink:href="#graphbox" x="{$TEXTWIDTH}" y="{$FONTHEIGHT + 2}" width="{$WIDTH}" height="{$num_cats * ($BARHEIGHT + 2)}"/>
      <g style="font-size:{$FONTHEIGHT} ; font-family:sans-serif">
        <!-- These draw the text labels -->
        <text x="{$TEXTWIDTH}" y="{$FONTHEIGHT + 1}" style="text-anchor: start">
          <xsl:value-of select="$questionXml//low_text"/>
        </text>
        <text x="{$TEXTWIDTH + ($WIDTH div 2)}" y="{$FONTHEIGHT + 1}" style="text-anchor:middle">
          <xsl:value-of select="$questionXml//mid_text"/>
        </text>
        <text x="{$TEXTWIDTH + $WIDTH}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">
          <xsl:value-of select="$questionXml//high_text"/>
        </text>

        <text x="{$TEXTWIDTH + $WIDTH + $MEANX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">Mean</text>
        <text x="{$TEXTWIDTH + $WIDTH + $SDX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">SD</text>
        <text x="{$TEXTWIDTH + $WIDTH + $NX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">N</text>
        <text x="{$TEXTWIDTH + $WIDTH + $NAX}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">NA</text>

        <!-- Now, draw the question text bits -->
        <xsl:if test="$num_cats &gt; 1">
          <xsl:call-template name="drawTextCat">
            <xsl:with-param name="respGroup" select="./ResponseGroup[1]"/>
            <xsl:with-param name="yvalue" select="$FONTHEIGHT + ($BARHEIGHT + 2) * $num_cats"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:for-each select="Categorization/ResponseGroup">
          <xsl:call-template name="drawTextCat">
            <xsl:with-param name="respGroup" select="."/>
            <xsl:with-param name="yvalue" select="$FONTHEIGHT + ($BARHEIGHT + 2) * position()"/>
          </xsl:call-template>
        </xsl:for-each>
      </g>
      <xsl:call-template name="numbers">
        <xsl:with-param name="yvalue" select="$height - 1"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="xoffset" select="$TEXTWIDTH"/>
      </xsl:call-template>
    </svg>
  </xsl:template>

  <xsl:template name="hbargraph">
    <xsl:param name="questionXml"/>
    <xsl:param name="num_steps">5</xsl:param>
    <xsl:param name="value">2</xsl:param>
    <xsl:param name="title">Bar Graph</xsl:param>
    <xsl:param name="question_id">null</xsl:param>
    <xsl:param name="offset">0</xsl:param>
    <xsl:param name="barcolor">#66f</xsl:param>
    <xsl:variable name="height" select="$FONTHEIGHT + $BARHEIGHT + $NUMHEIGHT + 2"/>
    <svg xmlns:xlink="http://www.w3.org/1999/xlink"
      width="{$WIDTH}" height="{$height}">
      <defs>
        <symbol id="graphbox" viewBox="0 0 {$num_steps - 1} 0.1" 
          preserveAspectRatio="none">
          <g style="stroke: black; stroke-width: 0.015; fill: none">
            <rect width="{$num_steps - 1}" height="0.1" x="0" y="0" 
              style="stroke-width: 0.02"/>
            <xsl:call-template name="axislines">
              <xsl:with-param name="num_steps" select="$num_steps"/>
            </xsl:call-template>
            <path d="M {$offset} 0 v .1 h {$value - $offset} v -.1 z" 
              style="fill: {$barcolor}; fill-opacity: 0.7"/>
            <xsl:if test="$offset &gt; 0 and ($offset - $value) &lt; 0.07 and ($offset - $value) &gt; -0.07">
              <path d="M {$value} 0 l 0.07 0.05 l -0.07 0.05 l -0.07 -0.05 z" 
                style="fill: black; fill-opacity: 0.3"/>
            </xsl:if>
          </g>
        </symbol>
      </defs>
      <title><xsl:value-of select="$title"/></title>
      <desc>School: <xsl:value-of select="/Eval_Results/@school"/>, 
      Eval: <xsl:value-of select="/Eval_Results/@eval_id"/>, 
      EvalQuestion: <xsl:value-of select="$question_id"/></desc>
      <use xlink:href="#graphbox" 
        x="0" y="{$FONTHEIGHT + 2}" width="{$WIDTH}" height="{$BARHEIGHT}"/>
      <g style="font-size:{$FONTHEIGHT} ; font-family:sans-serif">
        <text x="0" y="{$FONTHEIGHT + 1}" style="text-anchor: start">
          <xsl:value-of select="$questionXml//low_text"/>
        </text>
        <text x="{$WIDTH div 2}" y="{$FONTHEIGHT + 1}" style="text-anchor:middle">
          <xsl:value-of select="$questionXml//mid_text"/>
        </text>
        <text x="{$WIDTH}" y="{$FONTHEIGHT + 1}" style="text-anchor: end">
          <xsl:value-of select="$questionXml//high_text"/>
        </text>
      </g>
      <xsl:call-template name="numbers">
        <xsl:with-param name="yvalue" select="$height - 1"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
      </xsl:call-template>
    </svg>
  </xsl:template>

  <xsl:template name="numbers">
    <xsl:param name="yvalue"/>
    <xsl:param name="num_steps">5</xsl:param>
    <xsl:param name="xoffset">0</xsl:param>
    <g style="font-size:{$NUMFONTHEIGHT}; font-family:sans-serif">
      <xsl:call-template name="draw_numbers">
        <xsl:with-param name="yvalue" select="$yvalue"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="xoffset" select="$xoffset"/>
      </xsl:call-template>
    </g>
  </xsl:template>

  <xsl:template name="draw_numbers">
    <xsl:param name="x">1</xsl:param>
    <xsl:param name="xoffset">0</xsl:param>
    <xsl:param name="num_steps"/>
    <xsl:param name="yvalue"/>
    <xsl:variable name="xvalue" select="$xoffset + ($WIDTH div ($num_steps - 1)) * ($x - 1)"/>
    <text x="{$xvalue}" y="{$yvalue}">
      <xsl:attribute name="style">
        <xsl:choose>
          <xsl:when test="$x = 1">text-anchor:start</xsl:when>
          <xsl:when test="$x = $num_steps">text-anchor:end</xsl:when>
          <xsl:otherwise>text-anchor:middle</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="$x"/>
    </text>
    <xsl:if test="$x &lt; $num_steps">
      <xsl:call-template name="draw_numbers">
        <xsl:with-param name="yvalue" select="$yvalue"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="xoffset" select="$xoffset"/>
        <xsl:with-param name="x" select="$x + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="createBarGraph">
    <xsl:param name="questionXml"/>
    <xsl:variable name="question_id" select="@eval_question_id"/>
    <xsl:variable name="value" select="ResponseGroup/ResponseStatistics/mean"/>
    <bar-graph>
      <xsl:attribute name="eval_question_id">
        <xsl:value-of select="@eval_question_id" />
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$questionXml/PlusMinusRating">
          <xsl:variable name="offset" select="floor($questionXml/PlusMinusRating/@num_steps div 2)"/>
          <xsl:call-template name="hbargraph">
            <xsl:with-param name="questionXml" select="$questionXml"/>
            <xsl:with-param name="num_steps" select="$questionXml/PlusMinusRating/@num_steps"/>
            <xsl:with-param name="value" select="$value - 1"/>
            <xsl:with-param name="title">Plus/Minus Rating Bar Graph</xsl:with-param>
            <xsl:with-param name="question_id" select="$question_id"/>
            <xsl:with-param name="offset" select="$offset"/>
            <xsl:with-param name="barcolor">
              <xsl:choose>
                <xsl:when test="($value - 1) &gt; $offset">#6f6</xsl:when>
                <xsl:otherwise>#f66</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="hbargraph">
            <xsl:with-param name="questionXml" select="$questionXml"/>
            <xsl:with-param name="num_steps" select="$questionXml/NumericRating/@num_steps"/>
            <xsl:with-param name="value" select="$value - 1"/>
            <xsl:with-param name="title">Numeric Rating Bar Graph</xsl:with-param>
            <xsl:with-param name="question_id" select="$question_id"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </bar-graph>
  </xsl:template>

  <xsl:template name="createBarGraphGroup">
    <xsl:param name="questionXml"/>
    <xsl:variable name="question_id" select="@eval_question_id"/>
    <xsl:variable name="value" select="ResponseGroup/ResponseStatistics/mean"/>
    <xsl:variable name="num_questions" select="count($questionXml/following-sibling::EvalQuestionRef)+1"/>
    <bar-graph eval_question_id="{$question_id}">
      <xsl:choose>
        <xsl:when test="$questionXml/PlusMinusRating">
          <xsl:variable name="offset" select="floor($questionXml/PlusMinusRating/@num_steps div 2)"/>
          <xsl:call-template name="hbargraphgroup">
            <xsl:with-param name="num_questions" select="$num_questions"/>
            <xsl:with-param name="questionXml" select="$questionXml"/>
            <xsl:with-param name="num_steps" select="$questionXml/PlusMinusRating/@num_steps"/>
            <xsl:with-param name="value" select="$value"/>
            <xsl:with-param name="title">Plus/Minus Rating Bar Graph</xsl:with-param>
            <xsl:with-param name="question_id" select="$question_id"/>
            <xsl:with-param name="offset" select="$offset"/>
            <xsl:with-param name="barcolor">
              <xsl:choose>
                <xsl:when test="($value - 1) &gt; $offset">#6f6</xsl:when>
                <xsl:otherwise>#f66</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="hbargraphgroup">
            <xsl:with-param name="num_questions" select="$num_questions"/>
            <xsl:with-param name="questionXml" select="$questionXml"/>
            <xsl:with-param name="num_steps" select="$questionXml/NumericRating/@num_steps"/>
            <xsl:with-param name="value" select="$value - 1"/>
            <xsl:with-param name="title">Numeric Rating Bar Graph</xsl:with-param>
            <xsl:with-param name="question_id" select="$question_id"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </bar-graph>
  </xsl:template>

  <xsl:template name="createBarGraphCat">
    <xsl:param name="questionXml"/>
    <xsl:variable name="question_id" select="@eval_question_id"/>
    <xsl:variable name="raw_cats" select="count(Categorization/ResponseGroup)"/>
    <xsl:variable name="num_cats">
      <xsl:choose>
        <xsl:when test="$raw_cats = 1">1</xsl:when>
        <xsl:otherwise><xsl:value-of select="$raw_cats + 1"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <bar-graph eval_question_id="{$question_id}">
      <xsl:choose>
        <xsl:when test="$questionXml/PlusMinusRating">
          <xsl:variable name="offset" select="floor($questionXml/PlusMinusRating/@num_steps div 2)"/>
          <xsl:call-template name="hbargraphcat">
            <xsl:with-param name="num_cats" select="$num_cats"/>
            <xsl:with-param name="questionXml" select="$questionXml"/>
            <xsl:with-param name="num_steps" select="$questionXml/PlusMinusRating/@num_steps"/>
            <xsl:with-param name="title">Plus/Minus Rating Bar Graph</xsl:with-param>
            <xsl:with-param name="question_id" select="$question_id"/>
            <xsl:with-param name="offset" select="$offset"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="hbargraphcat">
            <xsl:with-param name="num_cats" select="$num_cats"/>
            <xsl:with-param name="questionXml" select="$questionXml"/>
            <xsl:with-param name="num_steps" select="$questionXml/NumericRating/@num_steps"/>
            <xsl:with-param name="title">Numeric Rating Bar Graph</xsl:with-param>
            <xsl:with-param name="question_id" select="$question_id"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </bar-graph>
  </xsl:template>
</xsl:stylesheet>
