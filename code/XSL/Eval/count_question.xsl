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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template match="Count[low_bound/@lower_than_bound='yes']">
    <xsl:variable name="low_bound"><xsl:value-of select="./low_bound"/></xsl:variable>
    <xsl:variable name="high_bound"><xsl:value-of select="./high_bound"/></xsl:variable>
    <xsl:variable name="interval"><xsl:value-of select="./interval"/></xsl:variable>
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:variable name="label" select="../question_label"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="Count">
      <xsl:call-template name="question_text"/>
      <select name="eval_q_{$qid}" onChange="satisfy({$qid},'select')">
        <option value="">&lt;&lt; Choose quantity &gt;&gt;</option>
        <xsl:text>&#10;</xsl:text>
        <xsl:element name="option">
          <xsl:attribute name="value"><xsl:number value="1" format="a"/></xsl:attribute>
          <xsl:variable name="val"><xsl:number value="1" format="a"/></xsl:variable>
          <xsl:if test="$val=$answer">
            <xsl:attribute name="selected">selected</xsl:attribute>
          </xsl:if>
            <xsl:choose>
              <xsl:when test="$low_bound = 0">
                <xsl:text>less than 0</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:number value="$low_bound - 1"/><xsl:text> or less</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <xsl:call-template name="count_option">
          <xsl:with-param name="low"><xsl:number value="$low_bound"/></xsl:with-param>
          <xsl:with-param name="high"><xsl:number value="$high_bound"/></xsl:with-param>
          <xsl:with-param name="inter"><xsl:number value="$interval"/></xsl:with-param>
          <xsl:with-param name="count">2</xsl:with-param>
          <xsl:with-param name="answer"><xsl:value-of select="$answer"/></xsl:with-param>
        </xsl:call-template>
        <xsl:if test="high_bound[@higher_than_bound='yes']">
          <xsl:element name="option">
            <xsl:attribute name="value"><xsl:number value="ceiling(($high_bound - $low_bound) div $interval)+2" format="a"/></xsl:attribute>
            <xsl:variable name="val"><xsl:number value="ceiling(($high_bound - $low_bound) div $interval)+2" format="a"/></xsl:variable>
            <xsl:if test="$val=$answer">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:number value="$high_bound+1"/><xsl:text> or greater</xsl:text>
          </xsl:element>
        </xsl:if>
      </select>
    </div>
  </xsl:template>

  <xsl:template match="Count">
    <xsl:variable name="low_bound"><xsl:value-of select="./low_bound"/></xsl:variable>
    <xsl:variable name="high_bound"><xsl:value-of select="./high_bound"/></xsl:variable>
    <xsl:variable name="interval"><xsl:value-of select="./interval"/></xsl:variable>
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="Count">
      <xsl:call-template name="question_text"/>
      <select name="eval_q_{$qid}" onChange="satisfy({$qid},'select')">
        <option value="">&lt;&lt; Choose quantity &gt;&gt;</option>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="count_option">
          <xsl:with-param name="low"><xsl:number value="$low_bound"/></xsl:with-param>
          <xsl:with-param name="high"><xsl:number value="$high_bound"/></xsl:with-param>
          <xsl:with-param name="inter"><xsl:number value="$interval"/></xsl:with-param>
          <xsl:with-param name="count">1</xsl:with-param>
          <xsl:with-param name="answer"><xsl:value-of select="$answer"/></xsl:with-param>
        </xsl:call-template>
        <xsl:if test="high_bound[@higher_than_bound='yes']">
          <xsl:element name="option">
            <xsl:attribute name="value">
              <xsl:number value="ceiling(($high_bound - $low_bound + 1) div $interval)+1" format="a"/>
            </xsl:attribute>
            <xsl:number value="$high_bound+1"/><xsl:text> or greater</xsl:text>
          </xsl:element>
        </xsl:if>
      </select>
    </div>
  </xsl:template>

  <xsl:template name="count_option">
    <xsl:param name="low">0</xsl:param>
    <xsl:param name="high">10</xsl:param>
    <xsl:param name="inter">1</xsl:param>
    <xsl:param name="count">1</xsl:param>
    <xsl:param name="answer"></xsl:param>
    <xsl:variable name="val"><xsl:number value="$count" format="a"/></xsl:variable>
    <xsl:text>&#10;</xsl:text>
    <xsl:choose>
      <xsl:when test="$inter = 1">
        <xsl:element name="option">
          <xsl:if test="$val=$answer">
            <xsl:attribute name="selected">selected</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="value"><xsl:value-of select="$val"/></xsl:attribute>
          <xsl:number value="$low"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$inter = 2">
        <xsl:element name="option">
          <xsl:attribute name="value"><xsl:value-of select="$val"/></xsl:attribute>
          <xsl:if test="$val=$answer">
            <xsl:attribute name="selected">selected</xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$low+1 &lt;= $high">
              <xsl:number value="$low"/>
              <xsl:text> or </xsl:text>
              <xsl:number value="$low+1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number value="$high"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="option">
          <xsl:attribute name="value"><xsl:value-of select="$val"/></xsl:attribute>
          <xsl:if test="$val=$answer">
            <xsl:attribute name="selected">selected</xsl:attribute>
          </xsl:if>
          <xsl:number value="$low"/>
          <xsl:text> to </xsl:text>
          <xsl:choose>
            <xsl:when test="$high &lt;= $low + $inter - 1">
              <xsl:number value="$high"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number value="$low + $inter - 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$low + $inter - 1 &lt; $high">
      <xsl:call-template name="count_option">
        <xsl:with-param name="low"><xsl:number value="$low + $inter"/></xsl:with-param>
        <xsl:with-param name="high"><xsl:number value="$high"/></xsl:with-param>
        <xsl:with-param name="inter"><xsl:number value="$inter"/></xsl:with-param>
        <xsl:with-param name="count"><xsl:number value="$count + 1"/></xsl:with-param>
        <xsl:with-param name="answer"><xsl:value-of select="$answer"/></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
