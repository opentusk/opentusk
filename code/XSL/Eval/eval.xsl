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

  <xsl:include href="../Common/flow.xsl"/>

  <!-- What user is filling out this eval? -->
  <xsl:param name="USERID"></xsl:param>
  <!-- Are they assigned to a teaching site? -->
  <xsl:param name="TEACHING_SITE"></xsl:param>
  <!-- How many users are registered? -->
  <xsl:param name="NUM_USERS">0</xsl:param>
  <!-- Who should this eval go back to if there is a problem? -->
  <xsl:param name="HTML_EVAL_ERROR_MESSAGE"></xsl:param>
  <xsl:param name="SITE_NAME"></xsl:param>
  <xsl:param name="EVALUATEE_NAME"></xsl:param>

  <xsl:key name="eval_question_id" match="EvalQuestion" use="@eval_question_id"/>

  <!-- Make all these things do nothing by default -->
  <xsl:template match="eval_title|due_date|available_date|prelim_due_date|CourseInfo|grouping|graphic_stylesheet|question_label"/>

  <xsl:variable name="courseXml"><xsl:value-of select="$URLPREFIX"/>XMLObject/course/<xsl:value-of select="/Eval/@school"/>/<xsl:value-of select="/Eval/@course_id"/></xsl:variable>
  <xsl:variable name="timePeriodXml"><xsl:value-of select="$URLPREFIX"/>XMLLister/timeperiod/<xsl:value-of select="/Eval/@school"/></xsl:variable>
  <xsl:variable name="time_period_id" select="/Eval/@time_period_id"/>

  <!-- Top level thing:  Put in a comment for the saved answers, and then run the rest. -->
  <xsl:template match="Eval">
    <xsl:comment>USERID: <xsl:value-of select="$USERID"/></xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:comment>Course URL: <xsl:value-of select="$courseXml"/></xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:comment>Saved Answers</xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="document($answerXml)/EvalAnswers/eval_answer"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="InfoBox"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- For each eval_answer, show the QID and the answer -->
  <xsl:template match="eval_answer">
    <xsl:comment>
      <xsl:text> </xsl:text><xsl:value-of select="@qid"/> : 
    </xsl:comment>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  <!-- Make the InfoBox element. -->
  <xsl:template name="InfoBox">
    <div class="infobox">
      <h4 class="title">Evaluation Information</h4>
      <table width="80%" cellpadding="2" cellspacing="2" border="0">
        <tr>
          <td align="right"><b>Eval Title:</b></td>
          <td align="left">
            <b style="font-size: 110%;"><xsl:value-of select="/Eval/eval_title"/></b>
          </td>
        </tr>

        <!-- Course Title -->
        <tr>
          <td align="right" width="25%"><b>Course:</b></td>
          <td align="left">
              <xsl:element name="a">
                <xsl:attribute name="href">/hsdb45/course/<xsl:value-of select="/Eval/@school"/>/<xsl:value-of select="/Eval/@course_id"/></xsl:attribute>
                <xsl:value-of select="document($courseXml)/course/title"/>
              </xsl:element>
          </td>
        </tr>

        <!-- Course Directors -->
        <xsl:variable name="dir_count">
          <xsl:value-of select="count(document($courseXml)/course/faculty-list/time-period[@id=$time_period_id]/course-user[course-user-role[@role='director']])"/>
        </xsl:variable>
        <xsl:if test="$dir_count &gt; 0">
          <tr>
            <td valign="top" align="right"><b>Course Director<xsl:if test="$dir_count &gt; 1">s</xsl:if>:</b></td>
            <td align="left">
              <xsl:for-each select="document($courseXml)/course/faculty-list/time-period[@id=$time_period_id]/course-user[course-user-role[@role='director']]">
                <xsl:element name="a">
                  <xsl:attribute name="href">/view/user/<xsl:value-of select="@user-id"/></xsl:attribute>
                  <xsl:value-of select="@name"/>
                </xsl:element>
                <xsl:if test="not(position() = $dir_count)">
                  <br/>
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>

        <!-- Teaching Site for course eval-->
        <xsl:variable name="eval_type"><xsl:value-of select="/Eval/@eval_type"/></xsl:variable>
        <xsl:choose>
        <xsl:when test="$eval_type = 'course'">
        
        <!-- Teaching Site -->
        <xsl:variable name="site_count">
          <xsl:value-of select="count(document($courseXml)/course/teaching-site-list/teaching-site)"/>
        </xsl:variable>
        <xsl:if test="$site_count &gt; 0">
          <tr>
            <td valign="top" align="right"><b>Teaching Site<xsl:if test="$site_count &gt; 1">s</xsl:if>:</b></td>
            <td align="left">
	      <xsl:choose>
	        <xsl:when test="$site_count = 1">
	              <xsl:for-each select="document($courseXml)/course/teaching-site-list/teaching-site">
        	        <xsl:value-of select="site-name"/> (<xsl:value-of select="site-location"/>)
                	<xsl:if test="not(position() = $site_count)">
	                  <br/>
	                </xsl:if>
        	      </xsl:for-each>
	        </xsl:when>
	        <xsl:when test="$site_count &gt; 1">
		<script>
		function showHide(switchContent) {
			var currContent = document.getElementById('switchContent');
			currContent.style.display = (currContent.style.display == "none") ? 'inline' : 'none';
		
		}
		</script>
	        <a href="javascript:showHide('switchContent')" style="cursor:hand;cursor:pointer">Show/Hide Teaching Site</a> <br/>
		<div id="switchContent" style="display:none">
	              <xsl:for-each select="document($courseXml)/course/teaching-site-list/teaching-site">
        	        <xsl:value-of select="site-name"/> (<xsl:value-of select="site-location"/>)
                	<xsl:if test="not(position() = $site_count)">
	                  <br/>
	                </xsl:if>
        	      </xsl:for-each>
		</div>
	        </xsl:when>
	      </xsl:choose>
            </td>
          </tr>
        </xsl:if>

        </xsl:when>
        <xsl:when test="$eval_type = 'teaching'">
          <tr>
            <td valign="top" align="right"><b>Teaching Site:</b></td>
            <td align="left"> <xsl:value-of select="$SITE_NAME"/> </td>
          </tr>
          <tr>
            <td valign="top" align="right"><b>Evaluatee:</b></td>
            <td align="left"> <xsl:value-of select="$EVALUATEE_NAME"/> </td>
          </tr>
        </xsl:when>
        </xsl:choose>

        <!-- Time Period -->
        <tr>
          <td align="right"><b>Time Period:</b></td>            
          <td align="left">
            <xsl:value-of select="document($timePeriodXml)/TimePeriodList/time_period[@time_period_id=$time_period_id]/title"/> 
            (<xsl:value-of select="document($timePeriodXml)/TimePeriodList/time_period[@time_period_id=$time_period_id]/start_date"/> to 
            <xsl:value-of select="document($timePeriodXml)/TimePeriodList/time_period[@time_period_id=$time_period_id]/end_date"/>)
          </td>
        </tr>

        <!-- Due Date -->
        <tr>
          <td align="right"><b>Due Date:</b></td>
          <td align="left">
			<xsl:choose>
				<xsl:when test="/Eval/prelim_due_date != '0000-00-00'">
					<xsl:value-of select="/Eval/prelim_due_date"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/Eval/due_date"/>
				</xsl:otherwise>
			</xsl:choose>
          </td>
        </tr>

        <!--  Num Users -->
        <xsl:if test="$NUM_USERS &gt; 0">
          <tr>
            <td align="right"><b>Registered Users:</b></td>
            <td align="left"><xsl:value-of select="$NUM_USERS"/></td>
          </tr>
        </xsl:if>

        <xsl:if test="//EvalQuestion[@required='Yes']">
          <tr>
            <td align="right"><img src="/icons/reddot.gif" width="10" height="10"/><b>:</b></td>
            <td align="left"><em>Required question</em></td>
          </tr>
        </xsl:if>

      </table>
    </div>
  </xsl:template>


  <xsl:include href="eval_question.xsl"/>

</xsl:stylesheet>
