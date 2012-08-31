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
  <xsl:variable name="evalURL">http://<xsl:value-of select="$HOST"/>/XMLObject/<xsl:value-of select="$FILTER"/>eval/<xsl:value-of select="/IndividualResults/@school"/>/<xsl:value-of select="/IndividualResults/@eval_id"/>/<xsl:value-of select="$FILTER_ID"/></xsl:variable>

  <xsl:variable name="evalXml" select="document($evalURL)/Eval"/>

  <xsl:variable name="resultsXml" select="/IndividualResults"/>

  <xsl:output method="html"/>

  <xsl:template match="/">
    <table border="1" cellspacing="0">
      <tr>
        <th width="60%">Question</th>
        <th width="40%">Response</th>
      </tr>
      <xsl:for-each select="$evalXml/EvalQuestion">
        <xsl:variable name="eval_question_id" select="@eval_question_id"/>
        <xsl:variable name="response" select="$resultsXml/Response[@eval_question_id=$eval_question_id]"/>
        <xsl:choose>
          <xsl:when test="NumericRating | PlusMinusRating">
            <tr>
              <td valign="top">
                <xsl:if test="question_label"><b><xsl:value-of select="question_label"/>.</b></xsl:if>
                <xsl:text> </xsl:text>
                <xsl:value-of select="descendant::question_text"/>
              </td>
              <td align="center">
                <table width="100%">
                  <tr>
                    <td>
                      <table width="100%">
                        <tr>
                          <td align="left"><xsl:value-of select="descendant::low_text"/></td>
                          <td align="right"><xsl:value-of select="descendant::high_text"/></td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                          <xsl:call-template name="table_graphic">
                            <xsl:with-param name="num_steps" select=".//@num_steps"/>
                            <xsl:with-param name="response" select="$response"/>
                            <xsl:with-param name="width" select="100 div .//@num_steps"/>
                            <xsl:with-param name="count" select="1"/>
                          </xsl:call-template>
                        </tr>
                        <tr>
                          <xsl:call-template name="table_numbers">
                            <xsl:with-param name="count" select="1"/>
                            <xsl:with-param name="num_steps" select=".//@num_steps"/>
                          </xsl:call-template>
                        </tr>
                      </table>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </xsl:when>
          <xsl:when test="MultipleChoice | MultipleResponse">
            <tr>
              <td valign="top">
                <xsl:if test="question_label"><b><xsl:value-of select="question_label"/>.</b></xsl:if>
                <xsl:text> </xsl:text>
                <xsl:value-of select="descendant::question_text"/>
              </td>
              <td>
                <table border="1" cellspacing="0" width="100%">
                  <xsl:for-each select="descendant::choice">
                    <tr>
                      <xsl:choose>
                        <xsl:when test="contains($response, .)">
                          <td bgcolor="#ccccff"><xsl:value-of select="."/></td>
                        </xsl:when>
                        <xsl:otherwise>
                          <td><xsl:value-of select="."/></td>
                        </xsl:otherwise>
                      </xsl:choose>
                    </tr>
                  </xsl:for-each>
                </table>
              </td>
            </tr>
          </xsl:when>
          <xsl:when test="FillIn">
            <tr>
              <td valign="top" colspan="2">
                <xsl:if test="question_label"><b><xsl:value-of select="question_label"/>.</b></xsl:if>
                <xsl:text> </xsl:text>
                <xsl:value-of select="descendant::question_text"/>
              </td>
            </tr>
            <tr>
              <td colspan="2"><i>Response: </i><xsl:value-of select="$response"/></td>
            </tr>
          </xsl:when>
          <xsl:otherwise>
            <tr>
              <td valign="top">
                <xsl:if test="question_label"><b><xsl:value-of select="question_label"/>.</b></xsl:if>
                <xsl:text> </xsl:text>
                <xsl:value-of select="descendant::question_text"/>
              </td>
              <td><xsl:value-of select="$response"/></td>
            </tr>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </table>
  </xsl:template>

  <xsl:template name="table_graphic">
    <xsl:param name="num_steps"/>
    <xsl:param name="response"/>
    <xsl:param name="width"/>

    <xsl:choose>
      <xsl:when test="$num_steps">
        <xsl:choose>
          <xsl:when test="$response &gt; 0">
            <td width="{$width}%" height="10" align="center" bgcolor="#6666cc"/>
          </xsl:when>
          <xsl:otherwise>
            <td width="{$width}%" height="10" align="center"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="table_graphic">
          <xsl:with-param name="num_steps" select="$num_steps - 1"/>
          <xsl:with-param name="response" select="$response - 1"/>
          <xsl:with-param name="width" select="$width"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="table_numbers">
    <xsl:if test="$count - 1 &lt; $num_steps">
      <td align="right"><b><xsl:value-of select="$count"/></b></td>
      <xsl:call-template name="table_numbers">
        <xsl:with-param name="num_steps" select="$num_steps"/>
        <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:if>
    <td></td>
  </xsl:template>

</xsl:stylesheet>
