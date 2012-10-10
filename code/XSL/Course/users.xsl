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
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:template match="course">
        <h3 class="title">Faculty List</h3>
        <table>
	    <tr>
	        <td><xsl:apply-templates select="./faculty-list"/></td>
	    </tr>
	</table>
    </xsl:template>

    <xsl:template match="faculty-list">
        <xsl:if test="descendant::course-user">
            <table>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">Director</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">Lecturer</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">Author</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">Instructor</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">LabInstructor</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">Librarian</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="faculty-group">
	            <xsl:with-param name="facultyGroup">MERCRepresentative</xsl:with-param>
                </xsl:call-template>
	    </table>
	</xsl:if>
    </xsl:template>

    <xsl:template name="faculty-group">
        <xsl:variable name="userLink">/view/user/</xsl:variable>
	<xsl:if test="descendant::course-user/course-user-role/@role=$facultyGroup">
	    <tr>
	        <td>
                    <ul>
	                <lh><h4 class="title"><xsl:value-of select="$facultyGroup"/><xsl:text>s</xsl:text></h4></lh>
	                <xsl:for-each select="./course-user">
	                    <xsl:if test="descendant::course-user-role/@role=$facultyGroup">
	                        <li><b><a href="{$userLink}{@user-id}"><xsl:value-of select="@name"/></a></b></li>
		            </xsl:if>
	                </xsl:for-each>
	            </ul>
	        </td>
	    </tr>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>
