<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="border_size">0</xsl:param>

  <!-- QuestionGroup headed by a YesNo -->
  <xsl:template match="QuestionGroup[EvalQuestion/YesNo]">
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="QuestionGroup">
      <table cellpadding="4" cellspacing="0" border="{$border_size}">
        <tr>
          <!-- Header row contains only Yes and No -->
          <th></th> <th></th> <th class="group_choice">Yes</th> <th class="group_choice">No</th>
          <!-- ...and N/A if applicable. -->
          <xsl:if test=".//*[@na_available='yes']">
            <th class="group_choice">N/A</th>
          </xsl:if>
        </tr>
        <xsl:text>&#10;</xsl:text>
        <!-- Now, actually do the YesNo element -->
        <xsl:apply-templates select="EvalQuestion/YesNo" mode="inGroup"/>
        <!-- Then, do the same for every QuestionRef after that -->
        <xsl:for-each select="EvalQuestionRef/QuestionRef">
          <xsl:call-template name="choice_row">
            <xsl:with-param name="num_choices">2</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </table>
    </div>
  </xsl:template>

  <!-- QuestionGroup headed by MultipleChoice or MultipleResponse -->
  <xsl:template match="QuestionGroup[EvalQuestion/MultipleChoice or EvalQuestion/MultipleResponse or EvalQuestion/DiscreteNumeric]">
    <xsl:variable name="num_choices" select="count(EvalQuestion//choice)"/>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="QuestionGroup">
      <table class="QuestionGroup" cellpadding="4" cellspacing="0" border="{$border_size}">
        <tr>
          <!-- Header Row contains an element for every choice -->
          <th></th> <th></th>
          <xsl:for-each select="EvalQuestion//choice">
            <th class="group_choice"><xsl:apply-templates/></th>
          </xsl:for-each>
          <!-- ...and N/A if applicable. -->
          <xsl:if test=".//*[@na_available='yes']">
            <th class="group_choice">N/A</th>
          </xsl:if>
        </tr>
        <xsl:text>&#10;</xsl:text>
        <!-- Actually do the first element. -->
        <xsl:apply-templates select="EvalQuestion/MultipleChoice | EvalQuestion/MultipleResponse | EvalQuestion/DiscreteNumeric" 
          mode="inGroup"/>
        <!-- Then, do the rows for each QuestionRef. -->
        <xsl:for-each select="EvalQuestionRef/QuestionRef">
          <xsl:call-template name="choice_row">
            <xsl:with-param name="num_choices" select="$num_choices"/>
          </xsl:call-template>
        </xsl:for-each>
      </table>
    </div>
  </xsl:template>

  <!-- QuestionGroup headed by a NumericRating or PlusMinusRating -->
  <xsl:template match="QuestionGroup[EvalQuestion/NumericRating or EvalQuestion/PlusMinusRating]">
    <xsl:variable name="num_steps" select=".//@num_steps"/>
    <xsl:variable name="show_numbers" select=".//@show_numbers"/>
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="QuestionGroup">
      <table class="QuestionGroup" cellpadding="4" cellspacing="0" border="{$border_size}">
        <tr>
          <!-- Header has three elements: low_text, mid_text, and high_text -->
          <th></th> <th></th>
          <th class="group_choice" align="right">
            <xsl:value-of select=".//low_text"/>
            <img src="/icons/transdot.gif" width="12" height="1"/>
          </th>
          <th class="group_choice" colspan="{$num_steps - 2}" align="center">
            <xsl:value-of select=".//mid_text"/>
          </th>
          <th class="group_choice">
            <img src="/icons/transdot.gif" width="12" height="1"/>
            <xsl:value-of select=".//high_text"/>
          </th>
          <!-- ...and N/A if applicable. -->
          <xsl:if test=".//*[@na_available='yes']"><th class="group_choice">N/A</th></xsl:if>
        </tr>
        <xsl:text>&#10;</xsl:text>
        <!-- Actually do the NumericRating or PlusMinusRating -->
        <xsl:apply-templates select="EvalQuestion/NumericRating | EvalQuestion/PlusMinusRating"
          mode="inGroup"/>
        <!-- And then do all of the QuestionRef's. -->
        <xsl:for-each select="EvalQuestionRef/QuestionRef">
          <xsl:call-template name="choice_row">
            <xsl:with-param name="num_choices" select="$num_steps"/>
            <xsl:with-param name="spread">1</xsl:with-param>
            <xsl:with-param name="show_nums" select="$show_numbers = 'yes'"/>
          </xsl:call-template>
        </xsl:for-each>
      </table>    
    </div>
  </xsl:template>

  <xsl:template match="QuestionGroup[EvalQuestion/FillIn]">
    <xsl:param name="label"><xsl:value-of select="../question_label"/></xsl:param>
    <xsl:choose>
      <xsl:when test="$label = 'auto'">
		<li />
      </xsl:when>
    </xsl:choose>
    <div class="QuestionGroup">
      <table class="QuestionGroup" cellpadding="4" cellspacing="0" border="{$border_size}">
        <!-- Actually do the FillIn -->
        <xsl:apply-templates select="EvalQuestion/FillIn" mode="inGroup"/>
        <xsl:variable name="longtext" select="EvalQuestion/FillIn/@longtext"/>
        <!-- And then do all of the QuestionRef's. -->
        <xsl:for-each select="EvalQuestionRef/QuestionRef">
          <xsl:call-template name="text_row">
            <xsl:with-param name="longtext" select="$longtext"/>
          </xsl:call-template>
        </xsl:for-each>
      </table>
    </div>
  </xsl:template>

  <!-- Actually make a radio button or check box -->
  <xsl:template name="button">
    <!-- The question id to associate with -->
    <xsl:param name="qid"/>
    <!-- The value of this answer -->
    <xsl:param name="value"/>
    <!-- The answer that the user has previously given -->
    <xsl:param name="answer"/>
    <input value="{$value}">
      <!-- Type depends on whether we're in a Multiple Response or not -->
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="../../EvalQuestion/MultipleResponse">checkbox</xsl:when>
          <xsl:otherwise>radio</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- The name of this element is formed from the question id -->
      <xsl:attribute name="name">eval_q_<xsl:value-of select="$qid"/></xsl:attribute>
      <!-- onClick is used to make the red dot go away. -->
      <xsl:attribute name="onClick">satisfy(<xsl:value-of select="$qid"/>,'radio')</xsl:attribute>
      <!-- We indicate this question as answer if its checked. -->
      <xsl:if test="contains($answer, $value)">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
    </input>
  </xsl:template>

  <!-- Makes a bunch of <td> elements with choices in them. -->
  <xsl:template name="choice_cells">
    <!-- How many we're making -->
    <xsl:param name="num_choices"/>
    <!-- The question id -->
    <xsl:param name="qid"/>
    <!-- The answer that's actually been used. -->
    <xsl:param name="answer"/>
    <!-- Which number we're on right now -->
    <xsl:param name="choice_num"/>
    <!-- Whether we're spreading them out, like for a Rating question. -->
    <xsl:param name="spread">0</xsl:param>
    <xsl:param name="show_nums" select="false()"/>
    <td valign="top">
      <!-- Figure out how to align the cell information; if $spread, then the ends
           need to be aligned to the sides. -->
      <xsl:choose>
        <xsl:when test="$spread = 1 and $choice_num = 1">
          <xsl:attribute name="align">right</xsl:attribute>
        </xsl:when>
        <xsl:when test="$spread = 1 and $choice_num = $num_choices">
          <xsl:attribute name="align">left</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="align">center</xsl:attribute>          
        </xsl:otherwise>
      </xsl:choose>
      <!-- If we're spreading, then put in spacers. -->
      <xsl:if test="$spread = 1 and $choice_num &gt; 1">
        <img src="/icons/transdot.gif" width="12" height="1"/>
      </xsl:if>
      <!-- Create the button -->
      <xsl:if test="$show_nums">
        <span class="scale_text"><xsl:value-of select="$choice_num"/></span>
      </xsl:if>
      <xsl:call-template name="button">
        <xsl:with-param name="value"><xsl:number value="$choice_num" format="a"/></xsl:with-param>
        <xsl:with-param name="answer" select="$answer"/>
        <xsl:with-param name="qid" select="$qid"/>
      </xsl:call-template>
      <!-- If we're spreading, then put in spacers. -->
      <xsl:if test="$spread = 1 and $choice_num &lt; $num_choices">
        <img src="/icons/transdot.gif" width="12" height="1"/>
      </xsl:if>
    </td>
    <!-- Now, call ourselves again with an incremented choice_num. -->
    <xsl:if test="$choice_num &lt; $num_choices">
      <xsl:call-template name="choice_cells">
        <xsl:with-param name="num_choices" select="$num_choices"/>
        <xsl:with-param name="qid" select="$qid"/>
        <xsl:with-param name="answer" select="$answer"/>
        <xsl:with-param name="choice_num" select="$choice_num + 1"/>
        <xsl:with-param name="spread" select="$spread"/>
        <xsl:with-param name="show_nums" select="$show_nums"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Set up an entire choice row. -->
  <xsl:template name="choice_row">
    <xsl:param name="num_choices"/>
    <xsl:param name="spread">0</xsl:param>
    <xsl:param name="show_nums" select="false()"/>
    <xsl:variable name="qid" select="../@eval_question_id"/>
    <xsl:variable name="answer" 
      select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <tr>
      <td align="right"><xsl:call-template name="dot_and_label"/></td>
      <td align="left"><xsl:apply-templates select="question_text"/></td>
      <xsl:call-template name="choice_cells">
        <xsl:with-param name="num_choices" select="$num_choices"/>
        <xsl:with-param name="qid" select="$qid"/>
        <xsl:with-param name="answer" select="$answer"/>
        <xsl:with-param name="choice_num">1</xsl:with-param>
        <xsl:with-param name="spread" select="$spread"/>
        <xsl:with-param name="show_nums" select="$show_nums"/>
      </xsl:call-template>
      <xsl:if test="@na_available='yes'">
        <td align="center" valign="top">
          <xsl:call-template name="button">
            <xsl:with-param name="value"><xsl:number value="$num_choices + 1" format="a"/></xsl:with-param>
            <xsl:with-param name="answer"><xsl:value-of select="$answer"/></xsl:with-param>
            <xsl:with-param name="qid"><xsl:value-of select="$qid"/></xsl:with-param>
          </xsl:call-template>
        </td>
      </xsl:if>
    </tr>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="textbox">
    <xsl:param name="qid"/>
    <xsl:param name="answer"/>
    <input onChange="satisfy({$qid},'text')" type="text" size="50" name="eval_q_{$qid}" value="{$answer}"/>
  </xsl:template>

  <xsl:template name="textarea">
    <xsl:param name="qid"/>
    <xsl:param name="answer"/>
    <textarea onChange="satisfy({$qid},'text')" rows="5" cols="50" name="eval_q_{$qid}">
      <xsl:value-of select="$answer"/>
    </textarea>
  </xsl:template>

  <xsl:template name="text_row">
    <xsl:param name="longtext" select="no"/>
    <xsl:variable name="qid" select="../@eval_question_id"/>
    <xsl:variable name="answer" 
      select="document($answerXml)/EvalAnswers/eval_answer[@qid=$qid]"/>
    <xsl:comment> Question ID : <xsl:value-of select="$qid" /></xsl:comment>
    <xsl:text>&#10;</xsl:text>
    <tr>
      <td valign="top" align="right"><xsl:call-template name="dot_and_label"/></td>
      <td valign="top" align="left"><xsl:apply-templates select="question_text"/></td>
      <td valign="top" align="left">
        <xsl:choose>
          <xsl:when test="$longtext='yes'">
            <xsl:call-template name="textarea">
              <xsl:with-param name="qid" select="$qid"/>
              <xsl:with-param name="answer" select="$answer"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="textbox">
              <xsl:with-param name="qid" select="$qid"/>
              <xsl:with-param name="answer" select="$answer"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <!-- Do the YesNo -->
  <xsl:template match="YesNo" mode="inGroup">
    <xsl:call-template name="choice_row">
      <xsl:with-param name="num_choices">2</xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Do the MultipleChoice or MultipleResponse -->
  <xsl:template match="MultipleChoice|MultipleResponse|DiscreteNumeric" mode="inGroup">
    <xsl:call-template name="choice_row">
      <xsl:with-param name="num_choices" select="count(choice)"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Do the NumericRating or PlusMinusRating -->
  <xsl:template match="NumericRating|PlusMinusRating" mode="inGroup">
    <xsl:call-template name="choice_row">
      <xsl:with-param name="num_choices" select="@num_steps"/>
      <xsl:with-param name="spread">1</xsl:with-param>
      <xsl:with-param name="show_nums" select="@show_numbers = 'yes'"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Do the FillIn -->
  <xsl:template match="FillIn" mode="inGroup">
    <xsl:call-template name="text_row">
      <xsl:with-param name="longtext" select="@longtext"/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
