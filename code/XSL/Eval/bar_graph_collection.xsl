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


<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0">

  <xsl:output method="xml" indent="yes"/> 

  <xsl:template match="text()"></xsl:template>

  <xsl:include href="bar_graph.xsl"/>

  <xsl:variable name="evalId" select="/Eval_Results/@eval_id"/>
  <xsl:variable name="school" select="/Eval_Results/@school"/>
  <xsl:variable name="evalXml" select="/Eval_Results/Eval"/>

  <xsl:template match="/">
    <bar-graph-collection>
      <xsl:apply-templates select="Eval_Results/Question_Results" />
    </bar-graph-collection>
  </xsl:template>

  <xsl:template match="Question_Results">
    <xsl:variable name="qid" select="@eval_question_id"/>
    <xsl:variable name="questionXml" select="$evalXml//EvalQuestion[@eval_question_id=$qid]|$evalXml//EvalQuestionRef[@eval_question_id=$qid]"/>
    <xsl:choose>
      <!-- Question is categorized, and is NR or PMR -->
      <xsl:when test="./Categorization and ($questionXml/NumericRating or $questionXml/PlusMinusRating)">
        <xsl:call-template name="createBarGraphCat">
          <xsl:with-param name="questionXml" select="$questionXml"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Question is categorized and is a QRef... -->
      <xsl:when test="./Categorization and $questionXml/QuestionRef">
        <xsl:variable name="otherId" select="$questionXml/QuestionRef/@target_question_id"/>
        <xsl:variable name="otherQuestion" select="$evalXml//EvalQuestion[@eval_question_id=$otherId]"/>
        <!-- ...and the referent is a NR or PMR -->
        <xsl:if test="$otherQuestion/NumericRating or $otherQuestion/PlusMinusRating">
          <xsl:call-template name="createBarGraphCat">
            <xsl:with-param name="questionXml" select="$otherQuestion"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <!-- Question is a NR or PMR in a Group -->
      <xsl:when test="$questionXml/parent::QuestionGroup and ($questionXml/NumericRating or $questionXml/PlusMinusRating)">
        <xsl:call-template name="createBarGraphGroup">
          <xsl:with-param name="questionXml" select="$questionXml"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Question is a NR or PMR *not* in a Group -->
      <xsl:when test="$questionXml/NumericRating or $questionXml/PlusMinusRating">
        <xsl:call-template name="createBarGraph">
          <xsl:with-param name="questionXml" select="$questionXml"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Question is a QRef... -->
      <xsl:when test="$questionXml/QuestionRef">
        <!-- ...and it's not in a Group... -->
        <xsl:if test="not($questionXml/parent::QuestionGroup)">
          <xsl:variable name="otherId" select="$questionXml/QuestionRef/@target_question_id"/>
          <xsl:variable name="otherQuestion" select="$evalXml//EvalQuestion[@eval_question_id=$otherId]"/>
          <!-- ...and the referent is a NR or PMR -->
          <xsl:if test="$otherQuestion/NumericRating or $otherQuestion/PlusMinusRating">
            <xsl:call-template name="createBarGraph">
              <xsl:with-param name="questionXml" select="$otherQuestion"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
      </xsl:when>
      <!-- Otherwise, we don't need to make a bar graph. -->
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
