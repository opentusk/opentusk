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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template match="IdentifySelf">
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:variable name="label" select="../question_label"/>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="IdentifySelf">
      <xsl:call-template name="question_text"/>
      <xsl:choose>
        <xsl:when test="../@required='Yes'">
          <p class="db_info">Your user ID is being saved with the results of this evaluation. <span style="color: red;">This 
          means that your evaluation is not anonymous!</span></p>
          <input type="hidden" name="eval_q_{$qid}" value="{$USERID}"/>
        </xsl:when>
        <xsl:otherwise>
          <p class="db_info">
            <input type="checkbox" name="eval_q_{$qid}" value="{$USERID}">
              <xsl:if test="$answer=$USERID">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input>
            Check here if you would like to identify yourself with the results of 
            this eval. (<span style="color: red;">If you check the box, your results 
            will no longer be anonymous.</span>)
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
    
  <xsl:template match="SmallGroupsInstructor">
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:comment> Answer : <xsl:value-of select="$answer"/></xsl:comment>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="SmallGroupsInstructor">
      <xsl:call-template name="question_text"/>
      <select name="eval_q_{$qid}" onChange="satisfy({$qid},'select')">
        <option value="">&lt;&lt; Choose Instructor &gt;&gt;</option>
        <xsl:for-each select="document($courseXml)/course/faculty-list/course-user[course-user-role[@role='Instructor']]">
          <xsl:variable name="val" select="@user-id"/>
          <option value="{$val}">
            <xsl:if test="$answer = $val">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@name"/>
          </option>
          <xsl:value-of select="."/>
        </xsl:for-each>
      </select>
    </div>
  </xsl:template>

  <xsl:template match="TeachingSite">
    <xsl:variable name="qid" select="../@eval_question_id" />
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="TeachingSite">
      <xsl:call-template name="question_text"/>
      <xsl:variable name="school" select="/Eval/@school"/>
      <xsl:choose>
        <xsl:when test="$TEACHING_SITE=''">
          <xsl:variable name="answer" select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]" />
          <select name="eval_q_{$qid}" onChange="satisfy({$qid},'select')">
            <option value="">&lt;&lt; Choose Site &gt;&gt;</option>
            <xsl:for-each select="document($courseXml)/course/teaching-site-list/teaching-site">
              <xsl:variable name="val"><xsl:value-of select="@teaching-site-id"/></xsl:variable>
              <option value="{$val}">
                <xsl:if test="$answer=$val">
                  <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="site-name"/> (<xsl:value-of select="site-location"/>)
              </option>
            </xsl:for-each>
          </select>
        </xsl:when>
        <xsl:otherwise>
	<xsl:choose>
		<xsl:when test="$school='Medical'">
		<p class="teaching_site">
	You are entered in the registrar's database as taking this course at 
	<b><xsl:value-of select="document($courseXml)/course/teaching-site-list/teaching-site[@teaching-site-id = $TEACHING_SITE]/site-name"/></b>.
	 If this is not correct, do not complete this evaluation. <xsl:value-of disable-output-escaping="yes" select="$HTML_EVAL_ERROR_MESSAGE" /> Thank you.
		</p>
		</xsl:when>
		<xsl:otherwise>
          <p class="db_info">You are entered in the registrar's database as taking this course at <b><xsl:value-of select="document($courseXml)/course/teaching-site-list/teaching-site[@teaching-site-id = $TEACHING_SITE]/site-name"/>.</b>
            If this is incorrect, please contact your student affairs office to correct the problem before continuing.</p>
		</xsl:otherwise>
	</xsl:choose>
        <input type="hidden" name="eval_q_{$qid}" value="{$TEACHING_SITE}"/>
	<script language="JavaScript">
		satisfy(<xsl:value-of select="$qid" />);
	</script>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

</xsl:stylesheet>
