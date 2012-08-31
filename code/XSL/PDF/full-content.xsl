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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
	<xsl:template match="db-content">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
			<fo:layout-master-set>
				<fo:simple-page-master master-name="rest-pages" page-height="279.4mm" page-width="215.9mm" margin-top="12mm" margin-bottom="0mm" margin-left="31.75mm" margin-right="19.05mm">
					<fo:region-before extent="13.4mm"/>
					<fo:region-after extent="13.4mm"/>
					<fo:region-body margin-top="12mm" margin-bottom="18mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="first-page" page-height="279.4mm" page-width="215.9mm" margin-top="12mm" margin-bottom="0mm" margin-left="31.75mm" margin-right="19.05mm">
					<fo:region-before extent="13.4mm" region-name="first-region-before"/>
					<fo:region-after extent="13.4mm"/>
					<fo:region-body margin-top="12mm" margin-bottom="18mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="basic">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="first" master-reference="first-page"/>
						<fo:conditional-page-master-reference page-position="rest" master-reference="rest-pages"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
			</fo:layout-master-set>
			<!--Body dim Width = 170mm Height 225mm-->
			<fo:page-sequence master-reference="basic">
				<fo:static-content flow-name="first-region-before">
					<fo:block font-size="12pt" font-family="serif" text-align="center">
						<xsl:value-of select="@course"/>: <fo:inline font-size="18pt">
							<xsl:value-of select="@title"/>
						</fo:inline>
					</fo:block>
				</fo:static-content>
				<fo:static-content flow-name="xsl-region-before">
					<fo:block font-size="12pt" font-family="serif" text-align="center">
						<xsl:value-of select="@course"/>: <xsl:value-of select="@title"/>
					</fo:block>
				</fo:static-content>
				<fo:static-content flow-name="xsl-region-after">
					<fo:block font-size="12pt" font-family="serif" text-align="center">
						<fo:page-number/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:apply-templates/>
				</fo:flow>
			</fo:page-sequence>
		</fo:root>
	</xsl:template>
	<xsl:template match="section-level-1">
		<fo:block font-size="17pt" color="#000000" space-after="1mm" space-before="1mm">
			<xsl:number format="1. "/>
			<xsl:value-of select="descendant::section-title"/>
		</fo:block>
		<fo:block start-indent="5mm" font-family="serif" font-size="10pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="section-level-2">
		<fo:block font-size="16pt" color="#000000" space-after="1mm" space-before="1mm">
			<xsl:number format="1. " level="multiple" count="section-level-1|section-level-2"/>
			<xsl:value-of select="descendant::section-title"/>
		</fo:block>
		<fo:block start-indent="5mm" font-family="serif" font-size="10pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="section-level-3">
		<fo:block font-size="15pt" color="#000000" space-after="1mm" space-before="1mm">
			<xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3"/>
			<xsl:value-of select="descendant::section-title"/>
		</fo:block>
		<fo:block start-indent="5mm" font-family="serif" font-size="10pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="section-level-4">
		<fo:block font-size="14pt" color="#000000" space-after="1mm" space-before="1mm">
			<xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4"/>
			<xsl:value-of select="descendant::section-title"/>
		</fo:block>
		<fo:block start-indent="5mm" font-family="serif" font-size="10pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="section-level-5">
		<fo:block font-size="13pt" color="#000000" space-after="1mm" space-before="1mm">
			<xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5"/>
			<xsl:value-of select="descendant::section-title"/>
		</fo:block>
		<fo:block start-indent="5mm" font-family="serif" font-size="10pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="section-title"/>
	<xsl:template match="itemized-list">
		<fo:list-block>
			<xsl:for-each select="list-item">
				<fo:list-item>
					<fo:list-item-label>
						<xsl:choose>
							<xsl:when test="count(ancestor::itemized-list) &gt; 2">
								<fo:block>
									<fo:inline font-family="LucidaSansUnicode" font-size="75%">&#x25A0;</fo:inline>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::itemized-list) &gt; 1">
								<fo:block>
									<fo:inline font-family="LucidaSansUnicode" font-size="75%">&#x25CB;</fo:inline>
								</fo:block>
							</xsl:when>
							<xsl:otherwise>
								<fo:block>
									<fo:inline font-family="LucidaSansUnicode" font-size="75%">&#x25CF;</fo:inline>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block>
							<xsl:apply-templates/>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</xsl:for-each>
		</fo:list-block>
	</xsl:template>
	<xsl:template match="definition-list">
		<xsl:for-each select="definition-term|definition-data">
			<xsl:choose>
				<xsl:when test="name() = 'definition-term'">
					<fo:block>
						<fo:inline font-family="LucidaSansUnicode" font-size="75%">&#x25CF;</fo:inline>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block start-indent="10mm">
						<fo:inline font-family="LucidaSansUnicode" font-size="75%">&#x25CF;</fo:inline>
						<xsl:apply-templates/>
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="enumerated-list">
		<fo:list-block space-before="2mm" space-after="2mm">
			<xsl:for-each select="list-item">
				<fo:list-item>
					<fo:list-item-label>
						<xsl:choose>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 7">
								<fo:block>
									<xsl:number format="(a). "/>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 6">
								<fo:block>
									<xsl:number format="(i). "/>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 5">
								<fo:block>
									<xsl:number format="(A). "/>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 4">
								<fo:block>
									<xsl:number format="(1). "/>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 3">
								<fo:block>
									<xsl:number format="a. "/>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 2">
								<fo:block>
									<xsl:number format="i. "/>
								</fo:block>
							</xsl:when>
							<xsl:when test="count(ancestor::enumerated-list) &gt; 1">
								<fo:block>
									<xsl:number format="A. "/>
								</fo:block>
							</xsl:when>
							<xsl:otherwise>
								<fo:block>
									<xsl:number format="1. "/>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block>
							<xsl:apply-templates/>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</xsl:for-each>
		</fo:list-block>
	</xsl:template>
	<xsl:template match="hsdb-graphic">
	
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="@width &gt; 300">
					<xsl:text>300px</xsl:text>
				</xsl:when>
				<xsl:when test="@height &gt; 300">
					<xsl:value-of select="(@width div @height) * 300"/><xsl:text>px</xsl:text>
				</xsl:when>				
				<xsl:otherwise>
					<xsl:value-of select="@width"></xsl:value-of><xsl:text>px</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="height">
			<xsl:if test="@width &lt; 300">		
				<xsl:choose>
					<xsl:when test="@height &gt;300">
						<xsl:text>300px</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@height"></xsl:value-of><xsl:text>px</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="@width &gt; 299">
				<xsl:value-of select="(@height div @width) * 300"/><xsl:text>px</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@image-class='thumb'">
				<fo:block>
					<fo:external-graphic src="http://tusk.tufts.edu/thumb/{@content-id}" height="{$height}" width="{$width}"/>
				</fo:block>
			</xsl:when>
			<xsl:when test="@image-class='half'">
				<xsl:choose>
					<xsl:when test="count(ancestor::table) &gt; 0">
						<fo:block>
							<fo:external-graphic src="http://tusk.tufts.edu/medium/{@content-id}" height="{$height}" width="{$width}"/>
						</fo:block>
					</xsl:when>
					<!-- if this isn't in a table, put it in one that's limited to 360 pixels wide -->
					<xsl:otherwise>
						<fo:block>
							<fo:table>
								<fo:table-column column-width="360px"/>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell>
											<fo:block>
												<fo:external-graphic src="http://tusk.tufts.edu/medium/{@content-id}" height="{$height}" width="{$width}"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<fo:external-graphic src="http://tusk.tufts.edu/large/{@content-id}" height="{$height}" width="{$width}"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="para">
		<fo:block font-size="10pt" space-before="2mm" space-after="2mm">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="emph">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="keyword|nugget|summary|topic-sentence|umls-concept|objective-item">
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="species">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="tbody">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="thead">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="foreign">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="sub">
		<fo:inline font-size="10pt" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="strong">
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="warning">
		<fo:inline font-weight="bold" font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="pagebreak">
		<fo:block break-after="page"/>
	</xsl:template>
	<xsl:template match="linebreak">
		<fo:block/>
	</xsl:template>
	<xsl:template name="print-column-width">
		<xsl:param name="width"/>
		<xsl:param name="colwidth">50</xsl:param>
		<xsl:variable name="coltempwidth">
			<xsl:choose>
				<xsl:when test="($width and contains($width,'%'))">
					<xsl:value-of select="(160 div 100) * format-number(substring($width,1,string-length	($width)-1),'#0.00')"/>
					<xsl:text>mm</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$colwidth"/>
					<xsl:text>mm</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:table-column column-width="{$coltempwidth}"/>
	</xsl:template>
	<xsl:template match="table">
		<xsl:variable name="border" select="@border*.1"/>
		<fo:block space-before="2mm" space-after="2mm">
			<fo:table keep-with-previous="always" table-omit-header-at-break="false" table-layout="fixed" width="160mm">
				<xsl:variable name="numbercol-td">
					<xsl:for-each select="tr">
						<xsl:sort select="count(td)" order="descending" data-type="number"/>
						<xsl:if test="position() = 1">
							<xsl:value-of select="count(td)"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="numbercol-th">
					<xsl:for-each select="tr">
						<xsl:sort select="count(th)" order="descending" data-type="number"/>
						<xsl:if test="position() = 1">
							<xsl:value-of select="count(th)"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="numbercol">
					<xsl:choose>
						<xsl:when test="$numbercol-th &gt; $numbercol-td">
							<xsl:value-of select="$numbercol-th"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numbercol-td"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="colwidth" select="160 div $numbercol"/>
				<xsl:if test="$numbercol = $numbercol-th">
					<xsl:for-each select="tr">
						<xsl:sort select="count(th)" order="descending" data-type="number"/>
						<xsl:if test="position() = 1">
							<xsl:for-each select="th">
								<xsl:call-template name="print-column-width">
									<xsl:with-param name="width" select="@width"/>
									<xsl:with-param name="colwidth" select="$colwidth"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$numbercol = $numbercol-td">
					<xsl:for-each select="tr">
						<xsl:sort select="count(td)" order="descending" data-type="number"/>
						<xsl:if test="position() = 1">
							<xsl:for-each select="td">
								<xsl:call-template name="print-column-width">
									<xsl:with-param name="width" select="@width"/>
									<xsl:with-param name="colwidth" select="$colwidth"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<fo:table-header>
					<xsl:for-each select="tr">
						<fo:table-row keep-together="always">
							<xsl:for-each select="th">
								<xsl:variable name="colspan">
									<xsl:if test="@colspan">
										<xsl:value-of select="@colspan"/>
									</xsl:if>
									<xsl:if test="not(@colspan)">1</xsl:if>
								</xsl:variable>
								<fo:table-cell background-color="#ccccff" text-align="center" number-columns-spanned="{$colspan}" border-width="{$border}mm" border-style="solid" border-color="rgb(0,0,0)">
									<fo:block hyphenate="true" language="en" font-size="10pt" space-before="0.5mm" space-after="0.5mm">
										<xsl:apply-templates/>
									</fo:block>
								</fo:table-cell>
							</xsl:for-each>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-header>
				<fo:table-body>
					<xsl:for-each select="tr">
						<xsl:if test="not(th)">
							<xsl:if test="position() &lt; 3">
								<fo:table-row keep-together="always" keep-with-previous="always">
									<xsl:for-each select="td">
										<xsl:variable name="colspan">
											<xsl:if test="@colspan">
												<xsl:value-of select="@colspan"/>
											</xsl:if>
											<xsl:if test="not(@colspan)">1</xsl:if>
										</xsl:variable>
										<xsl:variable name="rowspan">
											<xsl:if test="@rowspan">
												<xsl:value-of select="@rowspan"/>
											</xsl:if>
											<xsl:if test="not(@rowspan)">1</xsl:if>
										</xsl:variable>
										<xsl:variable name="text-align">
											<xsl:if test="@align">
												<xsl:value-of select="@align"/>
											</xsl:if>
											<xsl:if test="not(@align)">left</xsl:if>
										</xsl:variable>
										<xsl:variable name="v-align">
											<xsl:if test="@valign">
												<xsl:value-of select="@valign"/>
											</xsl:if>
											<xsl:if test="not(@valign)">top</xsl:if>
										</xsl:variable>
										<fo:table-cell text-align="{$text-align}" border-width="{$border}mm" number-rows-spanned="{$rowspan}" number-columns-spanned="{$colspan}" border-style="solid" border-color="rgb(0,0,0)">
											<fo:block start-indent="0mm" space-before="2mm" space-after="2mm">
												<fo:block hyphenate="true" language="en" start-indent="2mm">
													<xsl:apply-templates/>
												</fo:block>
											</fo:block>
										</fo:table-cell>
									</xsl:for-each>
								</fo:table-row>
							</xsl:if>
							<xsl:if test="position() &gt; 2">
								<fo:table-row keep-together="always">
									<xsl:for-each select="td">
										<xsl:variable name="colspan">
											<xsl:if test="@colspan">
												<xsl:value-of select="@colspan"/>
											</xsl:if>
											<xsl:if test="not(@colspan)">1</xsl:if>
										</xsl:variable>
										<xsl:variable name="rowspan">
											<xsl:if test="@rowspan">
												<xsl:value-of select="@rowspan"/>
											</xsl:if>
											<xsl:if test="not(@rowspan)">1</xsl:if>
										</xsl:variable>
										<xsl:variable name="text-align">
											<xsl:if test="@align">
												<xsl:value-of select="@align"/>
											</xsl:if>
											<xsl:if test="not(@align)">left</xsl:if>
										</xsl:variable>
										<xsl:variable name="v-align">
											<xsl:if test="@valign">
												<xsl:value-of select="@valign"/>
											</xsl:if>
											<xsl:if test="not(@valign)">top</xsl:if>
										</xsl:variable>
										<fo:table-cell text-align="{$text-align}" border-width="{$border}mm" number-rows-spanned="{$rowspan}" number-columns-spanned="{$colspan}" border-style="solid" border-color="rgb(0,0,0)">
											<fo:block start-indent="0mm" space-before="2mm" space-after="2mm">
												<fo:block hyphenate="true" language="en" hyphenation-push-character-count="2" hyphenation-remain-character-count="2" start-indent="2mm">
													<xsl:apply-templates/>
												</fo:block>
											</fo:block>
										</fo:table-cell>
									</xsl:for-each>
								</fo:table-row>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<xsl:template match="tr"/>
	<xsl:template match="td"/>
	<xsl:template match="special-char">
		<fo:inline font-family="{@font}">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
</xsl:stylesheet>
