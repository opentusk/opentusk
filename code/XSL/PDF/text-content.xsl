<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">

<xsl:template match="db-content">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
                <fo:layout-master-set>
                   <fo:simple-page-master master-name="doc"
		                     page-height="300mm" 
		                     page-width="210mm"
		                     margin-top="25.4mm" 
		                     margin-bottom="15.4mm" 
		                     margin-left="31.75mm" 
                		     margin-right="19.05mm">
                		 <fo:region-before extent="15mm"/>
                		 <fo:region-after extent="10mm"/>
				<fo:region-body margin-top="20mm" margin-bottom="12mm"/>
			</fo:simple-page-master>
	
		</fo:layout-master-set>
		<!--Body dim Width = 170mm Height 225mm-->
		<fo:page-sequence master-name="doc">
			<fo:static-content flow-name="xsl-region-before">
				<fo:block text-align="center"><xsl:value-of select="@course"/>: <xsl:value-of select="@title"/></fo:block>
			</fo:static-content>
			<fo:static-content flow-name="xsl-region-after">
				<fo:block font-size="12pt" text-align="center"><fo:page-number/></fo:block>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
			<xsl:apply-templates/>
			</fo:flow>
		 </fo:page-sequence>
		
	</fo:root>
</xsl:template>

<xsl:template match="section-level-1">	
	<fo:block font-size="20pt" color="#6699CC" space-after="1mm" space-before="1mm"><xsl:number format="1. "/><xsl:value-of select="descendant::section-title"/></fo:block>
	<fo:block start-indent="1cm">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="section-level-2">	
	<fo:block font-size="18pt" color="#6699CC" space-after="1mm" space-before="1mm"><xsl:number format="1. " level="multiple" count="section-level-1|section-level-2"/><xsl:value-of select="descendant::section-title"/></fo:block>
	<fo:block start-indent="2cm">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="section-level-3">	
	<fo:block font-size="16pt" color="#6699CC" space-after="1mm" space-before="1mm"><xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3"/><xsl:value-of select="descendant::section-title"/></fo:block>
	<fo:block start-indent="2cm">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="section-level-4">	
	<fo:block font-size="14pt" color="#6699CC" space-after="1mm" space-before="1mm"><xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4"/><xsl:value-of select="descendant::section-title"/></fo:block>
	<fo:block start-indent="2cm">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="section-level-5">	
	<fo:block font-size="12pt" color="#6699CC" space-after="1mm" space-before="1mm"><xsl:number format="1. " level="multiple" count="section-level-1|section-level-2|section-level-3|section-level-4|section-level-5"/><xsl:value-of select="descendant::section-title"/></fo:block>
	<fo:block start-indent="2cm">
		<xsl:apply-templates/>
	</fo:block>
</xsl:template>

<xsl:template match="section-title"/>
<xsl:template match="itemized-list">
	<fo:list-block>
		<xsl:for-each select="list-item">
			<fo:list-item>
				<fo:list-item-label>
					<fo:block>**</fo:block>
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

<xsl:template match="enumerated-list">
	<fo:list-block space-before="2mm" space-after="2mm">
		<xsl:for-each select="list-item">
			<fo:list-item>
				<fo:list-item-label>
					<xsl:choose>
						<xsl:when test="count(ancestor::enumerated-list) &gt; 1">
							<fo:block><xsl:number format="A. "/></fo:block>
						</xsl:when>
						<xsl:otherwise>
							<fo:block><xsl:number format="1. "/></fo:block>
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

<xsl:template match="hsdb-graphic"/>

<xsl:template match="para">
	<fo:block space-before="2mm" space-after="2mm"><xsl:apply-templates/></fo:block>
</xsl:template>

<xsl:template match="emph">
	<fo:inline text-decoration="underline"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="species">
	<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="sub">
	<fo:inline font-size="10pt" vertical-align="sub"><xsl:apply-templates/></fo:inline>
</xsl:template>

<xsl:template match="table"/>
	

<xsl:template match="tr"/>
<xsl:template match="td"/>

</xsl:stylesheet>
