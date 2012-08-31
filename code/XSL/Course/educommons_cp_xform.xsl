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
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:md="http://www.imsglobal.org/xsd/imsmd_v1p2"
    xmlns:cp="http://www.imsglobal.org/xsd/imscp_v1p1"
    xmlns:ec="http://cosl.usu.edu/xsd/eduCommonsv1.1"
    xmlns:tmd="http://tusk.tufts.edu/xsd/tuskv0p1">
    
<xsl:output method="xml" indent="no"/>

<!-- ### used by organization and resource templates below ### -->
<xsl:variable name="objectives" select="/cp:manifest/cp:metadata/md:lom/md:classification/md:purpose/md:value/md:langstring[@xml:lang]"/>
<xsl:variable name="hasRole" select="/cp:manifest/cp:metadata/md:lom/md:lifecycle/md:contribute"/>

<!-- ### copy root node and all of its attributes ### -->
<xsl:template match="/cp:manifest">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates/>	
	</xsl:copy>
</xsl:template>

<!-- ### course-level metadata is ignored by eduCommons, so get rid of it. ### -->
<xsl:template match="cp:manifest/cp:metadata" />

<!-- ### add educommons metadata to each resource ### -->
<xsl:template match="cp:resource/cp:metadata">
	<cp:metadata>
		<xsl:apply-templates/>
		<ec:eduCommons>
			<ec:objectType>
				Document
			</ec:objectType>
			<ec:copyright>
				<xsl:value-of select="tmd:tom/tmd:copyright"/>
			</ec:copyright>
		</ec:eduCommons>
	</cp:metadata>	
</xsl:template>

<!-- ### add Tufts Univ. as educommons 'rights holder' for each resource ### -->
<xsl:template match="cp:resource/cp:metadata/md:lom/md:lifecycle">
	<md:lifecycle>
		<md:contribute>
			<md:role>
				<md:source>
					<md:langstring xml:lang="en">eduCommonsv1.1</md:langstring>
				</md:source>
				<md:value>	
					<md:langstring xml:lang="en">rights holder</md:langstring>
				</md:value>
			</md:role>
			<md:centity>
				<md:vcard>
begin:vcard
fn: Tufts University
end:vcard
				</md:vcard>
			</md:centity>
		</md:contribute>
		<xsl:apply-templates/>
	</md:lifecycle>
</xsl:template>

<!-- ### translate TUSK roles to IMS and eduCommons verbiage ### -->
<xsl:template match="cp:resource/cp:metadata/md:lom/md:lifecycle/md:contribute/md:role">
	<md:role>
		<xsl:choose>
			<xsl:when test="md:value/md:langstring = 'Author'">
				<md:source>
					<md:langstring xml:lang="en">LOMv1.0</md:langstring>
				</md:source>
				<md:value>
					<md:langstring xml:lang="en">
						creator
					</md:langstring>
				</md:value>
			</xsl:when>
			<xsl:when test="md:value/md:langstring = 'Editor'">
				<md:source>
					<md:langstring xml:lang="en">LOMv1.0</md:langstring>
				</md:source>
				<md:value>
					<md:langstring xml:lang="en">
						<xsl:value-of select="md:value/md:langstring"/>
					</md:langstring>
				</md:value>
			</xsl:when>
			<xsl:when test="md:value/md:langstring = 'Director'">
				<md:source>
					<md:langstring xml:lang="en">eduCommonsv1.1</md:langstring>
				</md:source>
				<md:value>
					<md:langstring xml:lang="en">
						Instructor
					</md:langstring>
				</md:value>
			</xsl:when>
			<xsl:otherwise>
				<md:source>
					<md:langstring xml:lang="en">eduCommonsv1.1</md:langstring>
				</md:source>
				<md:value>
					<md:langstring xml:lang="en">
						contributor
					</md:langstring>
				</md:value>
			</xsl:otherwise>
		</xsl:choose>
	</md:role>
</xsl:template>


<xsl:template match="cp:organizations">
	<cp:organizations>
		<xsl:apply-templates/>
	</cp:organizations>
</xsl:template>

<xsl:template match="cp:organization">
	<cp:organization>
		<xsl:attribute name="identifier">
			<xsl:value-of select="@identifier"/>
		</xsl:attribute>
		<xsl:apply-templates/>
		
<!-- ### 
WE CONVERT A LOT OF STUFF THAT IS STORED IN TUSK AS METADATA INTO ACTUAL RESOURCES
IN bin/educommons_cp_xform.pl. AS SUCH, WE NEED TO GENERATE ITEMS FOR THEM, TOO. 
### -->
		<xsl:if test="$objectives = 'Educational Objective'">
			<cp:item isvisible="true" identifier="itmObj" identifierref="resObj">
				<cp:title>Objectives</cp:title>	
			</cp:item>
		</xsl:if>
		<xsl:if test="$hasRole">
			<cp:item isvisible="true" identifier="itmFac" identifierref="resFac">
				<cp:title>Faculty List</cp:title>	
			</cp:item>
		</xsl:if>
<!-- ### tuskMetaData dynamically has items generated for it ### -->
		<xsl:for-each select="/cp:manifest/cp:metadata/tmd:tusk/tmd:tuskMetaData">
			<cp:item isvisible="true">
				<xsl:variable name="token" select="translate(@token, ' ABCDEFGHIJKLMNOPQRSTUVWXYZ', '_abcdefghijklmnopqrstuvwxyz')" />
				<xsl:attribute name="identifier">
					<xsl:value-of select="concat('itm', $token)" />
				</xsl:attribute>
				<xsl:attribute name="identifierref">
					<xsl:value-of select="concat('res', $token)" />
				</xsl:attribute>
				<cp:title>
					<xsl:value-of select="@title"/>
				</cp:title>
			</cp:item>
		</xsl:for-each>
	</cp:organization>
</xsl:template>


<!-- ### 
our item called 'content' needs to reference a resource that is the 
course home page containing links to all content 
### -->
<xsl:template match="cp:item[@identifier='content']">
	<cp:item identifier="content" identifierref="res_course_home" isvisible="true">
		<cp:title>
			<xsl:value-of select="cp:title"/>
		</cp:title>
		<xsl:apply-templates select="cp:item"/>	
	</cp:item> 
</xsl:template>


<xsl:template match="cp:item">
	<xsl:variable name="idRef" select="@identifierref"/>
	<xsl:variable name="resourceNode" select="/cp:manifest/cp:resources/cp:resource[@identifier=$idRef]"/>

<!-- ### 
remove items that are of content type = link 
AND make sure all content is invisible, otherwise, it will show in left
nav in educommons.
###-->
	<xsl:if test="$resourceNode/cp:metadata/tmd:tom/tmd:tuskType != 'URL'">
	<cp:item>
		<xsl:attribute name="identifier">
			<xsl:value-of select="@identifier"/>
		</xsl:attribute>
		<xsl:attribute name="identifierref">
			<xsl:value-of select="@identifierref"/>
		</xsl:attribute>
		<xsl:attribute name="isvisible">false</xsl:attribute>
		<xsl:apply-templates/> 
	</cp:item> 
	</xsl:if>
</xsl:template>


<xsl:template match="cp:title">
	<cp:title>
	<xsl:choose>
		<xsl:when test="string-length(.)">
			<xsl:value-of select="."/>
		</xsl:when>
		<xsl:otherwise>
			[no author-provided title]
		</xsl:otherwise>
	</xsl:choose>
	</cp:title>
</xsl:template>

<xsl:template match="md:title/md:langstring">
	<md:langstring>
	<xsl:choose>
		<xsl:when test="string-length(.)">
			<xsl:value-of select="."/>
		</xsl:when>
		<xsl:otherwise>
			[no author-provided title]
		</xsl:otherwise>
	</xsl:choose>
	</md:langstring>
</xsl:template>


<xsl:template match="cp:resources">
	<cp:resources>
		<cp:resource identifier="res_course_home" type="webcontent">
			<xsl:call-template name="genMetadata">
				<xsl:with-param name="title">Content</xsl:with-param>
				<xsl:with-param name="isCourse">true</xsl:with-param>
			</xsl:call-template>
			<cp:file href="course_home.html" />	
		</cp:resource>
	
		<xsl:apply-templates/>
		
	<!-- ### WE HAVE SOME METADATA THAT WE WANT TO CONVERT TO RESOURCES ### -->
		<xsl:if test="$objectives = 'Educational Objective'">
			<cp:resource identifier="resObj" type="webcontent">
				<xsl:call-template name="genMetadata">
					<xsl:with-param name="title">Objectives</xsl:with-param>
					<xsl:with-param name="isCourse">false</xsl:with-param>
				</xsl:call-template>
				<cp:file href="objectives.html" />	
			</cp:resource>
		</xsl:if>
		<xsl:if test="$hasRole">
			<cp:resource identifier="resFac" type="webcontent">
				<xsl:call-template name="genMetadata">
					<xsl:with-param name="title">Faculty List</xsl:with-param>
					<xsl:with-param name="isCourse">false</xsl:with-param>
				</xsl:call-template>
				<cp:file href="faculty_list.html" />	
			</cp:resource>
		</xsl:if>

		<xsl:for-each select="/cp:manifest/cp:metadata/tmd:tusk/tmd:tuskMetaData">
			<cp:resource type="webcontent">
				<xsl:variable name="token" select="translate(@token, ' ABCDEFGHIJKLMNOPQRSTUVWXYZ', '_abcdefghijklmnopqrstuvwxyz')" />
				<xsl:attribute name="identifier">
					<xsl:value-of select="concat('res', $token)" />
				</xsl:attribute>
				<xsl:call-template name="genMetadata">
					<xsl:with-param name="title"><xsl:value-of select="@title"/></xsl:with-param>
					<xsl:with-param name="isCourse">false</xsl:with-param>
				</xsl:call-template>
				<cp:file>
					<xsl:attribute name="href">
						<xsl:value-of select="concat($token, '.html')"/>
					</xsl:attribute>
				</cp:file>
			</cp:resource>
		</xsl:for-each>
	</cp:resources>
</xsl:template>


<xsl:template match="cp:resource">
	<!-- we don't want content of type "link" to have a resource, so remove them -->
	<xsl:if test="cp:metadata/tmd:tom/tmd:tuskType != 'URL'">
		<xsl:variable name="filename" select="cp:file/@href" />
		<xsl:if test="cp:file and not(contains($filename, 'xml'))">
			<xsl:call-template name="genResource">
				<xsl:with-param name="gen_xtra_resource" select="1" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(contains($filename, 'css'))">
			<xsl:call-template name="genResource"/>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="tmd:tom"/>

<xsl:template match="cp:file"/>



<!-- ##### named templates ##### -->
<xsl:template name="genResource">
	<!-- i might want to add 'res' to front of id for consistency -->
	<xsl:param name="gen_xtra_resource"></xsl:param>
	<xsl:variable name="id" select="@identifier" />

	<cp:resource type="webcontent">
		<xsl:attribute name="identifier">
			<xsl:choose>
				<xsl:when test="$gen_xtra_resource">
					<xsl:value-of select="generate-id()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="@href">
			<xsl:attribute name="href">
				<xsl:value-of select="@href"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="$gen_xtra_resource">
				<cp:file>
					<xsl:attribute name="href">
						<xsl:value-of select="cp:file/@href"/>
					</xsl:attribute>
				</cp:file>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="filename" select="concat(substring($id, 4),'.html')"/>
				<cp:file>
					<xsl:attribute name="href">
						<xsl:value-of select="$filename"/>
					</xsl:attribute>
				</cp:file>
			</xsl:otherwise>
		</xsl:choose>
	</cp:resource>
</xsl:template>


<xsl:template name="genMetadata">
	<xsl:param name="isCourse">0</xsl:param>
	<xsl:param name="title"></xsl:param>
	<cp:metadata>
		<lom xmlns="http://www.imsglobal.org/xsd/imsmd_v1p2">
			<general>
				<title>
					<langstring xml:lang="en">
						<xsl:value-of select="$title"/>
					</langstring>
				</title>
				<language>en</language>
			</general>
			<lifecycle>
				<contribute>
					<role>
						<source>
							<langstring xml:lang="en">eduCommonsv1.1</langstring>
						</source>
						<value>
							<langstring xml:lang="en">rights holder</langstring>
						</value>
					</role>
					<centity>
						<vcard>
begin:vcard
fn: Tufts University
end:vcard
						</vcard>
					</centity>
				</contribute>
			</lifecycle>
		</lom>
		<eduCommons xmlns="http://cosl.usu.edu/xsd/eduCommonsv1.1">
		<xsl:choose>
			<xsl:when test="$isCourse = 'true'">
			<objectType>Course</objectType>
			</xsl:when>
			<xsl:otherwise>
			<objectType>Document</objectType>
			</xsl:otherwise>
		</xsl:choose>
		</eduCommons>
	</cp:metadata>
</xsl:template>


<!--
to blatantly copy anything not mentioned above
-->
<xsl:template match="*|@*|text()">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|text()"/>	
	</xsl:copy>
</xsl:template>


</xsl:stylesheet>
