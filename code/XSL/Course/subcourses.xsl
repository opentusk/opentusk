<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <h3 class="title">Sub Courses</h3>
        <xsl:apply-templates select="./sub-course-list"/>
    </xsl:template>

    <xsl:template match="sub-course-list">
        <xsl:variable name="subCourseLink">/hsdb45/course</xsl:variable>
	<xsl:if test="descendant::sub-course">
            <ul>
	        <xsl:for-each select="./sub-course">
	            <li>
		        <b>
		            <a href="{$subCourseLink}/{parent::sub-course-list/parent::course/@school}/{@course-id}">
			        <xsl:value-of select="."/>
			    </a>
		        </b>
		    </li>
	        </xsl:for-each>
	    </ul>
	</xsl:if>  
    </xsl:template>
</xsl:stylesheet>
