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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:template name="NumericChoices">
    <xsl:param name="num_steps">0</xsl:param>
    <xsl:param name="name">foo</xsl:param>
    <xsl:param name="counter">1</xsl:param>
    <xsl:param name="root"/>
    <xsl:param name="qid" select="../@eval_question_id"/>
    <xsl:param name="show_nums" select="false()"/>
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:if test="$counter &lt;= $num_steps">
      <xsl:text>&#10;</xsl:text>
      <xsl:element name="td">
        <xsl:if test="$counter = 1">
          <xsl:attribute name="align">right</xsl:attribute>
        </xsl:if>
        <img src="/icons/transdot.gif" height="1" width="18"/>
        <xsl:element name="input">
          <xsl:attribute name="type">radio</xsl:attribute>
          <xsl:variable name="val">
            <xsl:number value="$counter" format="a"/>
          </xsl:variable>
          <xsl:attribute name="value"><xsl:value-of select="$val"/></xsl:attribute>
          <xsl:if test="$val=$answer">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="name"><xsl:value-of select="$name"/></xsl:attribute>
          <xsl:attribute name="onClick">satisfy(<xsl:value-of select="$qid"/>,'radio')</xsl:attribute>
        </xsl:element>
        <xsl:if test="$show_nums">
          <span class="scale_text"><xsl:value-of select="$counter"/></span>
        </xsl:if>
        <img src="/icons/transdot.gif" height="1" width="18"/>
      </xsl:element>
      <xsl:call-template name="NumericChoices">
        <xsl:with-param name="counter" select="$counter + 1"/>
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="qid" select="$qid"/>
        <xsl:with-param name="root" select="$root"/>
        <xsl:with-param name="show_nums" select="$show_nums"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="RatingQuestion">
    <xsl:param name="root" select="."/>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:variable name="qid" select="../@eval_question_id"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="{name($root)}">
      <xsl:call-template name="question_text"/>
      <table cellpadding="2" cellspacing="2" border="0">
        <tr>
          <td align="right">
            <span class="scale_text"><xsl:apply-templates select="$root/low_text"/></span>
            <img src="/icons/transdot.gif" height="1" width="18"/>
          </td>
          <td colspan="{$root/@num_steps - 2}" align="center">
            <span class="scale_text"><xsl:apply-templates select="$root/mid_text"/></span>
          </td>
          <td>
            <img src="/icons/transdot.gif" height="1" width="18"/>
            <span class="scale_text"><xsl:apply-templates select="$root/high_text"/></span>
          </td>
          <xsl:if test="@na_available='yes'">
            <td> </td>
          </xsl:if>
        </tr>
        <tr>
          <xsl:call-template name="NumericChoices">
            <xsl:with-param name="qid" select="$qid"/>
            <xsl:with-param name="num_steps" select="$root/@num_steps"/>
            <xsl:with-param name="name">eval_q_<xsl:value-of select="../@eval_question_id"/></xsl:with-param>
            <xsl:with-param name="mid_text"><xsl:value-of select="$root/mid_text"/></xsl:with-param>
            <xsl:with-param name="show_nums" select="$root/@show_numbers = 'yes'"/>
          </xsl:call-template>
          <xsl:if test="@na_available='yes'">
            <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]"/>
            <xsl:variable name="val"><xsl:number value="$root/@num_steps+1" format="a"/></xsl:variable>
            <td colspan="{@num_steps}" align="center">
              <xsl:element name="input">
                <xsl:attribute name="type">radio</xsl:attribute>
                <xsl:attribute name="name">eval_q_<xsl:value-of select="$qid"/></xsl:attribute>
                <xsl:attribute name="value"><xsl:value-of select="$val"/></xsl:attribute>
                <xsl:attribute name="onClick">satisfy(<xsl:value-of select="$qid"/>,'radio')</xsl:attribute>
                <xsl:if test="$val=$answer">
                  <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
              </xsl:element>
              <span class="scale_text"><xsl:text>N/A</xsl:text></span>
            </td>
          </xsl:if>
        </tr>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="NumericRating|PlusMinusRating|QuestionRef[key('eval_question_id',@target_question_id)/NumericRating or key('eval_question_id',@target_question_id)/PlusMinusRating]">
    <xsl:choose>
      <xsl:when test="self::QuestionRef and key('eval_question_id',@target_question_id)/NumericRating">
        <xsl:call-template name="RatingQuestion">
          <xsl:with-param name="root" select="key('eval_question_id',@target_question_id)/NumericRating"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="self::QuestionRef and key('eval_question_id',@target_question_id)/PlusMinusRating">
        <xsl:call-template name="RatingQuestion">
          <xsl:with-param name="root" 
            select="key('eval_question_id',@target_question_id)/PlusMinusRating"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="RatingQuestion"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
