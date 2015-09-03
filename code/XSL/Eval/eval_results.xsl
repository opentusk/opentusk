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

  <xsl:include href="bar_graph.xsl"/>
  <xsl:include href="../Common/flow.xsl"/>

  <xsl:output method="html" encoding="iso-8859-1"/>
  <xsl:param name="SHOWUSERS"></xsl:param>
  <xsl:param name="FULLHTML"></xsl:param>
  <xsl:param name="PRETTYUSERLABEL"></xsl:param>
  <xsl:param name="MERGED"></xsl:param>
  <xsl:param name="MERGED_ID"></xsl:param>

  <xsl:variable name="eval_results" select="Eval_Results"/>
  <xsl:variable name="evalURL">http://<xsl:value-of select="$HOST"/>/XMLObject/<xsl:value-of select="$FILTER"/>eval/<xsl:value-of select="/Eval_Results/@school"/>/<xsl:value-of select="/Eval_Results/@eval_id"/>/<xsl:value-of select="$FILTER_ID"/></xsl:variable>

  <xsl:variable name="evalXml" select="document($evalURL)/Eval"/>
  <xsl:variable name="courseURL">http://<xsl:value-of select="$HOST"/>/XMLObject/course/<xsl:value-of select="Eval_Results/@school"/>/<xsl:value-of select="$evalXml/@course_id"/></xsl:variable>
  <xsl:variable name="courseXml" select="document($courseURL)/course"/>
  <xsl:variable name="completionsURL">
  	<xsl:choose>
  		<xsl:when test="$MERGED='1'">http://<xsl:value-of select="$HOST"/>/XMLObject/merged_eval_completions/<xsl:value-of select="Eval_Results/@school"/>/<xsl:value-of select="$MERGED_ID"/></xsl:when>
  		<xsl:otherwise>http://<xsl:value-of select="$HOST"/>/XMLObject/eval_completions/<xsl:value-of select="Eval_Results/@school"/>/<xsl:value-of select="/Eval_Results/@eval_id"/></xsl:otherwise>
  	</xsl:choose>
  </xsl:variable>
  <xsl:variable name="completionsXml" select="document($completionsURL)/Enrollment"/>

  <xsl:template match="/">
    <ol>
    <xsl:for-each select="$evalXml/child::*[self::EvalQuestion or self::EvalQuestionRef or self::QuestionGroup]">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    </ol>
  </xsl:template>

  <!-- Templates for dealing with "global" EvalQuestionRef elements  -->

  <xsl:template match="EvalQuestionRef[parent::Eval]">
    <xsl:variable name="root_question_id" select="./QuestionRef/@target_question_id"/>
    <xsl:variable name="root_question" select="$evalXml/descendant::EvalQuestion[@eval_question_id=$root_question_id]"/>
    <xsl:choose>
      <xsl:when test="$root_question[FillIn]">
        <xsl:call-template name="globalFillIn">
          <xsl:with-param name="question" select="."/>
          <xsl:with-param name="root_question" select="$root_question"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$root_question[NumericRating|PlusMinusRating]">
        <xsl:call-template name="globalNRPMR">
          <xsl:with-param name="question" select="."/>
          <xsl:with-param name="root_question" select="$root_question"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$root_question[MultipleChoice|MultipleResponse|YesNo|Count|DiscreteNumeric]">
        <xsl:call-template name="globalMCMRYNCDN">
          <xsl:with-param name="question" select="."/>
          <xsl:with-param name="root_question" select="$root_question"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- use "question root" parameter as a way to accomplish what is wanted -->

  <!-- "Global" EvalQuestion templates -->

  <xsl:template match="question_text/para[position()=1]">
    <p class="first_question_text">
      <xsl:call-template name="show_label">
        <xsl:with-param name="qid" select="../../@eval_question_id"/>
        <xsl:with-param name="label" select="../../question_label"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="question_text/para">
    <p class="question_text"><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template name="show_label">
    <xsl:param name="label"><xsl:value-of select="question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
        <li />
      </xsl:when>
      <xsl:when test="string-length($label) &gt; 0">
        <img src="/icons/transdot.gif" width="18" height="1"/>
        <span class="question_label"><xsl:value-of select="$label"/><xsl:text>. </xsl:text></span>
      </xsl:when>
      <xsl:otherwise>
        <img src="/icons/transdot.gif" width="36" height="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="question_text">
    <xsl:param name="text" select=".//question_text"/>
    <xsl:param name="label" select=".//question_label"/>
    <xsl:choose>
      <xsl:when test="$text/para">
        <div class="question_text"><xsl:apply-templates select="$text"/></div>
      </xsl:when>
      <xsl:otherwise>
        <p class="first_question_text">
          <xsl:call-template name="show_label">
            <xsl:with-param name="label" select="$label"/>
          </xsl:call-template>
          <xsl:apply-templates select="$text"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="EvalQuestion[parent::Eval and Title]">
    <h3 class="title"><xsl:call-template name="question_text"/></h3>
  </xsl:template>

  <xsl:template match="EvalQuestion[parent::Eval and Instruction]">
    <div class="QuestionResults"><xsl:call-template name="question_text"/></div>
  </xsl:template>

  <xsl:template name="categorizationHeader">
    <xsl:param name="question_results"/>
    <xsl:variable name="group_by_question_id" select="$question_results/Categorization/@group_by_question_id"/>
    <xsl:variable name="group_by_label" select="$evalXml//question_label[../@eval_question_id=$group_by_question_id]"/>
    <xsl:if test="$HIDEGROUPBY='0'">
      <div class="categorization">  Grouped by question <xsl:value-of select="$group_by_label"/> (ID=<xsl:value-of select="$group_by_question_id"/>).</div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="globalFillIn" match="EvalQuestion[parent::Eval and FillIn]">
    <xsl:param name="question" select="."/>
    <xsl:param name="root_question" select="."/>
    <xsl:variable name="question_id" select="$question/@eval_question_id"/>
    <xsl:variable name="question_results" select="$eval_results/Question_Results[@eval_question_id=$question_id]"/>
    <div class="QuestionResults">
      <xsl:call-template name="question_text">
        <xsl:with-param name="text" select="$question//question_text"/>
        <xsl:with-param name="label" select="$question//question_label"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$question_results/Categorization">
          <xsl:call-template name="categorizationHeader">
            <xsl:with-param name="question_results" select="$question_results"/>
          </xsl:call-template>
          <ul>
            <xsl:for-each select="$question_results/Categorization/ResponseGroup">
              <li>
                <xsl:choose>
                  <xsl:when test="./grouping_value='__NULL__'">
                    <b>No Response</b>
                  </xsl:when>
                  <xsl:otherwise>
                    <b><xsl:value-of select="./grouping_value"/></b>
                  </xsl:otherwise>
                </xsl:choose>
                (<xsl:value-of select="./ResponseStatistics/response_count"/>)
                <ul>
                  <xsl:for-each select="./Response">
                    <li><xsl:value-of select="."/></li>
                  </xsl:for-each>
                </ul>
                <br/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <xsl:otherwise>
          <ul>
            <xsl:for-each select="$question_results/ResponseGroup/Response">
              <li><xsl:value-of select="."/></li>
            </xsl:for-each>
          </ul>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="globalMCMRYNCDN" match="EvalQuestion[parent::Eval and (MultipleChoice or MultipleResponse or YesNo or Count or DiscreteNumeric)]">
    <xsl:param name="question" select="."/>
    <xsl:param name="root_question" select="."/>
    <xsl:variable name="question_id" select="$question/@eval_question_id"/>
    <xsl:variable name="question_results" select="$eval_results/Question_Results[@eval_question_id=$question_id]"/>

    <div class="QuestionResults">
      <xsl:call-template name="question_text">
        <xsl:with-param name="text" select="$question//question_text"/>
      </xsl:call-template>

      <xsl:choose>
        <xsl:when test="$question_results/Categorization">
          <xsl:call-template name="categorizationHeader">
            <xsl:with-param name="question_results" select="$question_results"/>
          </xsl:call-template>
          <ul>
            <xsl:if test="count($question_results/Categorization/ResponseGroup) &gt; 1">
              <li>
                <b>All</b>
                <table border="1" cellspacing="0">
                  <tr>
                    <th></th>
                    <th>N</th>
                    <th>%</th>
                  </tr>
                  <xsl:for-each select="$question_results/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
                    <xsl:sort select="." data-type="number"/>
                    <tr>
                      <td><xsl:value-of select="."/></td>
                      <td><xsl:value-of select="@count"/></td>
                      <td><xsl:value-of select="round(100 * (@count div ../../response_count))"/></td>
                    </tr>
                  </xsl:for-each>
                  <xsl:if test="$question_results/ResponseGroup/ResponseStatistics/no_response_count &gt; 0">
                    <tr>
                      <td>No Response</td>
                      <td><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/no_response_count"/></td>
                      <td><xsl:value-of select="round(100 * ($question_results/ResponseGroup/ResponseStatistics/no_response_count div ($question_results/ResponseGroup/ResponseStatistics/response_count + $question_results/ResponseGroup/ResponseStatistics/no_response_count + $question_results/ResponseGroup/ResponseStatistics/na_response_count)))"/></td>
                    </tr>
                  </xsl:if>
                  <xsl:if test="MultipleChoice">
                    <tr>
                      <td>All</td>
                      <td><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/response_count"/></td>
                      <td>100</td>
                    </tr>
                  </xsl:if>
                </table>
              </li>
            </xsl:if>
            <xsl:for-each select="$question_results/Categorization/ResponseGroup">
              <li>
                <b><xsl:value-of select="grouping_value"/></b>
                <table border="1" cellspacing="0">
                  <tr>
                    <th></th>
                    <th>N</th>
                    <th>%</th>
                  </tr>
                  <xsl:for-each select="ResponseStatistics/Histogram/HistogramBin">
                    <xsl:sort select="." data-type="number"/>
                    <tr>
                      <td><xsl:value-of select="."/></td>
                      <td><xsl:value-of select="@count"/></td>
                      <td><xsl:value-of select="round(100 * (@count div ../../response_count))"/></td>
                    </tr>
                  </xsl:for-each>
                  <xsl:if test="ResponseStatistics/no_response_count &gt; 0">
                    <tr>
                      <td>No Response</td>
                      <td><xsl:value-of select="ResponseStatistics/no_response_count"/></td>
                      <td><xsl:value-of select="round(100 * (ResponseStatistics/no_response_count div (ResponseStatistics/response_count + ResponseStatistics/no_response_count + $question_results/ResponseGroup/ResponseStatistics/na_response_count)))"/></td>
                    </tr>
                  </xsl:if>
                  <xsl:if test="MultipleChoice">
                    <tr>
                      <td>All</td>
                      <td><xsl:value-of select="ResponseStatistics/response_count"/></td>
                      <td>100</td>
                    </tr>
                  </xsl:if>
                </table>
                <br/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <xsl:otherwise>
		<xsl:choose>
			<xsl:when test="$MERGED != 1 and $completionsXml/@count = 1">
				<!-- This is a one man show !-->
				<xsl:choose>
					<xsl:when test="$question_results/ResponseGroup/ResponseStatistics/no_response_count &gt; 0"><b>No Response</b></xsl:when>
					<xsl:when test="$question_results/ResponseGroup/ResponseStatistics/na_response_count &gt; 0"><b>N/A</b></xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$question_results/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
							<xsl:sort select="." data-type="number"/>
							<xsl:if test="@count &gt; 0"><span style="padding-left:7px;"><b><xsl:value-of select="."/></b></span></xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
			          <table border="1" cellspacing="0">
			            <tr>
			              <th></th>
			              <th>N</th>
			              <th>%</th>
			            </tr>
			            <xsl:for-each select="$question_results/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
			              <xsl:sort select="." data-type="number"/>
			              <tr>
			                <td><xsl:value-of select="."/></td>
			                <td><xsl:value-of select="@count"/></td>
			                <td><xsl:value-of select="round(100 * (@count div ../../response_count))"/></td>
			              </tr>
			            </xsl:for-each>
			            <xsl:if test="$question_results/ResponseGroup/ResponseStatistics/no_response_count &gt; 0">
			              <tr>
			                <td>No Response</td>
			                <td><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/no_response_count"/></td>
			                <td><xsl:value-of select="round(100 * ($question_results/ResponseGroup/ResponseStatistics/no_response_count div ($question_results/ResponseGroup/ResponseStatistics/response_count + $question_results/ResponseGroup/ResponseStatistics/no_response_count + $question_results/ResponseGroup/ResponseStatistics/na_response_count)))"/></td>
			              </tr>
			            </xsl:if>
			            <xsl:if test="MultipleChoice">
			              <tr>
			                <td>All</td>
			                <td><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/response_count"/></td>
			                <td>100</td>
			              </tr>
			            </xsl:if>
			          </table>
			</xsl:otherwise>
		</xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="globalNRPMR" match="EvalQuestion[parent::Eval and (NumericRating or PlusMinusRating)]">
    <xsl:param name="question" select="."/>
    <xsl:param name="root_question" select="."/>
    <xsl:variable name="question_id" select="$question/@eval_question_id"/>
    <xsl:variable name="question_results" select="$eval_results/Question_Results[@eval_question_id=$question_id]"/>

    <div class="QuestionResults">
      <xsl:call-template name="question_text">
        <xsl:with-param name="text" select="$question//question_text"/>
      </xsl:call-template>
        <div class="inner">
      <xsl:choose>
        <xsl:when test="$question_results/Categorization">
          <xsl:call-template name="categorizationHeader">
            <xsl:with-param name="question_results" select="$question_results"/>
          </xsl:call-template>
            <xsl:call-template name="catsvgembed">
              <xsl:with-param name="question_id" select="$question_id"/>
              <xsl:with-param name="num_cats" select="count($question_results/Categorization/ResponseGroup) + 1"/>
              <xsl:with-param name="school" select="$evalXml/@school"/>
              <xsl:with-param name="eval_id" select="$evalXml/@eval_id"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>

		<xsl:choose>
			<xsl:when test="$MERGED != 1 and $completionsXml/@count = 1">
				<!-- This is a one man show !-->
				On a scale of
				<xsl:for-each select="$question_results/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
					<xsl:sort select="." data-type="number" order="ascending"/>
					<xsl:if test="position()=1">
						<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
				<!--(<xsl:value-of select="$question//low_text"/>)!--> to
				<xsl:for-each select="$question_results/ResponseGroup/ResponseStatistics/Histogram/HistogramBin">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position()=1">
						<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
				<!--(<xsl:value-of select="$question//high_text"/>)!-->:
				<b>
				<xsl:choose>
					<xsl:when test="$question_results/ResponseGroup/ResponseStatistics/mean">
						<xsl:value-of select="$question_results/ResponseGroup/Response"/>
					</xsl:when>
					<xsl:otherwise><xsl:text>--</xsl:text></xsl:otherwise>
				</xsl:choose>
				</b>
			</xsl:when>
			<xsl:otherwise>
				<div class="bargraph">
				  <span class="tableTitleSpan"><b>Frequency:</b></span>
				  <span class="tableContainerSpan" id="eval_question_H{$question_id}">
					<img src="/icons/transdot.gif" width="200px" height="1px"/><br/>
					Loading graph...
				  </span>
				</div>
				<div class="bargraph">
					<div>
					  <span class="tableTitleSpan"><b>Mean:</b></span>
					  <span class="tableContainerSpan" id="eval_question_{$question_id}">
						<img src="/icons/transdot.gif" width="200px" height="1px"/><br/>
						Loading graph...
					  </span>
					</div>
					<div>
					  <span class="tableTitleSpan"><b>Median:</b></span>
					  <span class="tableContainerSpan" id="eval_question_M{$question_id}">
						<img src="/icons/transdot.gif" width="200px" height="1px"/><br/>
						Loading graph...
					 </span>
					</div>
				</div>
				<p class="datastats">
				<b>N:</b><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/response_count"/>,
				<b>NA:</b><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/na_response_count"/><br/>
				<b><xsl:text>Mean:</xsl:text></b><xsl:choose>
				  <xsl:when test="$question_results/ResponseGroup/ResponseStatistics/mean">
					<xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/mean"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:text>--</xsl:text>
				  </xsl:otherwise>
				</xsl:choose>,
				<b><xsl:text>Std Dev:</xsl:text></b><xsl:choose>
				  <xsl:when test="$question_results/ResponseGroup/ResponseStatistics/standard_deviation">
					<xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/standard_deviation"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:text>--</xsl:text>
				  </xsl:otherwise>
				</xsl:choose><br/>
				<b>Median:</b><xsl:choose>
				  <xsl:when test="$question_results/ResponseGroup/ResponseStatistics/median">
					<xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/median"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:text>--</xsl:text>
				  </xsl:otherwise>
				</xsl:choose>,
				<b>25%:</b><xsl:choose>
				  <xsl:when test="$question_results/ResponseGroup/ResponseStatistics/median">
					<xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/median25"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:text>--</xsl:text>
				  </xsl:otherwise>
				</xsl:choose>,
				<b>75%:</b><xsl:choose>
				  <xsl:when test="$question_results/ResponseGroup/ResponseStatistics/median">
					<xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/median75"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:text>--</xsl:text>
				  </xsl:otherwise>
				</xsl:choose><br/>
				<b>Mode:</b><xsl:value-of select="$question_results/ResponseGroup/ResponseStatistics/mode"/><br/>
				</p>
				<div class="clear"><xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text></div>
			</xsl:otherwise>
		</xsl:choose>

        </xsl:otherwise>
      </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="EvalQuestion[parent::Eval and (TeachingSite or SmallGroupsInstructor)]">
    <xsl:param name="question" select="."/>
    <xsl:param name="root_question" select="."/>
    <xsl:variable name="question_id" select="$question/@eval_question_id"/>
    <xsl:variable name="question_results" select="$eval_results/Question_Results[@eval_question_id=$question_id]"/>

    <xsl:call-template name="globalMCMRYNCDN">
      <xsl:with-param name="question" select="."/>
      <xsl:with-param name="root_question" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="EvalQuestion[parent::Eval and IdentifySelf]">
    <xsl:param name="question" select="."/>
    <xsl:param name="root_question" select="."/>
    <xsl:variable name="question_id" select="$question/@eval_question_id"/>
    <xsl:variable name="question_results" select="$eval_results/Question_Results[@eval_question_id=$question_id]"/>
    <div class="QuestionResults">
      <xsl:call-template name="question_text">
        <xsl:with-param name="text" select="$question//question_text"/>
        <xsl:with-param name="label" select="$question//question_label"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$question_results/Categorization">
          <xsl:call-template name="categorizationHeader">
            <xsl:with-param name="question_results" select="$question_results"/>
          </xsl:call-template>
          <ul>
            <xsl:for-each select="$question_results/Categorization/ResponseGroup">
              <li>
                <xsl:choose>
                  <xsl:when test="./grouping_value='__NULL__'">
                    <b>No Response</b>
                  </xsl:when>
                  <xsl:otherwise>
                    <b><xsl:value-of select="./grouping_value"/></b>
                  </xsl:otherwise>
                </xsl:choose>
                (<xsl:value-of select="./ResponseStatistics/response_count"/>)
                <ul>
                  <xsl:for-each select="./Response">
                    <li><xsl:value-of select="."/></li>
                  </xsl:for-each>
                </ul>
                <br/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:when>
        <xsl:otherwise>
          <ul>
            <xsl:for-each select="$question_results/ResponseGroup/Response">
              <li><xsl:value-of select="."/></li>
            </xsl:for-each>
          </ul>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- QuestionGroup templates -->

  <xsl:template match="QuestionGroup[EvalQuestion[FillIn]]">
    <div class="QuestionGroupResults">
      <xsl:call-template name="globalFillIn">
        <xsl:with-param name="question" select="EvalQuestion"/>
        <xsl:with-param name="root_question" select="EvalQuestion"/>
      </xsl:call-template>

      <xsl:for-each select="EvalQuestionRef">
        <xsl:call-template name="globalFillIn">
          <xsl:with-param name="question" select="."/>
          <xsl:with-param name="root_question" select="../EvalQuestion"/>
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="QuestionGroup[EvalQuestion[NumericRating or PlusMinusRating]]">
    <xsl:choose>
      <xsl:when test=".//grouping">
        <xsl:for-each select="*">
          <xsl:call-template name="globalNRPMR">
            <xsl:with-param name="question" select="."/>
            <xsl:with-param name="root_question" select="../EvalQuestion"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
          <xsl:call-template name="groupsvgembed">
            <xsl:with-param name="question_id" select="EvalQuestion/@eval_question_id"/>
            <xsl:with-param name="num_questions" select="count(*)"/>
            <xsl:with-param name="school" select="$evalXml/@school"/>
            <xsl:with-param name="eval_id" select="$evalXml/@eval_id"/>
          </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="QuestionGroup[EvalQuestion[MultipleChoice or MultipleResponse or YesNo or Count or DiscreteNumeric]]">
    <xsl:call-template name="globalMCMRYNCDN">
      <xsl:with-param name="question" select="EvalQuestion"/>
      <xsl:with-param name="root_question" select="EvalQuestion"/>
    </xsl:call-template>

    <xsl:for-each select="EvalQuestionRef">
      <xsl:call-template name="globalMCMRYNCDN">
        <xsl:with-param name="question" select="."/>
        <xsl:with-param name="root_question" select="../EvalQuestion"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="QuestionGroup[EvalQuestion[SmallGroupsInstructor or TeachingSite]]">
    QuestionGroup headed by either a SmallGroupsInstructor or a TeachingSite
  </xsl:template>

</xsl:stylesheet>
