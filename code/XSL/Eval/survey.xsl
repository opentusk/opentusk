<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="html" encoding="iso-8859-1"/>

  <xsl:template match="Survey">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="survey_title|start_date|stop_date"/>

  <xsl:include href="eval.xsl"/>

</xsl:stylesheet>
