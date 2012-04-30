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
