<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <xsl:output method="html"/>

  <xsl:include href="eval.xsl"/>
  
  <xsl:template match="Eval">
    <html>
      <head>
        <title><xsl:value-of select="eval_title"/></title><xsl:text>&#10;</xsl:text>
        <xsl:comment>Eval ID: <xsl:value-of select="@school"/> <xsl:value-of select="@eval_id"/></xsl:comment><xsl:text>&#10;</xsl:text>
        <xsl:comment>Course: <xsl:value-of select="document($courseXml)/course/title"/> (<xsl:value-of select="@course_id"/>)</xsl:comment><xsl:text>&#10;</xsl:text>
        <xsl:comment>Time Period ID: <xsl:value-of select="@time_period_id"/></xsl:comment><xsl:text>&#10;</xsl:text>
        <xsl:comment>Available Date: <xsl:value-of select="available_date"/></xsl:comment><xsl:text>&#10;</xsl:text>
        <xsl:comment>Prelim Due Date: <xsl:value-of select="prelim_due_date"/></xsl:comment><xsl:text>&#10;</xsl:text>
        <xsl:comment>Due Date: <xsl:value-of select="due_date"/></xsl:comment><xsl:text>&#10;</xsl:text>
        <link rel="stylesheet" type="text/css" href="style/eval.css" title="HSDBEval"/><xsl:text>&#10;</xsl:text>
        <script type="text/javascript">
          <xsl:comment>
function satisfy(qid) {
  var imgname="flag_"+qid;
  if (document.images) {
    document.images[imgname].src = "/icons/transdot.gif";
  }
  return true;
}
//</xsl:comment>
        </script>
        <xsl:text>&#10;</xsl:text>
        <xsl:comment>Saved Answers</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="document($answerXml)/EvalAnswers/eval_answer"/>
      </head>
      <body>
        <xsl:call-template name="InfoBox"/>
        <form>
          <xsl:apply-templates/>
        </form>
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>