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
  
  <xsl:variable name="evalURL">http://<xsl:value-of select="$HOST"/>/XMLObject/<xsl:value-of select="$FILTER"/>eval/<xsl:value-of select="/Eval_Results/@school"/>/<xsl:value-of select="/Eval_Results/@eval_id"/>/<xsl:value-of select="$FILTER_ID"/></xsl:variable>

  <xsl:variable name="evalResults" select="Eval_Results"/>
  <xsl:variable name="evalXml" select="document($evalURL)/Eval"/>

  <xsl:template match="/">
    <xsl:for-each select="$evalXml/child::*[self::EvalQuestion or self::EvalQuestionRef or self::QuestionGroup]">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="EvalQuestion">
  </xsl:template>

  <xsl:template match="EvalQuestion[FillIn]">
    <xsl:variable name="question" select="."/>
    <xsl:variable name="questionID" select="$question/@eval_question_id"/>
    <xsl:variable name="questionResults" select="$evalResults/Question_Results[@eval_question_id=$questionID]"/>
    
    <b><xsl:value-of select="$question/question_label"/>.</b> <xsl:value-of select="$question//question_text"/>
    <ul>
      <xsl:for-each select="$questionResults/ResponseGroup/Response">
        <li><xsl:value-of select="."/></li>
      </xsl:for-each>
    </ul>

    <br/>
  </xsl:template>

  <xsl:template match="EvalQuestion[MultipleChoice]">
    <xsl:variable name="question" select="."/>
    <xsl:variable name="questionID" select="$question/@eval_question_id"/>
    <xsl:variable name="questionResults" select="$evalResults/Question_Results[@eval_question_id=$questionID]"/>    

    <b><xsl:value-of select="$question/question_label"/>. </b> <xsl:value-of select="$question//question_text"/>

    <table border="1" cellpadding="3" cellspacing="0">
      <tr>
        <td nowrap="true" align="center">Total</td>
        <td nowrap="true" align="center">No Resp</td>
        <td nowrap="true" align="center">NA Resp</td>
        <xsl:for-each select="$question//choice">
          <td align="center" colspan="2"><xsl:value-of select="."/></td>
        </xsl:for-each>
      </tr>
      <tr>
        <td nowrap="true" align="center"><xsl:value-of select="$questionResults/ResponseGroup/ResponseStatistics/response_count"/></td>
        <td nowrap="true" align="center"><xsl:value-of select="$questionResults/ResponseGroup/ResponseStatistics/no_response_count"/></td>
        <td nowrap="true" align="center"><xsl:value-of select="$questionResults/ResponseGroup/ResponseStatistics/na_response_count"/></td>
        <xsl:for-each select="$questionResults/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
          <td nowrap="true" align="center"><xsl:value-of select="@count"/></td>
          <td nowrap="true" align="center"><xsl:value-of select="round((@count div $questionResults/ResponseGroup/ResponseStatistics/response_count) * 100)"/>%</td>
        </xsl:for-each>
      </tr>
    </table>

    <br/>
  </xsl:template>

  <xsl:template match="EvalQuestion[NumericRating|PlusMinusRating]">
    <xsl:variable name="question" select="."/>
    <xsl:variable name="questionID" select="$question/@eval_question_id"/>
    <xsl:variable name="questionResults" select="$evalResults/Question_Results[@eval_question_id=$questionID]"/>

    <b><xsl:value-of select="$question/question_label"/>. </b> <xsl:value-of select="$question//question_text"/>

    <table border="1" cellpadding="3" cellspacing="0">
      <tr>
        <td nowrap="true" align="center">Total</td>
        <td nowrap="true" align="center">No Resp</td>
        <td nowrap="true" align="center">NA Resp</td>
        <td nowrap="true" align="center">Low Text</td>
        <xsl:call-template name="EnumChoices">
          <xsl:param name="count" select="1"/>
          <xsl:with-param name="num_steps" select="$question//@num_steps"/>
        </xsl:call-template>
        <td nowrap="true" align="center">High Text</td>
      </tr>
      <tr>
        <td nowrap="true" align="center"><xsl:value-of select="$questionResults/ResponseGroup/ResponseStatistics/response_count"/></td>
        <td nowrap="true" align="center"><xsl:value-of select="$questionResults/ResponseGroup/ResponseStatistics/no_response_count"/></td>
        <td nowrap="true" align="center"><xsl:value-of select="$questionResults/ResponseGroup/ResponseStatistics/na_response_count"/></td>
        <td nowrap="true" align="center"><xsl:value-of select="$question//low_text"/></td>
        <xsl:for-each select="$questionResults/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
          <td nowrap="true" align="center" width="30"><xsl:value-of select="@count"/></td>
          <td nowrap="true" align="center" width="30"><xsl:value-of select="round((@count div $questionResults/ResponseGroup/ResponseStatistics/response_count) * 100)"/>%</td>
        </xsl:for-each>
        <td nowrap="true" align="center"><xsl:value-of select="$question//high_text"/></td>
      </tr>
    </table>

    <br/>
  </xsl:template>

  <xsl:template name="EnumChoices">
    <xsl:param name="count" select="1"/>
    <xsl:param name="num_steps" select="5"/>
    <xsl:if test="not($count &gt; $num_steps)">
      <td width="60" align="center" colspan="2"><b><xsl:value-of select="$count"/></b></td>
      <xsl:call-template name="EnumChoices">
        <xsl:with-param name="count" select="$count+1"/>
        <xsl:with-param name="$num_steps"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
