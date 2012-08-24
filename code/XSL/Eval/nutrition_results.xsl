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

  <xsl:variable name="evalResultsXml" select="Eval_Results"/>

  <xsl:variable name="evalURL">http://<xsl:value-of select="$HOST"/>/XMLObject/eval/nutrition/<xsl:value-of select="/Eval_Results/@eval_id"/></xsl:variable>
  <xsl:variable name="evalXml" select="document($evalURL)/Eval"/>

  <xsl:variable name="courseURL">http://<xsl:value-of select="$HOST"/>/XMLObject/course/nutrition/<xsl:value-of select="$evalXml/@course_id"/></xsl:variable>
  <xsl:variable name="courseXml" select="document($courseURL)/course"/>
  
  <xsl:variable name="completionsURL">http://<xsl:value-of select="$HOST"/>/XMLObject/eval_completions/nutrition/<xsl:value-of select="/Eval_Results/@eval_id"/></xsl:variable>
  <xsl:variable name="completionsXml" select="document($completionsURL)/Enrollment"/>

  <xsl:variable name="mergedResultsURL">http://<xsl:value-of select="$HOST"/>/XMLObject/merged_eval_results/nutrition/<xsl:value-of select="$MERGED_EVAL_ID"/></xsl:variable>
  <xsl:variable name="mergedResultsXml" select="document($mergedResultsURL)/Eval_Results"/>

  <xsl:template match="/">
    <html>
      <head>
        <style type="text/css">
          p { 
          font-size: 12px;
          }
          th {
          font-size: 12px;
          }
          td {
          font-size: 12px;
          }
        </style>
        <title>HSDB Nutrition Eval Report: <xsl:value-of select="$evalXml/eval_title"/></title>
      </head>
      <body bgcolor="#FFFFFF">
        <xsl:call-template name="header"/><br/>
        <xsl:call-template name="instructors"/>
        <xsl:call-template name="completions"/>
        
        <table border="1" cellspacing="0">
          <xsl:apply-templates select="$evalXml/EvalQuestion[MultipleChoice]"/><br/>
        </table>
        <br/>
        <br/>

        <b>Numeric Rating Questions</b><br/>
        <table border="1" cellspacing="0">
          <tr>
            <th>Question</th>
            <th></th>
            <th width="20">1</th>
            <th width="20">2</th>
            <th width="20">3</th>
            <th width="20">4</th>
            <th width="20">5</th>
            <th></th>
            <th>No Answer</th>
            <th>Not Applicable</th>
            <th>Average</th>
            <th>FSNSP AVG. (for semester)</th>
          </tr>
          <xsl:apply-templates select="$evalXml/EvalQuestion[NumericRating|PlusMinusRating]"/><br/>
        </table>
        <br/>
        <br/>

        <b>Written Responses</b><br/><br/>
        <xsl:apply-templates select="$evalXml/EvalQuestion[FillIn]"/>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="instructors">
    <p>
      <table>
        <xsl:if test="$courseXml/faculty-list/course-user[course-user-role/@role='Instructor']">
          <tr>
            <td valign="top">
              Principal Instructors:
            </td>
            <td valign="top">
              <ul>
                <xsl:for-each select="$courseXml/faculty-list/course-user[course-user-role/@role='Instructor']/@name">
                  <li><xsl:value-of select="."/></li>
                </xsl:for-each>
              </ul>            
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="$courseXml/faculty-list/course-user[course-user-role/@role='Cooperating Instructor']">
          <tr>
            <td valign="top">
              Cooperating Instructors:
            </td>
            <td valign="top">
              <ul>
                <xsl:for-each select="$courseXml/faculty-list/course-user[course-user-role/@role='Cooperating Instructor']/@name">
                  <li><xsl:value-of select="."/></li>
                </xsl:for-each>
              </ul>            
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="$courseXml/faculty-list/course-user[course-user-role/@role='Teaching Assistant']">
          <tr>
            <td valign="top">
              Teaching Assistants:
            </td>
            <td valign="top">
              <ul>
                <xsl:for-each select="$courseXml/faculty-list/course-user[course-user-role/@role='Teaching Assistant']/@name">
                  <li><xsl:value-of select="."/></li>
                </xsl:for-each>
              </ul>
              
            </td>
          </tr>
        </xsl:if>        
      </table>
    </p>
  </xsl:template>
  
  <xsl:template match="EvalQuestion[FillIn]">
    <xsl:variable name="eval_question_id" select="@eval_question_id"/>
    <xsl:variable name="eval_question_results" select="$evalResultsXml/Question_Results[@eval_question_id=$eval_question_id]"/>

    <b>
      <xsl:value-of select="question_label"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select=".//question_text"/>
    </b>
    <br/>
    <br/>
    <table>
      <xsl:for-each select="$eval_question_results/ResponseGroup/Response">
        <xsl:sort select="@pretty_user_label"/>
        <tr>
          <xsl:choose>
            <xsl:when test="$eval_question_id='6333'">
              <td></td>
            </xsl:when>
            <xsl:otherwise>
              <td valign="top"><b><xsl:value-of select="@pretty_user_label"/>.</b></td>
            </xsl:otherwise>
          </xsl:choose>
          <td><xsl:value-of select="."/></td>
        </tr>
      </xsl:for-each>
    </table>
    <br/>
  </xsl:template>

  <xsl:template match="EvalQuestion[MultipleChoice]">
    <xsl:variable name="eval_question_id" select="@eval_question_id"/>

    <tr>
      <td><b><xsl:value-of select="./MultipleChoice/question_text"/></b></td>
      <td>Responses</td>
    </tr>
    <xsl:for-each select="$evalResultsXml/Question_Results[@eval_question_id=$eval_question_id]/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
      <xsl:sort data-type="number" select="@count" order="descending"/>
      <xsl:if test="@count>0">
        <tr>
          <td><xsl:value-of select="."/></td>
          <td><xsl:value-of select="@count"/></td>
        </tr>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="EvalQuestion[NumericRating|PlusMinusRating]">
    <xsl:variable name="eval_question_id" select="@eval_question_id"/>
    <xsl:variable name="eval_question_results" select="$evalResultsXml/Question_Results[@eval_question_id=$eval_question_id]"/>
    <xsl:variable name="merged_question_results" select="$mergedResultsXml/Question_Results[@eval_question_id=$eval_question_id]"/>

    <tr>
      <td>
        <b>
          <xsl:value-of select="question_label"/>
        </b>
        <xsl:text> </xsl:text>
        <xsl:value-of select=".//question_text"/>
      </td>
      <td align="center"><xsl:value-of select=".//low_text"/></td>
      <xsl:for-each select="$eval_question_results/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
        <td align="center"><xsl:value-of select="@count"/></td>
      </xsl:for-each>
      <td align="center"><xsl:value-of select=".//high_text"/></td>
      <td align="center"><xsl:value-of select="$eval_question_results/ResponseGroup/ResponseStatistics/no_response_count"/></td>
      <td align="center"><xsl:value-of select="$eval_question_results/ResponseGroup/ResponseStatistics/na_response_count"/></td>
      <td align="center">
        <xsl:choose>
          <xsl:when test="$eval_question_results/ResponseGroup/ResponseStatistics/mean">
            <xsl:value-of select="$eval_question_results/ResponseGroup/ResponseStatistics/mean"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>--</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td align="center">
        <xsl:if test="substring(question_label, 1, 2)='1-'">
          <xsl:value-of select="$merged_question_results/ResponseGroup/ResponseStatistics/mean"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="header">
    <b>
      <xsl:value-of select="$courseXml/registrar-code"/>: <xsl:value-of select="$courseXml/title"/><br/>
      <xsl:value-of select="$evalXml/eval_title"/><br/>
    </b>
  </xsl:template>

  <xsl:template name="completions">
    <b>Enrollment Information</b>
    <table border="1" cellspacing="0">
      <tr>
        <th>Total Users</th>
        <th>Complete Users</th>
        <th>Incomplete Users</th>
      </tr>
      <tr>
        <td align="center">
          <xsl:value-of select="$completionsXml/@count"/>
        </td>
        <td align="center">
          <xsl:value-of select="$completionsXml/CompleteUsers/@percent"/>%
          (<xsl:value-of select="$completionsXml/CompleteUsers/@count"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$completionsXml/@count"/>)
        </td>
        <td align="center">
          <xsl:value-of select="$completionsXml/IncompleteUsers/@percent"/>%
          (<xsl:value-of select="$completionsXml/IncompleteUsers/@count"/>
          <xsl:text>/</xsl:text>
          <xsl:value-of select="$completionsXml/@count"/>)
        </td>
      </tr>
    </table>
  </xsl:template>

</xsl:stylesheet>
