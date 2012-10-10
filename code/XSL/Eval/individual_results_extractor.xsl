<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/Eval_Results">
    <IndividualResults eval_id="{@eval_id}" school="{@school}" user_code="{$USERCODE}">
      <xsl:for-each select="Question_Results">
        <xsl:variable name="response" select="ResponseGroup/Response[@user_token=$USERCODE]"/>
        <xsl:text>
</xsl:text>
        <Response eval_question_id="{@eval_question_id}"><xsl:value-of select="$response"/></Response>
      </xsl:for-each>
        <xsl:text>
</xsl:text>
    </IndividualResults>
  </xsl:template>
</xsl:stylesheet>
