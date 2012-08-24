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

  <xsl:output method="html" encoding="iso-8859-1"/>

  <!-- Are they using some saved answers? -->
  <xsl:param name="SAVED_ANSWER_ID"></xsl:param>
  <!-- Where can we get the XML files we need? -->
  <xsl:param name="URLPREFIX">http://tusk.tufts.edu/</xsl:param>

  <!-- Variable for where XML files are stored -->
   <xsl:variable name="answerXml">
    <xsl:if test="$SAVED_ANSWER_ID &gt; 0">
      <xsl:value-of select="$URLPREFIX"/>XMLObject/eval_saved_answers/<xsl:value-of select="/Eval/@school"/>/<xsl:value-of select="$SAVED_ANSWER_ID"/>
    </xsl:if>
  </xsl:variable>


  <xsl:template name="dot_and_label">
    <xsl:param name="qid"><xsl:value-of select="../@eval_question_id"/></xsl:param>
    <xsl:param name="required"><xsl:value-of select="../@required"/></xsl:param>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$required='Yes'">
        <img src="/icons/reddot.gif" width="10" height="10" alt="required"
          name="flag_{$qid}"/><xsl:text> </xsl:text>
        <script language="JavaScript">markRequired(<xsl:value-of select="$qid"/>);</script>
      </xsl:when>
      <xsl:otherwise>
        <img src="/icons/transdot.gif" width="10" height="10" alt="not required"
          name="flag_{$qid}"/><xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
      </xsl:when>
      <xsl:when test="string-length($label) &gt; 0">
        <span class="question_label"><xsl:value-of select="$label"/><xsl:text>. </xsl:text></span>
      </xsl:when>
      <xsl:otherwise>
        <img src="/icons/transdot.gif" height="1" width="26"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Question text: shows the label, if there is one, and throws in the correct box. -->
  <xsl:template name="question_text">
        <p class="question_text">
          <xsl:call-template name="dot_and_label"/>
          <xsl:apply-templates select="question_text"/>
        </p>
  </xsl:template>
 

  <!-- Titles: just do the question text. -->
  <xsl:template match="Title">
    <h3 class="title"><xsl:value-of select="./question_text"/></h3>
  </xsl:template>

  <!-- Instructions: Just do the text. -->
  <xsl:template match="Instruction">
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="Instruction"><xsl:value-of select="$label" /><xsl:call-template name="question_text"/></div>
  </xsl:template>

  <!-- FillIns: for long text. -->
  <xsl:template match="FillIn[@longtext='yes'] | QuestionRef[key('eval_question_id', @target_question_id)/FillIn[@longtext='yes']]">
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="question_text"/>
    <textarea onChange="satisfy({$qid},'text')" wrap="virtual" rows="5" cols="60" name="eval_q_{$qid}">
      <xsl:value-of select="$answer"/>
    </textarea>
  </xsl:template>

  <!-- FillIn: Short text. -->
  <xsl:template match="FillIn[@longtext='no'] | QuestionRef[key('eval_question_id', @target_question_id)/FillIn[@longtext='no']]">
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <xsl:call-template name="question_text"/>
	<xsl:element name="textarea">
		<xsl:attribute name="onkeypress">lengthCheck(<xsl:value-of select="$qid" />,'text',300)</xsl:attribute>
		<xsl:attribute name="onchange">satisfy(<xsl:value-of select="$qid" />,'text')</xsl:attribute>
		<xsl:attribute name="wrap">virtual</xsl:attribute>
		<xsl:attribute name="rows">5</xsl:attribute>
		<xsl:attribute name="cols">60</xsl:attribute>
		<xsl:attribute name="name">eval_q_<xsl:value-of select="$qid" /></xsl:attribute>
	        <xsl:value-of select="$answer"/>
	</xsl:element>
  </xsl:template>

  <!-- The other question types. -->
  <xsl:include href="mult_choice.xsl"/>
  <xsl:include href="numeric.xsl"/>
  <xsl:include href="db_based.xsl"/>
  <xsl:include href="count_question.xsl"/>
  <xsl:include href="question_group.xsl"/>

</xsl:stylesheet>
