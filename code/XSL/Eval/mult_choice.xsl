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

  <!-- This cool code for putting stuff into filled columns was adapted from a post
       to the xsl-list mailing list by Paul Tyson <paul@precisiondocuments.com>
       on Thu, 27 Sep 2001. Thank you, Paul. -->
  <xsl:template name="make-choice-rows">
    <xsl:param name="n" select="1"/>
    <xsl:param name="root" select="."/>
    <xsl:variable name="numCols">
      <xsl:choose>
        <xsl:when test="$root/@num_columns &gt; 0 and $root/@num_columns &lt; 7">
          <xsl:value-of select="$root/@num_columns"/>
        </xsl:when>
        <xsl:otherwise>4</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$n &gt; count($root/choice)"/>
      <xsl:otherwise>
        <xsl:text>&#10;</xsl:text>
        <tr>
          <xsl:apply-templates select="$root/choice[position() &gt;= $n and position() &lt; $n + $numCols]">
            <xsl:with-param name="num" select="$n"/>
          </xsl:apply-templates>
          <xsl:if test="not($root/choice[position() &gt;= $n + $numCols]) and
                        count($root/choice) mod $numCols">
            <xsl:call-template name="fill-choice-row">
              <xsl:with-param name="num-empty"
                select="$numCols - count($root/choice) mod $numCols"/>
            </xsl:call-template>
          </xsl:if>
        </tr>
        <xsl:call-template name="make-choice-rows">
          <xsl:with-param name="n" select="$n + $numCols"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fill-choice-row">
    <xsl:param name="num-empty"/>
    <xsl:choose>
      <xsl:when test="$num-empty = 0"/>
      <xsl:otherwise>
        <td></td>
        <xsl:call-template name="fill-choice-row">
          <xsl:with-param name="num-empty" select="$num-empty - 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- End of Paul Tyson's code. -->

  <xsl:template match="choice">
    <xsl:param name="num" select="position()"/>
    <xsl:variable name="qid" select="../../@eval_question_id" />
    <xsl:variable name="show_nums" select="../@show_numbers = 'yes'"/>
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:text>&#10;</xsl:text>
    <td>
      <xsl:element name="input">
        <xsl:choose>
          <xsl:when test="parent::MultipleResponse">
            <xsl:attribute name="type">checkbox</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">radio</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:attribute name="name">eval_q_<xsl:value-of select="$qid"/></xsl:attribute>
        <xsl:variable name="val">
          <xsl:choose>
            <xsl:when test="@stored_value">
              <xsl:value-of select="@stored_value"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:number value="$num+position()-1" format="a"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="value"><xsl:value-of select="$val" /></xsl:attribute>
        <xsl:if test="contains($answer, $val)">
          <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="onClick">
          satisfy(<xsl:value-of select="$qid"/>, 'radio')</xsl:attribute>
      </xsl:element>
      <span class="choice_text">
        <xsl:if test="$show_nums">
          <xsl:number value="$num+position()-1" format="A"/>:
        </xsl:if>
        <xsl:apply-templates/>
      </span>
      <img src="/icons/transdot.gif" width="18" height="1"/>
    </td>
  </xsl:template>

  <xsl:template 
    match="MultipleChoice | QuestionRef[key('eval_question_id', @target_question_id)/MultipleChoice] | DiscreteNumeric | QuestionRef[key('eval_question_id', @target_question_id)/DiscreteNumeric]">
    <xsl:variable name="qid" select="../@eval_question_id"/>
    <xsl:variable name="label" select="../question_label"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid"/></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="{name()}">
      <xsl:call-template name="question_text"/>
      <table cellpadding="2" cellspacing="2" border="0">
        <xsl:choose>
          <xsl:when test="self::QuestionRef">
            <xsl:call-template name="make-choice-rows">
              <xsl:with-param name="root" 
                select="key('eval_question_id', @target_question_id)/MultipleChoice | key('eval_question_id', @target_question_id)/DiscreteNumeric"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="make-choice-rows"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@na_available='yes'">
          <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]"/>
          <xsl:variable name="val">
            <xsl:number value="count(choice)+1" format="a"/>
          </xsl:variable>
          <tr>
            <td>
              <input type="radio" name="eval_q_{$qid}" value="{$val}" onClick="satisfy({$qid},'radio')">
                <xsl:if test="$val=$answer">
                  <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
              </input>
              <xsl:text>N/A</xsl:text>
            </td>
          </tr>
        </xsl:if>
      </table>
    </div>
  </xsl:template>

  <xsl:template name="dropdown-choice">
    <xsl:param name="answer"/>
    <xsl:variable name="val">
      <xsl:choose>
        <xsl:when test="./@stored_value">
          <xsl:value-of select="./@stored_value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number value="position()" format="a"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <option value="{$val}">
      <xsl:if test="$val=$answer">
        <xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
    </option>
    <xsl:value-of select="."/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="MultipleChoice[@choice_style='dropdown'] | QuestionRef[key('eval_question_id', @target_question_id)/MultipleChoice[@choice_style='dropdown']] | DiscreteNumeric[@choice_style='dropdown'] | QuestionRef[key('eval_question_id', @target_question_id)/DiscreteNumeric[@choice_style='dropdown']]">
    <xsl:variable name="qid" select="../@eval_question_id"/>
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="{name()}">
      <xsl:call-template name="question_text"/>
      <select onChange="satisfy({$qid},'select')" name="eval_q_{$qid}">
        <option value="">&lt;&lt; Select response &gt;&gt;</option>
        <xsl:text>&#10;</xsl:text>
        <xsl:choose>
          <!-- If it's a reference, loop over the referred-to question's choices -->
          <xsl:when test="self::QuestionRef">
            <xsl:for-each select="key('eval_question_id', @target_question_id)/MultipleChoice/choice | key('eval_question_id', @target_question_id)/DiscreteNumeric/choice">
              <xsl:call-template name="dropdown-choice">
                <xsl:with-param name="answer" select="$answer"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <!-- Otherwise, loop over ours. -->
          <xsl:otherwise>
            <xsl:for-each select="choice">
              <xsl:call-template name="dropdown-choice">
                <xsl:with-param name="answer" select="$answer"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@na_available='yes'">
          <xsl:variable name="val">
            <xsl:number value="count(choice)+1" format="a"/>
          </xsl:variable>
          <xsl:element name="option">
            <xsl:attribute name="value"><xsl:value-of select="$val" /></xsl:attribute>
            <xsl:if test="$val=$answer">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
          </xsl:element>
          <xsl:text>N/A</xsl:text>
        </xsl:if>
      </select>
    </div>
  </xsl:template>

  <xsl:template 
    match="MultipleResponse | QuestionRef[key('eval_question_id', @target_question_id)/MultipleResponse]">
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="label" select="../question_label"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="MultipleResponse">
      <xsl:call-template name="question_text"/>
      <table cellpadding="2" cellspacing="2" border="0">
        <xsl:choose>
          <xsl:when test="self::QuestionRef">
            <xsl:call-template name="make-choice-rows">
              <xsl:with-param name="root" 
                select="key('eval_question_id', @target_question_id)/MultipleResponse"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="make-choice-rows"/>
          </xsl:otherwise>
        </xsl:choose>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="YesNo | QuestionRef[key('eval_question_id', @target_question_id)/YesNo]">
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:variable name="label" select="../question_label"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="YesNo">
      <xsl:call-template name="question_text"/>
      <div>
        <input value="a" type="radio" name="eval_q_{$qid}" onClick="satisfy({$qid},'radio')">
          <xsl:if test="$answer='a'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <span class="choice_text"><xsl:text>Yes</xsl:text></span>
        <img src="/icons/transdot.gif" height="1" width="6"/>
        <input value="b" type="radio" name="eval_q_{$qid}" onClick="satisfy({$qid},'radio')">
          <xsl:if test="$answer='b'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <span class="choice_text"><xsl:text>No</xsl:text></span>
        <xsl:if test="@na_available='yes'">
          <img src="/icons/transdot.gif" height="1" width="6"/>
          <input value="c" type="radio" name="eval_q_{$qid}" onClick="satisfy({$qid},'radio')">
            <xsl:if test="$answer='c'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <span class="choice_text"><xsl:text>N/A</xsl:text></span>
        </xsl:if>
      </div>
    </div>    
  </xsl:template>

</xsl:stylesheet>
