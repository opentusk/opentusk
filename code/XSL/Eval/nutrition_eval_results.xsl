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

  <xsl:output method="html"/>

  <xsl:param name="SHOWUSERS"></xsl:param>

  <xsl:template match="/">
    <html>
      <body bgcolor="#FFFFFF">
        <h1>
          <xsl:if test="Eval_Results/eval_header/course-ref[@code]">
            <xsl:value-of select="Eval_Results/eval_header/course-ref/@code"/>: 
          </xsl:if>
          <xsl:value-of select="Eval_Results/eval_header/course-ref"/>
        </h1>
	<h1><xsl:value-of select="Eval_Results/eval_header/eval_title"/></h1>
        <xsl:apply-templates select="Eval_Results/Enrollment" />
        <table border="1" cellpadding="2">
          <xsl:apply-templates select="Eval_Results/Question_Results[EvalQuestion/MultipleChoice]"/>
	</table>
	<br/><br/>
        <h2>Numeric Rating Questions</h2>
	<table border="1" cellpadding="2">
	  <tr>
	    <td bgcolor="#eeeeee"><b>Question</b></td>
	    <td> </td>
	    <td><b>1</b></td>
	    <td><b>2</b></td>
	    <td><b>3</b></td>
	    <td><b>4</b></td>
	    <td><b>5</b></td>
	    <td> </td>
	    <td>No Answer</td>
	    <td>Not Applicable</td>
	    <td>Average</td>
            <td bgcolor="#eeeeee">FSNSP AVG.<br/>(for semester)</td>
	  </tr>
	  <xsl:apply-templates select="Eval_Results/Question_Results[EvalQuestion/NumericRating]"/>
	</table>
	<br/><br/>
	<h2>Written Responses</h2>
	<xsl:apply-templates select="Eval_Results/Question_Results[EvalQuestion/FillIn]"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="Enrollment">
    <h2>Enrollment Information</h2>
     <table border="1" cellpadding="2">
       <tr><td colspan="2">Total users: <xsl:value-of select="@count"/></td></tr>
       <tr>
         <th>Complete Users</th>
         <th>Incomplete Users</th>
       </tr>
       <tr>
         <td><xsl:value-of select="CompleteUsers/@percent"/>% (<xsl:value-of select="CompleteUsers/@count"/>/<xsl:value-of select="@count"/>)</td>
         <td><xsl:value-of select="IncompleteUsers/@percent"/>% (<xsl:value-of select="IncompleteUsers/@count"/>/<xsl:value-of select="@count"/>)</td>
       </tr>
       <xsl:if test="$SHOWUSERS">
         <tr>
           <td><xsl:apply-templates select="CompleteUsers"/></td>
           <td><xsl:apply-templates select="IncompleteUsers"/></td>
         </tr>
       </xsl:if>
     </table>
  </xsl:template>

  <xsl:template match="CompleteUsers">
    <ul><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="IncompleteUsers">
    <ul><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="user-ref">
    <li><xsl:value-of select="."/></li>
  </xsl:template>

  <xsl:template match="Question_Results[EvalQuestion/MultipleChoice]">
    <tr>
      <td bgcolor="#eeeeee">
        <b><xsl:value-of select="EvalQuestion/MultipleChoice/question_text"/></b>
      </td>
      <td>Responses</td>
    </tr>
    <xsl:for-each select="./ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
      <xsl:if test="@count!='0'">
        <tr>
	  <td bgcolor="#eeeeee"><xsl:value-of select="."/></td>
	  <td><xsl:value-of select="./@count"/></td>
        </tr>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Question_Results[EvalQuestion/FillIn]">
    <b><xsl:value-of select="EvalQuestion/label"/></b><xsl:text> </xsl:text>
    <xsl:value-of select="EvalQuestion/FillIn/question_text"/>
    <br/>
    <ul>
    <xsl:for-each select="./ResponseGroup/Response">
      <li><b><xsl:value-of select="@pretty_user_label"/><xsl:text>: </xsl:text></b><xsl:value-of select="."/></li>
    </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="Question_Results[EvalQuestion/NumericRating]">
    <tr>
      <td bgcolor="#eeeeee">
        <b><xsl:value-of select="EvalQuestion/label"/></b><xsl:text> </xsl:text>
	<xsl:value-of select="EvalQuestion/NumericRating/question_text"/>
     </td>
      <td><xsl:value-of select="EvalQuestion/NumericRating/low_text"/></td>
      <xsl:for-each select="./ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
        <td><xsl:value-of select="./@count"/></td>
      </xsl:for-each>
      <td><xsl:value-of select="EvalQuestion/NumericRating/high_text"/></td>
      <td><xsl:value-of select="ResponseGroup/ResponseStatistics/no_response_count"/></td>
      <td><xsl:value-of select="ResponseGroup/ResponseStatistics/na_response_count"/></td>
      <td><xsl:value-of select="ResponseGroup/ResponseStatistics/mean"/></td>
      <td bgcolor="#eeeeee"><xsl:value-of select="Question_Mean"/></td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
