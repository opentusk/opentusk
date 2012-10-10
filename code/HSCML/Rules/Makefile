INDEX = index.xml
XSLT = xsltproc
XSLTOPTS =

all: index.html hsdbdtds.cat

index.html: $(INDEX) dtdlist.xsl
	$(XSLT) $(XSLTOPTS) dtdlist.xsl $(INDEX) > $@

hsdbdtds.cat: $(INDEX) catalog.xsl
	$(XSLT) $(XSLTOPTS) catalog.xsl $(INDEX) > $@

clean:
	rm index.html hsdbdtds.cat

