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
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">


<xsl:template match="COLLECTION">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
                <fo:layout-master-set>
                   <fo:simple-page-master master-name="slides"
		                     page-height="300mm" 
		                     page-width="210mm"
		                     margin-top="13mm" 
		                     margin-bottom="13mm" 
		                     margin-left="20mm" 
                		     margin-right="20mm">
                		 <fo:region-before extent="7mm"/>
                		 <fo:region-after extent="7mm"/>
				<fo:region-body margin-top="13mm" margin-bottom="13mm"/>
			</fo:simple-page-master>
	
		</fo:layout-master-set>
		<!--Body dim Width = 170mm Height 225mm-->
		<fo:page-sequence master-reference="slides">
			<fo:static-content flow-name="xsl-region-before">
				<fo:table background-color="rgb(214, 226, 234)" table-layout="fixed">
				<fo:table-column column-width="20mm"/>
				<fo:table-column column-width="75mm"/>
				<fo:table-column column-width="75mm"/>
				<fo:table-body>
					<fo:table-row>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(214, 226, 234)" text-align="center" number-rows-spanned="2">
					</fo:table-cell>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(214, 226, 234)">
						<fo:block font-size="6pt">
							Tufts OpenCourseWare
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(214, 226, 234)" text-align="end" number-columns-spanned="2">
						<fo:block font-size="6pt" font-style="italic">
							<xsl:value-of select="@COPYRIGHT"/>
						</fo:block>
					</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(214, 226, 234)" number-columns-spanned="2">
						<fo:block font-size="6pt">
							<xsl:value-of select="@NAME"/>
						</fo:block>
					</fo:table-cell> 
					</fo:table-row>
				</fo:table-body>
				</fo:table>
			</fo:static-content>
			<fo:static-content flow-name="xsl-region-after">
				<fo:table background-color="rgb(214, 226, 234)" table-layout="fixed">
				<fo:table-column column-width="85mm"/>
				<fo:table-column column-width="85mm"/>
				<fo:table-body>
					<fo:table-row>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(214, 226, 234)">
						<fo:block font-size="6pt">
							<xsl:value-of select="@COURSE"/> (<xsl:value-of select="@AUTHOR"/>)
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(214, 226, 234)" text-align="end">
						<fo:block font-size="6pt">
							Page - <fo:page-number/>
						</fo:block>
					</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
				</fo:table>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
			<fo:table table-layout="fixed" border-width="2mm" border-style="solid" border-color="rgb(255,255,255)">
				<fo:table-column column-width="7mm"/>
				<fo:table-column column-width="163mm"/>
				<fo:table-body>
<xsl:for-each select="SLIDE">
		<fo:table-row height="10mm">
		<fo:table-cell>
			<fo:block>
				<xsl:value-of select="position()"/>.
			</fo:block>
		</fo:table-cell>
		<fo:table-cell height="10mm" text-align="center">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
		</fo:table-row>
		<fo:table-row height="120mm" keep-with-previous="always">
		<fo:table-cell number-columns-spanned="2" text-align="center"  border-width="1mm" border-style="solid" border-color="rgb(255,255,255)">
		<fo:block>
			<fo:external-graphic height= "100mm" src="{@SRC}"/>
		</fo:block>
		</fo:table-cell>
		</fo:table-row>
</xsl:for-each>
				</fo:table-body>
			</fo:table>
			</fo:flow>
		 </fo:page-sequence>
		
	</fo:root>
</xsl:template>
</xsl:stylesheet>
