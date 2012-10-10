<?xml version="1.0"?>
<!DOCTYPE MACROS SYSTEM "macros.dtd">
 
<MACROS> 
<MACRO name="On_Before_Document_Save" hide="true" lang="JScript"><![CDATA[
if (ActiveDocument.ViewType != sqViewNormal && ActiveDocument.ViewType != sqViewTagsOn) {
  Application.Alert("Unable to set the last modified date.\nSave in Tags On or Normal view to update this element.");
}
else if (!ActiveDocument.IsXML) {
  Application.Alert("Unable to set the last modified date because document is not XML.");
}
else {
  InsertLastModifiedDate();
}
]]></MACRO> 

<MACRO name="On_Before_Document_SaveAs" hide="true" lang="JScript"><![CDATA[
if (ActiveDocument.ViewType != sqViewNormal && ActiveDocument.ViewType != sqViewTagsOn) {
  Application.Alert("Must save in Tags On or Normal view to generate Last Modified Date.");
}
else if (!ActiveDocument.IsXML) {
  Application.Alert("Cannot generate Last Modified Date because document is not XML.");
}
else {
  InsertLastModifiedDate();
}
]]></MACRO> 

<MACRO name="Insert Abstract" key="" lang="JScript" id="1303" tooltip="Insert Abstract" desc="Insert Abstract"><![CDATA[


function doInsertAbstract() {
  // See if abstract already present
  var abstracts = ActiveDocument.getElementsByTagName("Abstract");
  if (abstracts.length > 0) {
    Application.Alert("Article already has an abstract.");
    Selection.SelectNodeContents(abstracts(0));

  // Find insert location for Abstract, then insert
  } else {
    var rng = ActiveDocument.Range;
    rng.MoveToDocumentStart();
    if (rng.FindInsertLocation("Abstract")) {
       rng.InsertWithTemplate("Abstract");
       rng.Select();
    }
    else {
       Application.Alert("Cannot find location to insert Abstract.");
    }
    rng = null;
  }
}
if (CanRunMacros())
  doInsertAbstract();

]]></MACRO> 
 
<MACRO name="Insert Appendix" key="" lang="VBScript" id="1228" tooltip="Insert Appendix" desc="Insert an appendix to the article"><![CDATA[

Function doInsertAppendix

  Dim rng
  Set rng = ActiveDocument.Range
  ' Test If can insert Appendix at current position
  If not rng.CanInsert("Appendix") Then
    
    ' If In an Appendix, insert a new before the current one    
    If not rng.IsParentElement("Appendix") Then
    
      ' Otherwise insert an Appendix at the End
      rng.MoveToDocumentEnd
    End If
    
    If not rng.FindInsertLocation("Appendix", False) Then
      Application.Alert("Could not find insert location for Appendix")
      Set rng = Nothing
      Exit Function
    End If
    
  End If

  rng.InsertWithTemplate "Appendix"
  rng.Select
  Set rng = Nothing
  
End Function

If CanRunMacrosVB Then
    doInsertAppendix
  
End If

]]></MACRO> 
 
<MACRO name="Insert Author" key="" lang="VBScript" id="1315" tooltip="Insert Author" desc="Insert author's information"><![CDATA[

Function doInsertAuthor

  Dim rng
  Set rng = ActiveDocument.Range
  ' Test If can insert Author at current position
  If not rng.CanInsert("Author") Then
    
    ' If In an Author, insert a new before the current one    
    If not rng.IsParentElement("Author") Then
    
      ' Otherwise insert an Author at the End
      rng.MoveToDocumentEnd
    End If
    
    If not rng.FindInsertLocation("Author", False) Then
      Application.Alert("Could not find insert location for Author")
      Set rng = Nothing
      Exit Function
    End If
    
  End If

  rng.InsertElement "Author"
  Set rng = Nothing
  
End Function

If CanRunMacrosVB Then
  doInsertAuthor
End If

]]></MACRO> 
 
<MACRO name="Insert BiblioItem" key="" lang="VBScript" id="1704" tooltip="Insert BiblioItem" desc="Insert a bibliography item"><![CDATA[

' SoftQuad Script Language VBScript:

Sub doInsertBiblioItem
  dim Bibliographies
  Dim rng
  Set rng = ActiveDocument.Range

  If Selection.CanInsert("BiblioItem") Then
    Selection.InsertWithTemplate "BiblioItem"
    
  Else
    If Selection.IsParentElement("Bibliography") Then
      If Selection.FindInsertLocation("BiblioItem") Then
        Selection.InsertWithTemplate("BiblioItem")
      Else
        rng.MoveToDocumentEnd
        rng.MoveToElement "Bibliography", False
        If rng.FindInsertLocation("Title") Then
          rng.InsertWithTemplate("Title")
          If rng.FindInsertLocation("BiblioItem") Then
            rng.InsertWithTemplate("BiblioItem")
            rng.Select
          Else
            Application.Alert("Could not find insert location for BiblioItem")
            Set rng = Nothing
            Exit Sub
          End If
        Else
          Application.Alert("Could not find insert location for Bibliography Title")
          Set rng = Nothing
          Exit Sub
        End If
      End If
      
    Else
      Set Bibliographies = ActiveDocument.getElementsByTagName("Bibliography")
  
      rng.MoveToDocumentEnd

      If Bibliographies.length = 0 Then
      
        If rng.FindInsertLocation("Bibliography", false) Then
          rng.InsertWithTemplate "Bibliography"
        Else
          Application.Alert("Could not find insert location for Bibliography")
          Set rng = Nothing
          Exit Sub
        End If
        
        If rng.MoveToElement("BiblioItem") Then
          rng.Select
        Else
          If rng.FindInsertLocation("BiblioItem",false) Then
            rng.InsertWithTemplate("BiblioItem")
            rng.Select
          Else
            Application.Alert("Could not find insert location for BiblioItem")
            Set rng = Nothing
            Exit Sub
          End If
        End If

      Else
        If rng.FindInsertLocation("BiblioItem",false) Then
          rng.InsertWithTemplate("BiblioItem")
          rng.Select
        Else
          rng.MoveToDocumentEnd
          If rng.FindInsertLocation("Title", false) Then
            rng.InsertWithTemplate("Title")
            If rng.FindInsertLocation("BiblioItem") Then
              rng.InsertWithTemplate("BiblioItem")
              rng.Select
            Else
              Application.Alert("Could not find insert location for BiblioItem")
            End If
          Else
            Application.Alert("Could not find insert location for Bibliography Title")
          End If
        End If
      End If
    End If
  End If
  Set rng = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertBiblioItem
End If

]]></MACRO> 
 
<MACRO name="Insert Citation" key="" lang="VBScript" id="1319" tooltip="Insert Citation" desc="Insert citation to a bibliography item">
<![CDATA[
Sub doInsertCitation
  On Error Resume Next 
  dim obj
  set obj = CreateObject("journalist.Citation")
  if Err.Number <> 0 Then 
    Application.Alert ("The Citation DLL isn't installed. " + Chr(13) _
      + "Please register Samples\VC++\ReleaseMinDependency\journalist.dll.") 
  Else 
    If Selection.CanInsert("Citation") Then
      obj.NewCitation
    Else
      Application.Alert("Cannot insert Citation at this point in document.")
    End If
  End If
  set obj = nothing
End Sub

If CanRunMacrosVB Then
  doInsertCitation
End If
]]>
</MACRO> 
 
<MACRO name="Insert Copyright" key="" lang="VBScript" id="22008" tooltip="Insert Copyright" desc="Insert copyright information"><![CDATA[

Sub doInsertCopyright
  Dim Copyrights
  Set Copyrights = ActiveDocument.getElementsByTagName("Copyright")

  If Copyrights.length = 0 Then
    Dim rng
    Set rng = ActiveDocument.Range
    rng.MoveToDocumentStart
    If rng.FindInsertLocation("Copyright") Then
      rng.InsertWithTemplate "Copyright"
      rng.Select
    Else
      Application.Alert("Could not find insert location for Copyright")
    End If
    Set rng = Nothing
  Else
    Selection.SelectNodeContents(Copyrights.item(0))
  End If
End Sub

If CanRunMacrosVB Then
  doInsertCopyright
End If

]]></MACRO> 
 
<MACRO name="Toggle Emphasis" key="" lang="JScript" id="20409" tooltip="Insert or Remove Emphasis" desc="Insert, Surround, or Remove Emphasis (Italic)"><![CDATA[
function doToggleEmphasis() {
// If emphasis already present, remove tags.
// If not:  If insertion pt, insert emphasis template
//          If selection, surround selection with emphasis tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("Emphasis")) {
    if (rng.ContainerName != "Emphasis") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("Emphasis")) {
        rng.InsertWithTemplate("Emphasis");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert Emphasis element here.");
      }
    }
    else {
      if (rng.CanSurround("Emphasis")) {
        rng.Surround ("Emphasis");
      }
      else {
        Application.Alert("Cannot change Selection to Emphasis element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleEmphasis();
}
]]></MACRO> 

<MACRO name="Toggle Strong" key="" lang="JScript" id="20403" tooltip="Insert or Remove Strong" desc="Insert, Surround, or Remove Strong (Bold)"><![CDATA[
function doToggleStrong() {
// If Strong already present, remove tags.
// If not:  If insertion pt, insert Strong template
//          If selection, surround selection with emphasis tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("Strong")) {
    if (rng.ContainerName != "Strong") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("Strong")) {
        rng.InsertWithTemplate("Strong");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert Strong element here.");
      }
    }
    else {
      if (rng.CanSurround("Strong")) {
        rng.Surround ("Strong");
      }
      else {
        Application.Alert("Cannot change Selection to Strong element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleStrong();
}
]]> </MACRO> 
 
<MACRO name="Toggle TT" key="" lang="JScript" id="20414" tooltip="Insert or Remove TT" desc="Insert, Surround, or Remove TT (Monospaced)"><![CDATA[
function doToggleTT() {
// If TT already present, remove tags.
// If not:  If insertion pt, insert TT template
//          If selection, surround selection with emphasis tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("TT")) {
    if (rng.ContainerName != "TT") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("TT")) {
        rng.InsertWithTemplate("TT");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert TT element here.");
      }
    }
    else {
      if (rng.CanSurround("TT")) {
        rng.Surround ("TT");
      }
      else {
        Application.Alert("Cannot change Selection to TT element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleTT();
}
]]> </MACRO> 
 
<MACRO name="Toggle Underscore" key="" lang="JScript" id="20416" tooltip="Insert or Remove Underscore" desc="Insert, Surround, or Remove Underscore"><![CDATA[
function doToggleUnderscore() {
// If Underscore already present, remove tags.
// If not:  If insertion pt, insert Underscore template
//          If selection, surround selection with emphasis tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("Underscore")) {
    if (rng.ContainerName != "Underscore") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("Underscore")) {
        rng.InsertWithTemplate("Underscore");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert Underscore element here.");
      }
    }
    else {
      if (rng.CanSurround("Underscore")) {
        rng.Surround ("Underscore");
      }
      else {
        Application.Alert("Cannot change Selection to Underscore element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleUnderscore();
}
]]> </MACRO> 
 
 
<MACRO name="Insert Figure" key="" lang="JScript" id="1116" tooltip="Insert Figure" desc="Insert Figure">
<![CDATA[
function doFigureInsert() {
  var rng2 = ActiveDocument.Range;
  rng2.InsertWithTemplate("Figure");
  rng2.MoveToElement("Graphic");
  rng2.SelectContainerContents();
  rng2.Select();
  if (!ChooseImage()) {
    rng2.MoveToElement("Figure", false);
    rng2.SelectElement();
    rng2.Delete();
    rng2 = null;
    return false;
  }
  rng2.MoveToElement("Title", false);
  rng2.SelectContainerContents();
  rng2.Select();
  rng2 = null;
  return true;
}
  

function doInsertFigure() {
  var rng = ActiveDocument.Range;
  
  // Make Insertion point then try to insert figure here
  rng.Collapse(sqCollapseStart);

  // Try to insert the figure
  if (rng.CanInsert("Figure")) {
    rng.Select();
    doFigureInsert();
    rng = null;
    return;
  }

  // If can't insert figure, split the container and see if we can then
  var node = rng.ContainerNode;
  if (node) {
    var elName = node.nodeName;
    if (elName == "Para" || elName == "LiteralLayout" || elName == "ProgramListing") {
      Selection.SplitContainer();
      rng = ActiveDocument.Range;
      var rngSave = rng.Duplicate;
      rng.SelectBeforeContainer();
      if (rng.CanInsert("Figure")) {
        rng.Select();
        if (doFigureInsert()) {
          rng = null;
          rngSave = null;
          return;
        }
        else {
          rngSave.Select();
          Selection.JoinElementToPreceding();
          rng = null;
          rngSave = null;
          return;
        }
      }

      // Join selection back together
      else {
        Selection.JoinElementToPreceding();
      }
      rngSave = null;
    }
  }
  
  // If not, try to find a place to insert the Figure
  
  if (rng.FindInsertLocation("Figure")) {
    rng.Select();
    doFigureInsert();
    rng = null;
    return;
  }

  // Try looking backwards
  if (rng.FindInsertLocation("Figure", false)) {
    rng.Select();
    doFigureInsert();
    rng = null;
    return;
  }  

  Application.Alert("Could not find insert location for Figure.");
  rng = null;
}
if (CanRunMacros()) { 
  doInsertFigure();
}
]]>
</MACRO> 
 
<MACRO name="Insert Graphic" key="" lang="JScript" id="1115" tooltip="Insert Graphic" desc="Insert Graphic element"><![CDATA[
function doGraphicInsert() {
  var rng2 = ActiveDocument.Range;
  rng2.InsertWithTemplate("Graphic");
  rng2.Select();
  if (!ChooseImage()) {
    rng2.SelectElement();
    rng2.Delete();
    rng2 = null;
    return false;
  }
  rng2 = null;
  return true;
}

function doInsertGraphic() {
  var rng = ActiveDocument.Range;
  
  // Make Insertion point then try to insert Graphic here
  rng.Collapse(sqCollapseStart);

  // Try to insert the Graphic
  if (rng.CanInsert("Graphic")) {
    rng.Select();
    doGraphicInsert();
    rng = null;
    return;
  }

  // If can't insert Graphic, split the container and see if we can then
  var node = rng.ContainerNode;
  if (node) {
    var elName = node.nodeName;
    if (elName == "Para" || elName == "LiteralLayout" || elName == "ProgramListing") {
      Selection.SplitContainer();
      rng = ActiveDocument.Range;
      var rngSave = rng.Duplicate;
      rng.SelectBeforeContainer();
      if (rng.CanInsert("Graphic")) {
        rng.Select();
        if (doGraphicInsert()) {
          rng = null;
          return;
        }
        else {
          rngSave.Select();
          Selection.JoinElementToPreceding();
          rng = null;
          return;
        }
      }
  
      // Join selection back together
      else {
        Selection.JoinElementToPreceding();
      }
      rngSave = null;
    }
  }
  
  // If not, try to find a place to insert the Figure
  
  if (rng.FindInsertLocation("Graphic")) {
    rng.Select();
    doGraphicInsert();
    rng = null;
    return;
  }

  // Try looking backwards
  if (rng.FindInsertLocation("Graphic", false)) {
    rng.Select();
    doGraphicInsert();
    rng = null;
    return;
  }  

  Application.Alert("Could not find insert location for Graphic.");
  rng = null;
}
if (CanRunMacros()) { 
  doInsertGraphic();
}

]]></MACRO> 
 
<MACRO name="Insert InlineGraphic" key="" lang="JScript" id="1117" tooltip="Insert InlineGraphic" desc="Insert an inline graphic"><![CDATA[

function doInsertInlineGraphic() {
  var rng = ActiveDocument.Range;
  
  // Make Insertion point then try to insert InlineGraphic here
  rng.Collapse(sqCollapseStart);

  // Try to insert the graphic
  if (rng.CanInsert("InlineGraphic")) {
    rng.InsertWithTemplate("InlineGraphic");
    rng.Select();
    if (!ChooseImage()) {
      rng.SelectElement();
      rng.Delete();
    }
  }

  else {
    Application.Alert("Cannot insert InlineGraphic here.");
  }
  rng = null;
}
if (CanRunMacros()) {
  doInsertInlineGraphic();
}

]]></MACRO> 
 
<MACRO name="Replace Graphic" key="" lang="JScript" id="1265" tooltip="Replace InlineGraphic or Graphic" desc="Choose a new graphic image"><![CDATA[

function doReplaceGraphic() {
  var rng = ActiveDocument.Range;
  
  // If in a graphic -- let user pick new graphic
  if (rng.ContainerName == "Graphic" || rng.ContainerName == "InlineGraphic") {
    ChooseImage();
  }
  else {
    Application.Alert("Select a Graphic or inlineGraphic to replace.");
  }
  rng = null;
}
if (CanRunMacros()) {
  doReplaceGraphic();
}

]]></MACRO> 

<MACRO name="Insert Link" key="Ctrl+Shift+L" lang="VBScript" id="1328" tooltip="Insert Link" desc="Insert Link element referencing another element in document">
<![CDATA[
Sub doInsertLink
  On Error Resume Next
  dim LinkDlg
  set LinkDlg = CreateObject("linkdemo.InsertLinkDlg")
  if Err.Number <> 0 Then  
    Application.Alert ("Can't create Link form.  Inserting <Link> element.")
    Selection.InsertWithTemplate "Link"  
  Else  
    LinkDlg.InsertLinkDlg
  End If
  set LinkDlg = nothing
End Sub

If CanRunMacrosVB Then
  doInsertLink
End If
]]>
</MACRO> 
 
<MACRO name="Insert LiteralLayout" key="" lang="VBScript" id="1205" tooltip="Insert Literal Layout" desc="Insert LiteralLayout element in which spaces and line breaks are preserved">
<![CDATA[
Sub doInsertLiteralLayout
  Dim rng
  Set rng = ActiveDocument.Range
  
  If rng.IsInsertionPoint Then
    If rng.FindInsertLocation("LiteralLayout") OR rng.FindInsertLocation("LiteralLayout", false) Then
      rng.InsertWithTemplate "LiteralLayout"
      rng.Select
    Else
      Application.Alert("Could not find insert location for LiteralLayout")
    End If
  Else
    If rng.CanSurround("LiteralLayout") Then
      rng.Surround "LiteralLayout"
      rng.Select
    Else
      Application.Alert("Cannot change selection to LiteralLayout")
    End If
  End If
  
  Set rng = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertLiteralLayout
End If
]]>
</MACRO> 
 
<MACRO name="Insert Note" key="" lang="VBScript" id="1227" tooltip="Insert Note" desc="Insert note to the reader"><![CDATA[

Sub doInsertNote
  Dim rng
  Set rng = ActiveDocument.Range
  If rng.IsInsertionPoint Then
    If rng.FindInsertLocation("Note") OR rng.FindInsertLocation("Note", false) Then
      rng.InsertWithTemplate "Note"
      rng.Select
    Else
      Application.Alert("Could not find insert location for Note")
    End If
  Else
    If rng.CanSurround("Note") Then
      rng.Surround "Note"
      rng.Select
    Else
      Application.Alert("Cannot change selection to Note")
    End If
  End If
  Set rng = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertNote
End If

]]></MACRO> 
 
<MACRO name="Insert New Section" key="Ctrl+Alt+N" lang="VBScript" id="1744" tooltip="Insert New Section" desc="Insert the same level section where allowed after current point"><![CDATA[

Sub doInsertNewSection
  On Error Resume Next
  Dim rng
  Set rng = ActiveDocument.Range
  
  rng.Collapse
  If rng.IsParentElement("Sect4") Then
    ' Just because we're in a Sect4 doesn't mean it's our container.
    ' Move up the hierarchy until the Sect4 is our parent
    While rng.ContainerNode.nodeName <> "Sect4"
      rng.SelectElement
    Wend

    ' Move the selection to after the current Sect4
    rng.SelectAfterNode(rng.ContainerNode)

    ' Insert a new Sect4
    rng.InsertWithTemplate("Sect4")
  Else
    If rng.IsParentElement("Sect3") Then
      While rng.ContainerNode.nodeName <> "Sect3"
        rng.SelectElement
      Wend

      rng.SelectAfterNode(rng.ContainerNode)

      rng.InsertWithTemplate("Sect3")
    Else
      If rng.IsParentElement("Sect2") Then
        While rng.ContainerNode.nodeName <> "Sect2"
          rng.SelectElement
        Wend

        rng.SelectAfterNode(rng.ContainerNode)

        rng.InsertWithTemplate("Sect2")
      Else
        If rng.IsParentElement("Sect1") Then
          While rng.ContainerNode.nodeName <> "Sect1"
            rng.SelectElement
          Wend

          rng.SelectAfterNode(rng.ContainerNode)

          rng.InsertWithTemplate("Sect1")
        Else
          If rng.IsParentElement("Bibliography") Then
            Application.Alert("You cannot insert sections inside a Bibliography.")
          Else
            Application.Alert("You are not currently inside a section.  Try inserting a subsection instead.")
          End If
        End If    
      End If
    End If
  End If
  rng.Select
  Set rng = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertNewSection
End If

]]></MACRO> 
 
<MACRO name="Insert ProgramListing" key="" lang="VBScript" id="1248" tooltip="Insert Program Listing" desc="Insert ProgramListing element in which spaces and line breaks are preserved">
<![CDATA[
Sub doInsertProgramListing
  Dim rng
  Set rng = ActiveDocument.Range
  
  If rng.IsInsertionPoint Then
    If rng.FindInsertLocation("ProgramListing") OR rng.FindInsertLocation("ProgramListing", false) Then
      rng.InsertWithTemplate "ProgramListing"
      rng.Select
    Else
      Application.Alert("Could not find insert location for ProgramListing")
    End If
  Else
    If rng.CanSurround("ProgramListing") Then
      rng.Surround "ProgramListing"
      rng.Select
    Else
      Application.Alert("Cannot change selection to ProgramListing")
    End If
  End If
  
  Set rng = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertProgramListing
End If
]]>
</MACRO> 
 
<MACRO name="Insert Subsection" key="Ctrl+Alt+S" lang="VBScript" id="1748" tooltip="Insert Subsection" desc="Insert the next-lower level section where allowed after current point">
<![CDATA[
Sub doInsertSubSection
  dim Rng
  set Rng = ActiveDocument.Range
  dim UserRng
  set UserRng = ActiveDocument.Range
  dim RngNode
  On Error Resume Next 
  Rng.Collapse
  If Rng.IsParentElement("Sect4") Then
    ' Sect4 is the lowest level section in the DTD
    Application.Alert("You cannot enter any more levels of subsection.")
  Else
    If Rng.IsParentElement("Sect3") Then
    ' Just because we're in a Sect3 doesn't mean it's our container.
    ' Move up the hierarchy until the Sect3 is our parent.
    ' First, set a DOM Node match to the range for navigating.

      set RngNode = Rng.ContainerNode      
      While RngNode.nodeName <> "Sect3"
          set RngNode = RngNode.parentNode
      Wend

    ' Set the range to the contents of the Sect3 element, and collapse 
    ' it to the beginning of that element.
  
      set Rng = SelectNodeContents(RngNode)
      Rng.Collapse(sqCollapseEnd)

    ' Just because we're at the level where we can insert a Sect4 doesn't
    ' mean that we're at a point where we can.  Move the selection point
    ' past any intervening elements until we can insert a Sect4

      set RngNode = RngNode.firstChild
      While not Rng.CanInsert("Sect4")
        Rng.SelectAfterNode(RngNode)
        set RngNode = RngNode.nextSibling
      Wend

    ' Now we can insert the Sect4
      Rng.InsertWithTemplate("Sect4")
      Selection = Rng.Select
    Else
      If Rng.IsParentElement("Sect2") Then
        set RngNode = Rng.ContainerNode
        While RngNode.nodeName <> "Sect2"
          set RngNode = RngNode.parentNode
        Wend
  
        set Rng = SelectNodeContents(RngNode)
        Rng.Collapse(sqCollapseEnd)

        set RngNode = RngNode.firstChild
        While not Rng.CanInsert("Sect3")
          Rng.SelectAfterNode(RngNode)
          set RngNode = RngNode.nextSibling
        Wend
  
        Rng.InsertWithTemplate("Sect3")
        Selection = Rng.Select
      Else
        If Rng.IsParentElement("Sect1") Then
          set RngNode = Rng.ContainerNode
          While RngNode.nodeName <> "Sect1"
            set RngNode = RngNode.parentNode
          Wend
    
          set Rng = SelectNodeContents(RngNode)
          Rng.Collapse(sqCollapseEnd)

          set RngNode = RngNode.firstChild
          While not Rng.CanInsert("Sect2")
            Rng.SelectAfterNode(RngNode)
            set RngNode = RngNode.nextSibling
          Wend

          Rng.InsertWithTemplate("Sect2")
          Selection = Rng.Select
        Else
          If Rng.IsParentElement("Appendix") Then
            set RngNode = Rng.ContainerNode
            While RngNode.nodeName <> "Appendix"
              set RngNode = RngNode.parentNode
            Wend
      
            set Rng = SelectNodeContents(RngNode)
            Rng.Collapse(sqCollapseEnd)

            set RngNode = RngNode.firstChild
            While (not Rng.CanInsert("Sect1")) and Rng.IsParentElement("Article")
              Rng.SelectAfterNode(RngNode)
              set RngNode = RngNode.nextSibling
            Wend
      
            Rng.InsertWithTemplate("Sect1")
            Selection = Rng.Select
          Else
            If Rng.IsParentElement("Bibliography") Then
              Application.Alert("Cannot insert sections in a Bibliography.")
              Selection = UserRng.Select
            Else
              If Rng.IsParentElement("Article") Then
                set RngNode = Rng.ContainerNode
                While RngNode.nodeName <> "Article"
                  set RngNode = RngNode.parentNode
                Wend
      
                set Rng = SelectNodeContents(RngNode)
                Rng.Collapse(sqCollapseEnd)

                set RngNode = RngNode.firstChild
                While (not Rng.CanInsert("Sect1")) and Rng.IsParentElement("Article")
                  Rng.SelectAfterNode(RngNode)
                  set RngNode = RngNode.nextSibling
                Wend

                If Rng.IsParentElement("Article") Then
' need If statement in case we walked outside the document Element
                  Rng.InsertWithTemplate("Sect1")
                  Selection = Rng.Select
                Else
                  Application.Alert("Cannot insert subsection here.")
                  Selection = UserRng.Select
                End If
              End If
            End If
          End If
        End If    
      End If
    End If
  End If
  set Rng = Nothing
  set UserRng = Nothing
  set RngNode = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertSubSection
End If
]]>
</MACRO> 
 
<MACRO name="Insert ULink" key="" lang="VBScript" id="1110" tooltip="Insert ULink" desc="Insert an external reference"><![CDATA[

Sub doInsertULink
  dim Rng
  set Rng = ActiveDocument.Range
  If Rng.IsInsertionPoint Then
    If Rng.CanInsert("ULink") Then
      Rng.InsertElement "ULink"
    Else
      Application.Alert("Cannot insert ULink element here.")
      Set Rng = Nothing
      Exit Sub
    End If
  Else
    If Rng.CanSurround("ULink") Then
      Rng.Surround "ULink"
    Else
      Application.Alert("Cannot change selection to ULink element.")
      Set Rng = Nothing
      Exit Sub
    End If
  End If
  Dim Dlg
  ' This line creates and displays the dialog
  Set Dlg = FormFuncs.CreateFormDlg(Application.Path + "/Forms/ULink.hhf")
  Dim desc
  Set desc = Dlg.URLDesc
  Rng.SelectcontainerContents
  desc.Text = Rng.Text
  Dlg.URLLink.Text = Rng.ContainerNode.getAttribute("URL")
  ' make the dialog modal
  If Dlg.DoModal = 1 Then
    Rng.Text = desc.Text
    Rng.ContainerNode.setAttribute "URL", Dlg.URLLink.Text
  Else
    Rng.RemoveContainerTags
  End If
  Rng.Select
  Set Dlg = Nothing
  Set Rng = Nothing
End Sub

If CanRunMacrosVB Then
  doInsertULink
End If

]]></MACRO> 
 
<MACRO name="On_Document_Open_Complete" lang="JScript" hide="true" desc="initialize the macros"><![CDATA[

  Application.Run("Init_JScript_Macros");
  Application.Run("Init_VBScript_Macros");
  
  var viewType = ActiveDocument.ViewType;
  if ((viewType == sqViewNormal || viewType == sqViewTagsOn) && (ActiveDocument.IsXML)) {
    var LastModList = ActiveDocument.getElementsByTagName("LastModDate");
    var Rng = ActiveDocument.Range;
    if (LastModList.length > 0) {
      Rng.SelectNodeContents(LastModList.item(0));
      Rng.ReadOnlyContainer = true;
    }
    Rng = null;
  }

//***************************************************************************************************
// Global variables and global function for Annotations and Revision Control
//****************************************************************************************************

// document properties for Annotations
  var docProps = ActiveDocument.CustomDocumentProperties;
  docProps.Add ("HideAnnotations", false);

// document properties for Revision Control
  docProps.Add ("Highlighting", true);
  docProps.Add ("ShowOriginal", false);
  docProps.Add ("InsNextPrev", false);
  docProps.Add ("DelNextPrev", false);
  
  if ((viewType == sqViewNormal || viewType == sqViewTagsOn) && (ActiveDocument.IsXML)) {
    Application.Run("Show Annotations");
    Application.Run("Show Changes With Highlighting");
  }


  
]]></MACRO> 
<MACRO name="Init_VBScript_Macros" lang="VBScript" desc="initialize VBScript macros" hide="true"><![CDATA[

Function CanRunMacrosVB
  If (not ActiveDocument.ViewType = sqViewNormal) AND (not ActiveDocument.ViewType = sqViewTagsOn) Then
    Application.Alert("Change to Tags On or Normal view to run macros.")
    CanRunMacrosVB = False
    Exit Function
  End If
  
  If not ActiveDocument.IsXML Then
    Application.Alert("Cannot run macros because document is not XML.")
    CanRunMacrosVB = False
    Exit Function
  End If

  CanRunMacrosVB = True
End Function
  
]]></MACRO> 
<MACRO name="Init_JScript_Macros" lang="JScript" desc="initialize JScript macros" hide="true"><![CDATA[

function CanRunMacros() {
  if (ActiveDocument.ViewType != sqViewNormal && ActiveDocument.ViewType != sqViewTagsOn) {
    Application.Alert("Change to Tags On or Normal view to run macros.");
    return false;
  }

  if (!ActiveDocument.IsXML) {
    Application.Alert("Cannot run macros because document is not XML.");
    return false;
  }
  return true;
}

function ChooseImage()
{
  var rng = ActiveDocument.Range;
  if (rng.ContainerName == "Graphic" || rng.ContainerName == "InlineGraphic") {
    try {
      var obj = new ActiveXObject("SQExtras.FileDlg");
    }
    catch(exception) {
      var result = reportRuntimeError("Choose Image Error:", exception);
      Application.Alert(result + "\nPlease register SQExtras.dll");
      return false;
    }
    if (obj.DisplayImageFileDlg(true, "Choose Image", "Image Files (*.gif,*.jpg,*.png,*.tiff,*.tif,*.bmp)|*.gif;*.jpg;*.png;*.tiff;*.tif;*.bmp|All Files (*.*)|*.*||",  Application.Path + "\\Samples\\Cameras\\images\\clipart")) {
      var src = obj.FullPathName;
      var url = Application.PathToURL(src, ActiveDocument.Path + "\\");
      rng.ContainerAttribute("FileRef") = url;
      obj = null;
      rng = null;
      return true;
    }
    else {
      rng = null;
      obj = null;
      return false;
    }
  }
  else {
    Application.Alert("Graphic not selected");
    rng = null;
    return false;
  }
  rng = null;
}

function StartNewSubsection(sectName)
{
// This function can only be called if it is known that Para is a parent element

  var paraName = "Para";
  var titleName = "Title";
  
  var rng = ActiveDocument.Range;
  var strBody = "";
  var strTitle = "";
  
  // Use the current Para for the Title of the new section
  var node = Selection.ContainerNode;
  while (node.nodeName != paraName) {
    node = node.parentNode;
  }
  
  rng.SelectNodeContents(node);
  strTitle = rng.Text;
  rng.SelectElement();
  rng.Delete();
  
  // Copy the rest to a string
  rng.Select();
  var rng3 = rng.Duplicate;
  var ret = rng3.MoveToElement(sectName);  // look for following subsections
  var rng2 = rng.Duplicate;
  rng2.SelectContainerContents();
  rng2.Collapse(sqCollapseEnd);  // Make sure subsection found is in current section
  if (ret && rng2.IsGreaterThan(rng3)) {
    rng3.SelectBeforeContainer();
    rng = rng3.Duplicate;
  } 
  else { // no subsections, so move to end of container
    rng = rng2.Duplicate;
  }
  Selection.ExtendTo(rng);
  strBody = Selection.Text;
  Selection.Delete();
  
  // Put in the new section
  rng.InsertElement(sectName);
  rng.InsertElement(titleName);
  rng.TypeText(strTitle);
  rng.SelectAfterContainer();
  if (strBody != "") rng.TypeText(strBody);
  rng.MoveToElement(titleName, false);
  rng.Select();
  rng = null;
  rng3 = null;
  rng2 = null;
}

// InsertLastModifiedDate - inserts date just before document is saved
function InsertLastModifiedDate() {

  var localtime = new Date();
  var LastModString = localtime.toLocaleString();

  var LastModList = ActiveDocument.getElementsByTagName("LastModDate");

  var Rng = ActiveDocument.Range;
  if (LastModList.length > 0) {
    Rng.SelectNodeContents(LastModList.item(0));
    Rng.ReadOnlyContainer = false;
    Rng.PasteString(LastModString);
    Rng.ReadOnlyContainer = true;
  }
  else {
    Rng.MoveToDocumentEnd();

    if (Rng.FindInsertLocation("LastModDate", false)) {
      Rng.InsertElement("LastModDate");
      Rng.TypeText(LastModString);
      Rng.ReadOnlyContainer = true;
    }
    else {
      Application.Alert("Could not find insert location for LastModDate");
    }
  }
  Rng = null;
}

// fix PubDate
  fixISODates(false);

]]></MACRO> 
<MACRO name="On_Update_UI" lang="JScript" hide="true" id="144"><![CDATA[
function refreshStyles() {
  var docProps = ActiveDocument.CustomDocumentProperties;
  if (docProps.count == 0) return;
  if (docProps.item("Highlighting").value == "True") {
    var rng = ActiveDocument.Range;
    rng.MoveToDocumentStart();
    while(rng.MoveToElement("Insertion")) {
      rng.ContainerStyle = "color:red; text-decoration:underline";
    }
    rng.MoveToDocumentStart();
    while (rng.MoveToElement("Deletion")) {
      rng.ContainerStyle = "color:red; text-decoration:line-through";
    }
    rng = null;
  }
  var hideAnnots = docProps.item("HideAnnotations").value;

  if(hideAnnots == "True"){
    Application.Run("Hide Annotations");
  }
}
// This causes too much flickering since On_Update_UI is called so frequently.
// However without it, if you press <Enter> while in an Insertion or Deletion, the styles aren't set correctly.
//if (ActiveDocument.IsXML &&
//    (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn)) {
//  refreshStyles();
//}

// function to disable Annotation Macros
function disableAnnotMacros() {
  var dt = ActiveDocument.doctype;
  if (dt.hasElementType("Annotation")) { // if the elements exist in the DTD
    var Annot_list = ActiveDocument.getElementsByTagName("Annotation");
    // if not annotated
    if(Annot_list.length == 0) {
      Application.DisableMacro("Delete Annotation");
      Application.DisableMacro("Hide Annotations");
      Application.DisableMacro("Show Annotations");
      Application.DisableMacro("List All Comments");
    Application.DisableMacro("Delete All Annotations");
      Application.DisableMacro("Clean Up Empty");
      if(!Selection.CanSurround("Annotation")){
        Application.DisableMacro("Insert Annotation");
      }
    }else {
      if(!Selection.CanSurround("Annotation")){
        Application.DisableMacro("Insert Annotation");
      }
      // if annotation is not selected
      if(!Selection.IsParentElement("Annotation")){
        Application.DisableMacro("Delete Annotation");
      }
    var docProps = ActiveDocument.CustomDocumentProperties;
    var hideAnnots;
    if (docProps.count == 0) hideAnnots = "False";
    else hideAnnots = docProps.item("HideAnnotations").value;
      if(hideAnnots == "True"){
        Application.DisableMacro("Hide Annotations");
      } else {
        Application.DisableMacro("Show Annotations");
      }
    }
  }
  else {
    Application.DisableMacro("Delete Annotation");
    Application.DisableMacro("Hide Annotations");
    Application.DisableMacro("Show Annotations");
    Application.DisableMacro("List All Comments");
    Application.DisableMacro("Clean Up Empty");
    Application.DisableMacro("Delete All Annotations");
  if(!Selection.CanSurround("Annotation")){
        Application.DisableMacro("Insert Annotation");
    }
  }
}

// function to disable Version Control Macros
function disableVCMacros() {
  var dt = ActiveDocument.doctype;
  if (dt.hasElementType("Insertion") && dt.hasElementType("Deletion")) { // if the elements exist in the DTD

    var Ins_list = ActiveDocument.getElementsByTagName("Insertion");
    var Del_list = ActiveDocument.getElementsByTagName("Deletion");
    // if no changes have been made disable some macros
    if(Ins_list.length == 0 && Del_list.length == 0) {
      if(Selection.IsInsertionPoint ){
          Application.DisableMacro("Deletion");
        }else if (!Selection.CanSurround("Deletion")){
      Application.DisableMacro("Deletion");
    }
      Application.DisableMacro("Accept Change");
      Application.DisableMacro("Reject Change");
      Application.DisableMacro("Reject Changes");
      Application.DisableMacro("Accept Changes");
      Application.DisableMacro("Accept or Reject Changes");
      Application.DisableMacro("Show Original");
      Application.DisableMacro("Find Prev");
      Application.DisableMacro("Find Next");
      Application.DisableMacro("Show Changes With Highlighting");
      Application.DisableMacro("Show Changes Without Highlighting");
    }
    else {

      if(Selection.ContainerNode) {
        // if text is selected 
        if (!Selection.CanSurround("Deletion") || Selection.IsInsertionPoint || Selection.IsParentElement("Deletion")){
          Application.DisableMacro("Deletion");
        }
        if(!Selection.CanInsert("Insertion") || Selection.IsParentElement("Deletion") ||Selection.IsParentElement("Insertion")){
          Application.DisableMacro("Insertion");
        }
          
        
        // if the current Selection is neither Insertion nor Deletion
        if(!Selection.isParentElement("Insertion") && !Selection.IsParentElement("Deletion")){
          Application.DisableMacro("Accept Change");
          Application.DisableMacro("Reject Change");
        }
        var docProps = ActiveDocument.CustomDocumentProperties;
        var highlight;
        var showoriginal;
        if (docProps.count == 0) {
          highlight = "True";
          showoriginal = "False";
        } else {
          highlight = docProps.item("Highlighting").value;
          showoriginal = docProps.item("ShowOriginal").value;
        }
        if(highlight == "True") {
          Application.DisableMacro("Show Changes With Highlighting");
        } else if(showoriginal == "True"){ 
          Application.DisableMacro("Show Original");
        } else {
          Application.DisableMacro("Show Changes Without Highlighting");
        }

      }
    }
  }
  else {
    Application.DisableMacro("Insertion");
    Application.DisableMacro("Deletion");
    Application.DisableMacro("Accept Change");
    Application.DisableMacro("Reject Change");
    Application.DisableMacro("Reject Changes");
    Application.DisableMacro("Accept Changes");
    Application.DisableMacro("Accept or Reject Changes");
    Application.DisableMacro("Show Original");
    Application.DisableMacro("Find Prev");
    Application.DisableMacro("Find Next");
    Application.DisableMacro("Show Changes With Highlighting");
    Application.DisableMacro("Show Changes Without Highlighting");
  } 
}

// Check if the view is Tags On and if so, adjust the selection out of the 
// top-level
if (Selection.IsInsertionPoint && ActiveDocument.ViewType == sqViewTagsOn) {
   if (Selection.ContainerNode == null) {
      Selection.MoveRight();
   }
   if (Selection.ContainerNode == null) {
      Selection.MoveLeft();
   }
}

// Disable most macros if in Plain Text view or if the document is not XML
if (!ActiveDocument.IsXML ||
    (ActiveDocument.ViewType != sqViewNormal && ActiveDocument.ViewType != sqViewTagsOn)) {
  Application.DisableMacro("Insert Abstract");
  Application.DisableMacro("Insert Appendix");
  Application.DisableMacro("Insert Author");
  Application.DisableMacro("Insert BiblioItem");
  Application.DisableMacro("Insert Citation");
  Application.DisableMacro("Insert Copyright");
  Application.DisableMacro("Toggle Emphasis");
  Application.DisableMacro("Toggle Strong");
  Application.DisableMacro("Toggle TT");
  Application.DisableMacro("Toggle Underscore");
  Application.DisableMacro("Insert Figure");
  Application.DisableMacro("Insert Graphic");
  Application.DisableMacro("Replace Graphic");
  Application.DisableMacro("Insert InlineGraphic");
  Application.DisableMacro("Insert Link");
  Application.DisableMacro("Insert LiteralLayout");
  Application.DisableMacro("Insert Note");
  Application.DisableMacro("Insert New Section");
  Application.DisableMacro("Insert ProgramListing");
  Application.DisableMacro("Insert PubDate");
  Application.DisableMacro("Insert Subsection");
  Application.DisableMacro("Insert ULink");
  Application.DisableMacro("Import Table");
  Application.DisableMacro("Update Table");
  Application.DisableMacro("Import SeeAlso");
  Application.DisableMacro("Update SeeAlso");
  Application.DisableMacro("Save As HTML");
  Application.DisableMacro("Import From Word");
  Application.DisableMacro("Convert to Subsection");
  Application.DisableMacro("Convert to Section");
  Application.DisableMacro("Convert to Paragraph");
  Application.DisableMacro("Convert to Article Title");
  Application.DisableMacro("Join Paragraphs");
  Application.DisableMacro("Promote Section");
  Application.DisableMacro("Demote Section");
  Application.DisableMacro("Toggle Rules Checking");
  Application.DisableMacro("Insertion");
  Application.DisableMacro("Deletion");
  Application.DisableMacro("Accept Change");
  Application.DisableMacro("Reject Change");
  Application.DisableMacro("Reject Changes");
  Application.DisableMacro("Accept Changes");
  Application.DisableMacro("Accept or Reject Changes");
  Application.DisableMacro("Show Original");
  Application.DisableMacro("Find Prev");
  Application.DisableMacro("Find Next");
  Application.DisableMacro("Show Changes With Highlighting");
  Application.DisableMacro("Show Changes Without Highlighting");
  Application.DisableMacro("Delete Annotation");
  Application.DisableMacro("Insert Annotation");
  Application.DisableMacro("Hide Annotations");
  Application.DisableMacro("Show Annotations");
  Application.DisableMacro("List All Comments");
  Application.DisableMacro("Clean Up Empty");
  Application.DisableMacro("Delete All Annotations");
}

if (ActiveDocument.ViewType != sqViewNormal && ActiveDocument.ViewType != sqViewTagsOn) {
  Application.DisableMacro("Use 1.css for the Structure View");
  Application.DisableMacro("Use 2.css for the Structure View");
  Application.DisableMacro("Use 3.css for the Structure View");
  Application.DisableMacro("Use 4.css for the Structure View");
  Application.DisableMacro("Use 5.css for the Structure View");
  Application.DisableMacro("Use the default (generated) Structure View");
}

// Disable some macros if the view is Normal or Tags On
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {

// Structural elements
  if (  Selection.IsParentElement("Bibliography") ||
        Selection.IsParentElement("Abstract") ||
        Selection.IsParentElement("PubDate") ||
        Selection.IsParentElement("Copyright") ||
        Selection.IsParentElement("Title")) {
    Application.DisableMacro("Insert New Section"); }
    
  if (!Selection.IsParentElement("Sect1")) {
    Application.DisableMacro("Insert New Section"); }
 
  if (  Selection.IsParentElement("Sect4") ||
        Selection.IsParentElement("Bibliography") ) {
    Application.DisableMacro("Insert Subsection"); }

// Text-level elements
  if (!Selection.CanInsert("Citation")) {
    Application.DisableMacro("Insert Citation"); }
  if (!Selection.CanInsert("InlineGraphic")) {
    Application.DisableMacro("Insert InlineGraphic"); }
  if (!Selection.CanInsert("Link")) {
    Application.DisableMacro("Insert Link"); }
  
  if (Selection.IsInsertionPoint){
      if (!Selection.CanInsert("ULink")) {
        Application.DisableMacro("Insert ULink"); }
  }

  if (!Selection.IsInsertionPoint) {
    if (!Selection.CanSurround("LiteralLayout"))
      Application.DisableMacro("Insert LiteralLayout");
    if (!Selection.CanSurround("Note"))
      Application.DisableMacro("Insert Note");
    if (!Selection.CanSurround("ProgramListing"))
      Application.DisableMacro("Insert ProgramListing");
    if (!Selection.CanSurround("ULink"))
     Application.DisableMacro("Insert ULink");
  }


  // Emphasis elements
  if (Selection.IsInsertionPoint) {
    if (!Selection.CanInsert("Emphasis")&& Selection.ContainerName != "Emphasis")
        Application.DisableMacro("Toggle Emphasis");
  }
  else {
    if (!Selection.CanSurround("Emphasis")&& Selection.ContainerName != "Emphasis")
        Application.DisableMacro("Toggle Emphasis");
  }
  
  if (Selection.IsInsertionPoint) {
    if (!Selection.CanInsert("Strong")&& Selection.ContainerName != "Strong")
      Application.DisableMacro("Toggle Strong");
  }
  else {
    if (!Selection.CanSurround("Strong")&& Selection.ContainerName != "Strong")
        Application.DisableMacro("Toggle Strong");
  }
  
  if (Selection.IsInsertionPoint) {
    if (!Selection.CanInsert("TT")&& Selection.ContainerName != "TT")
        Application.DisableMacro("Toggle TT");
  }
  else {
    if (!Selection.CanSurround("TT")&& Selection.ContainerName != "TT")
        Application.DisableMacro("Toggle TT");
  }
  
  if (Selection.IsInsertionPoint) {
    if (!Selection.CanInsert("Underscore")&& Selection.ContainerName != "Underscore")
        Application.DisableMacro("Toggle Underscore");
  }
  else {
    if (!Selection.CanSurround("Underscore")&& Selection.ContainerName != "Underscore")
        Application.DisableMacro("Toggle Underscore");
  }
  
  // Word Import Macros
  if (!Selection.IsParentElement("Para")) {
    Application.DisableMacro("Convert to Subsection");
    Application.DisableMacro("Convert to Section");
    if (!Selection.IsParentElement("Title")) {
      Application.DisableMacro("Convert to Article Title");
    }
  }
  else {
    if (Selection.IsParentElement("Sect4")) {
      Application.DisableMacro("Convert to Subsection");
    }
  }
  if (!Selection.IsParentElement("Title")) {
    Application.DisableMacro("Convert to Paragraph");
    Application.DisableMacro("Promote Section");
    Application.DisableMacro("Demote Section");
  }
  else {  
    if (!Selection.IsParentElement("Sect1") ){
      Application.DisableMacro("Convert to Paragraph");
    }
    if (!Selection.IsParentElement("Sect2") ){
      Application.DisableMacro("Promote Section");
    }
    if (!Selection.IsParentElement("Sect1") || Selection.IsParentElement("Sect4")){
      Application.DisableMacro("Demote Section");
    }
  }
  if (Selection.IsInsertionPoint) {
    Application.DisableMacro("Join Paragraphs");
  }
  
  // Find if any Bibliography Designator has changed and convert it to uppercase
  // (to demonstrate "GetNodeState" capability)
  if (Selection.ContainerName != "Designator") {
    var list=ActiveDocument.getElementsByTagName("Designator");
    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        var node = list.item(i);
        if (ActiveDocument.GetNodeState("ContentInserted", node)) {
          var rng = ActiveDocument.Range;
          rng.SelectNodeContents(node);
          var str = rng.Text;
          rng.Text = str.toUpperCase();
          ActiveDocument.ClearNodeChangedStates(node,false);
          rng = null;
        }
      }
    }
  }
  
  // Structure view macros
  if (!ActiveDocument.StructureViewVisible) {
    Application.DisableMacro("Use 1.css for the Structure View");
    Application.DisableMacro("Use 2.css for the Structure View");
    Application.DisableMacro("Use 3.css for the Structure View");
    Application.DisableMacro("Use 4.css for the Structure View");
    Application.DisableMacro("Use 5.css for the Structure View");
    Application.DisableMacro("Use the default (generated) Structure View");
  }


  // function to disable Annotation Macros
  disableAnnotMacros();

  // call function to disable Version Control Macros
  disableVCMacros();
  
}

]]></MACRO> 
 
<MACRO name="Import Table" lang="JScript" id="1378" tooltip="Import Database Table" desc="Import a table from a database"><![CDATA[
// SoftQuad Script Language JScript:
function RepairXMetaLInstallPath(paramFile) {
	// Open the param.txt
	var iomode = 1;  // ForReading
	var createmode = false; // a new file is NOT created if the specified filename doesn't exist.
	var formatmode = -1;  // Unicode
	if (Application.UnicodeSupported == false) {
		formatmode = 0;  // ASCII
	}

	try {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		var f = fso.OpenTextFile(paramFile, iomode, createmode, formatmode );
	}
	catch(exception) {
		result = reportRuntimeError("Import Table Error:", exception);
		Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
		fso = null;
		rng = null;
		return false;
	}

	// Read the whole file
	var str;
	str = f.ReadAll();
	f.Close();

	// Insert the xmetal install path if necessary.

	if (!str) {
	       Application.Alert("Initialization file for Database Import Wizard is empty.");
		return true; // file empty? Carry on anyway.
	}
	
	var  found = str.search(/XMETAL_INSTALL_PATH/g);
	if (found == -1) {
		return true;  // Not there, don't need to do anything.
	}

	var path = Application.Path;
	str = str.replace(/XMETAL_INSTALL_PATH/g, path);
	
	var iomode = 2;  // ForWriting
	var createmode = true; // a new file is created if the specified filename doesn't exist.
	f = fso.OpenTextFile(paramFile, iomode, createmode, formatmode);
	f.Write(str);

	// Close the text file
	f.Close();
	return true;

}

function doImportTable() {
// Local variables
  var paramFile = Application.Path + "\\Samples\\Cameras\\param.txt";
  var tableFile = Application.Path + "\\Samples\\Cameras\\DBImport.htm";
  
//Fix XmetaL Install Path in param.txt
  if (!RepairXMetaLInstallPath(paramFile)) return;

// Find a place to insert the table
  var rng = ActiveDocument.Range;
  var found = false;
  
  // look forwards
  found = rng.FindInsertLocation("TABLE");
  if (!found)
    // look backwards
    found = rng.FindInsertLocation("TABLE", false);
    
  if (found) {
  
    var result = "";
    // Generate a new, unique, parameter file name
    var newParamFile=Application.UniqueFileName(Application.Path + "\\Samples\\Cameras\\","dbi",".txt");

    // Copy the old parameter file into the new one
    // (so that the wizard won't come up blank)
    if (paramFile != null) {
      try {
        var fso = new ActiveXObject("Scripting.FileSystemObject");
        fso.CopyFile(paramFile,newParamFile);
      }
      catch(exception) {
        result = reportRuntimeError("Import Table Error:", exception);
        Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
        fso = null;
        rng = null;
        return;
      }
      fso = null;
    }

    // Run the wizard
    // Show the dialog
    try {
      var obj = new ActiveXObject("SoftQuad.DBImport");
      var ret = obj.NewDBImport(newParamFile, tableFile);
    }
    catch(exception) {
      result = reportRuntimeError("Import Table Error:", exception);
      Application.Alert(result + "\nPlease register DBImport.dll");
      rng = null;
      obj = null;
      return;
    }
  
    // If user chose OK ...
    if (ret) {

      // Read the resulting table into the document
      var str = Application.FileToString(tableFile);
      rng.TypeText(str);
    
      // The table id is the paramFile, minus the full path
      var splitPath=newParamFile.split('\\');
      var spLength=splitPath.length;
      var tableId=splitPath[spLength-1];
  
      rng.MoveToElement("TABLE", false); // move backwards to table element
      if (rng.ContainerName == "TABLE") {
        rng.ContainerAttribute("border") = "1";  // looks better
        rng.ContainerAttribute("id") = tableId; // for later updates
      }
        
      // Scroll to the location of the inserted table
      rng.Select();
      ActiveDocument.ScrollToSelection();
      Selection.MoveLeft();  // avoid big cursor next to table

      // Copy the new parameter file into the original one
      // (so that the next time the wizard is run, our new parameter file will dictate the initial state)
      if (paramFile!=null) {
        try {
          var fso = new ActiveXObject("Scripting.FileSystemObject");
          fso.CopyFile(newParamFile,paramFile);
        }
        catch(exception) {
          result = reportRuntimeError("Import Table Error:", exception);
          Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
          fso = null;
          rng = null;
          return;
        }
        fso = null;
      }

    }
  }
  else {
    Application.Alert("Can't find insert location for TABLE.");
  } 
  rng = null;
  obj = null;
}
if (CanRunMacros()) {
  doImportTable();
}
]]></MACRO> 
 
<MACRO name="Update Table" lang="JScript" tooltip="Update Imported Table" desc="Update table imported from database" id="1377"><![CDATA[
// SoftQuad Script Language JScript:
function doUpdateTable() {
  // Local variables
  var rng = ActiveDocument.Range;
  var tableFile = Application.Path + "\\Samples\\Cameras\\DBImport.htm";
  
  // Check that we are inside a table
  var node = rng.ContainerNode;
  while (node && node.nodeName != "TABLE") {
    node = node.parentNode;
  }
  
  if (node) {
    // Check we are in the right kind of table
    var tableId = rng.ElementAttribute("id", "TABLE");

    var paramFile = Application.Path + "\\Samples\\Cameras\\" + tableId;
    try {
      var fso = new ActiveXObject("Scripting.FileSystemObject");
    }
    catch(exception) {
      result = reportRuntimeError("Update Table Error:", exception);
      Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
      rng = null;
      return;
    }
    if (fso.FileExists(paramFile)) {
    
      // Insert the new table
      try {
        var obj = new ActiveXObject("SoftQuad.DBImport");
        obj.UpdateDBImport(paramFile, tableFile);
      }
      catch(exception) {
        var result = reportRuntimeError("Update Table Error:", exception);
        Application.Alert(result + "\nPlease register DBImport.dll");
        rng = null;
        obj = null;
        return;
      }

      // Delete the old table
      rng.SelectNodeContents(node);
      rng.SelectElement();
      rng.Delete();

      // Read the resulting table into the document
      var str = Application.FileToString(tableFile);
      rng.TypeText(str);

      // Set the border and id attributes of the table
      rng.MoveToElement("TABLE", false); // move backwards to table element
      if (rng.ContainerName == "TABLE") {
        rng.ContainerAttribute("border") = "1";  // looks better
        rng.ContainerAttribute("id") = tableId; // for later updates
      }

      // Scroll to the location of the inserted table
      rng.MoveLeft();
      rng.Select();
      ActiveDocument.ScrollToSelection();
    }
    else {
      Application.Alert("Parameter file "+paramFile+" does not exist.\nCannot update this table.");
    }
  }
  else {
    Application.Alert("You are not currently inside a table that can be updated.");
  }
  rng = null;
  obj = null;
}

if (CanRunMacros()) {
  doUpdateTable();
}
]]></MACRO> 
 
 
<MACRO name="Revert To Saved" lang="JScript" id="1367" desc="Opens last saved version of the current document"><![CDATA[
if (!ActiveDocument.Saved) {
  if (ActiveDocument.FullName != "") {
    retVal = Application.Confirm("If you continue you will lose changes to this document.\nDo you want to revert to the last-saved version?");
    if (retVal) {
      ActiveDocument.Reload();
    }
  } else {
    Application.Alert("Unable to revert to saved. This document has not been saved.")
  }
}
]]></MACRO> 

<MACRO name="Toggle Rules Checking" lang="JScript" id="1919" desc="Turn Rules Checking On/Off">
<![CDATA[
if (ActiveDocument.RulesChecking) {
  var response = Application.MessageBox("Running macros without rules checking may have unpredictable results.\nDo you want to proceed?", 32+1, "Toggle Rules Checking");
  if (response == 1)  
    ActiveDocument.RulesChecking = false;
}
else {
  ActiveDocument.RulesChecking = true;
  if (!ActiveDocument.RulesChecking) {
    Application.Alert("Could not turn Rules Checking on due to validation errors.");
    ActiveDocument.Validate();
  }
}
]]></MACRO> 
 

<MACRO name="On_Before_Document_Preview" hide="true" lang="JScript"><![CDATA[

  // This macro gets called when the user has selected Page Preview view,
  // or Preview in Browser.  The BrowserURL property is the URL that will 
  // be passed to the browser.  On entry, it contains the URL of a temporary
  // copy of the XML file being edited.  We apply an XSLT stylesheet to create
  // an HTML file and set BrowserURL to be the path to this file.


  
// This macro illustrates the use of the MSXML component to do an
// XSL transformation.  Note that the version of MSXML that ships
// with IE5 is not compliant with the final recommendation of the
// W3C XSLT working group.
function doOnBeforeDocumentPreview() {

  
  // Load the XML document into MSXML
  var result = "";
  var xmlurl = ActiveDocument.BrowserURL;
  try {
    var xmldoc = new ActiveXObject("MSXML2.DOMDocument");
  }
  catch(exception) {
    result = reportRuntimeError("Page Preview Error:", exception);
    Application.Alert(result + "\nYou need to get the latest version of MSXML from the Microsoft site.");
    ActiveDocument.BrowserURL = "";
    return;
  }
  xmldoc.async = false;
  xmldoc.validateOnParse = false;
  xmldoc.load(xmlurl);
  
  // Load the XSL stylesheet
  try {
    var xsldoc = new ActiveXObject("MSXML2.DOMDocument");
  }
  catch(exception) {
    result = reportRuntimeError("Page Preview Error:", exception);
    Application.Alert(result + "\nFailed second use of MSXML.");
    ActiveDocument.BrowserURL = "";
    return;
  }
  var xslurl = Application.PathToUrl(Application.Path + "\\Display\\journalist.xsl");
  xsldoc.async = false;
  xsldoc.load(xslurl);

  var htmlout = "";
  var errPos = "NOERROR";
  if (xmldoc.parseError.errorCode != 0) {
    result = reportParseError(xmldoc.parseError);
    errPos = "XML";
  }
  else
  {
    if (xsldoc.parseError.errorCode != 0) {
      result = reportParseError(xsldoc.parseError);
      errPos = "XSL";
    }
    else
    {
      try {
        htmlout = xmldoc.transformNode(xsldoc);
      }
      catch (exception) {
        result = reportRuntimeError("Page Preview Error:", exception);
        errPos = "TRANSFORMNODE";
      }
    }
  }
  if (result != "") {
    Application.Alert(errPos + " : " + result);
    ActiveDocument.BrowserURL = "";
    return;
  }
    
  // Get name of HTML file for output
  // If the doc is not saved, set the temp file path to "Document".
  var strTempFilePath; 
  if ( ActiveDocument.Path ) {
    strTempFilePath = ActiveDocument.Path;
  } else {
    strTempFilePath = Application.Path + "\\Document";
  }

  // Create the document property for PreviewTempFile.
  var ndlProperties = ActiveDocument.CustomDocumentProperties;
  var ndProperty    = ndlProperties.item( "PreviewTempFile" );

  // Reuse an existing temp file, or create a new one.
  var strTempName;
  if ( ndProperty ) {
    strTempName = ndProperty.value;
  } else {
    strTempName = Application.UniqueFileName( strTempFilePath, "XM", "htm" );
    ndlProperties.Add ( "PreviewTempFile", strTempName );
  }
  
  // HTML output path is the temp file.
  var htmPath = strTempName;

  // Write the resulting HTML
  try {
    var fso = new ActiveXObject("Scripting.FileSystemObject");
  }
  catch(exception) {
    result = reportRuntimeError("Page Preview Error:", exception);
    Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
    ActiveDocument.BrowserURL = "";
    fso = null;
    return;
  }
  var ArgOverwrite = true;
  var ArgUnicode = true;
  if (Application.UnicodeSupported == false) {
    ArgUnicode = false;
  }
  tf = fso.CreateTextFile(htmPath, ArgOverwrite, ArgUnicode);
  tf.Write(htmlout);
  tf.Close();

  // Change the URL to be sent to the browser to the HTML output file
  var htmURL = Application.PathToURL(htmPath);
  ActiveDocument.BrowserURL = htmURL;
  fso = null;
}
doOnBeforeDocumentPreview();
]]></MACRO> 

<MACRO name="On_Document_Close" hide="true" lang="JScript"><![CDATA[

  // Get the document property for PreviewTempFile.
  var ndlProperties = ActiveDocument.CustomDocumentProperties;
  var ndProperty    = ndlProperties.item( "PreviewTempFile" );

  // If the PreviewTempFile exists for this document, delete it.
  if ( ndProperty != null ) {
    try {
      var objFileSystem = new ActiveXObject( "Scripting.FileSystemObject" );
      objFileSystem.DeleteFile( ndProperty.value );
    }
    catch(exception) {
      var result = reportRuntimeError("Document Close Error:", exception);
      Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
    }
    objFileSystem = null;
  }
]]></MACRO>

<MACRO name="Save As HTML" key="" lang="JScript" id="1308" tooltip="Save As HTML" desc="Save document as an HTML file"><![CDATA[

  
// This macro illustrates the use of the MSXML component to do an
// XSL transformation.  Note that the version of MSXML that ships
// with IE5 is not compliant with the final recommendation of the
// W3C XSLT working group.
function doSaveAsHTML() {

  // Get the file used for Browser preview.
  
  try {
    fso = new ActiveXObject("Scripting.FileSystemObject");
  }
  catch(exception) {
    result = reportRuntimeError("Save As HTML Error:", exception);
    Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
    fso = null;
    return;
  }
  var strTempName = ActiveDocument.CreatePreviewFile();
  
  var result = "";
  // Load the XML document into MSXML
  var xmlurl = Application.PathToUrl(strTempName);
  try {
    var xmldoc = new ActiveXObject("MSXML2.DOMDocument");
  }
  catch(exception) {
    result = reportRuntimeError("Save As HTML Error:", exception);
    Application.Alert(result + "\nYou need to get the latest version of MSXML from the Microsoft site.");
    fso.DeleteFile(strTempName);
    fso = null;
    return;
  }
  xmldoc.async = false;
  xmldoc.validateOnParse = false;
  xmldoc.load(xmlurl);
  
  // Load the XSL stylesheet
  try {
    var xsldoc = new ActiveXObject("MSXML2.DOMDocument");
  }
  catch(exception) {
    result = reportRuntimeError("Save As HTML Error:", exception);
    Application.Alert(result + "\nFailed second use of MSXML.");
    fso.DeleteFile(strTempName);
    fso = null;
    return;
  }
  var xslurl = Application.PathToUrl(Application.Path + "\\Display\\journalist.xsl");
  xsldoc.async = false;
  xsldoc.load(xslurl);

  var htmlout = "";
  var errPos = "NOERROR";
  if (xmldoc.parseError.errorCode != 0) {
    result = reportParseError(xmldoc.parseError);
    errPos = "XML";
  }
  else
  {
    if (xsldoc.parseError.errorCode != 0) {
      result = reportParseError(xsldoc.parseError);
      errPos = "XSL";
    }
    else
    {
      try {
        htmlout = xmldoc.transformNode(xsldoc);
      }
      catch (exception) {
        result = reportRuntimeError("Save As HTML Error:", exception);
        errPos = "TRANSFORMNODE";
      }
    }
  }
  if (result != "") {
    Application.Alert(errPos + " : "+result);
    fso.DeleteFile(strTempName);
    fso = null;
    return;
  }
  var dlog;
  
  // Get name of HTML file for output
  htmPath = ActiveDocument.FullName;
  
  // if the document hasn't been saved yet, get a file name from the user
  if (htmPath == "") {
    try {
      dlog = new ActiveXObject("SQExtras.FileDlg");
    }
    catch(exception) {
      result = reportRuntimeError("Save As HTML Error:", exception);
      Application.Alert(result + "\nPlease register SQExtras.dll.");
      fso.DeleteFile(strTempName);
      fso = null;
      dlog = null;
      return;
    }
    if (dlog.DisplayFileDlg(false, "HTML Save As","HTML Files (*.htm)|*.htm|All Files (*.*)|*.*||", Application.Path + "\\Document", "htm")) {
      var htmPath = dlog.FullPathName;
    }
    else {
      fso.DeleteFile(strTempName);
      fso = null;
      dlog = null;
      return;
    }
  }
  
  // Document has been saved so just put new ending on the filetitle if it is ok with user
  else {
    htmPath = htmPath.replace(/\.xml/i, "\.htm");
    var exists = Application.FileExists(htmPath);
    var response = 6;  //YES
    if (exists) {
      response = Application.MessageBox(htmPath+" already exists.\nDo you want to replace it?", 32+3, "Save As HTML");
    }
    if (response == 7) { //NO
      try {
        dlog = new ActiveXObject("SQExtras.FileDlg");
      }
      catch(exception) {
        result = reportRuntimeError("Save As HTML Error:", exception);
        Application.Alert(result + "\nPlease register SQExtras.dll.");
        fso.DeleteFile(strTempName);
        fso = null;
        dlog = null;
        return;
      }
      if (dlog.DisplayFileDlg(false, "HTML Save As","HTML Files (*.htm)|*.htm|All Files (*.*)|*.*||", ActiveDocument.Path, "htm")) {
        var htmPath = dlog.FullPathName;
      }
      else {
        fso.DeleteFile(strTempName);
        fso = null;
        dlog = null;
        return;
      }
    }
    else if (response == 2) { //CANCEL
      fso.DeleteFile(strTempName);
      fso = null;
      dlog = null;
      return;
    }
  }
  
  Application.MessageBox ("HTML written to "+ htmPath, 64, "Save As HTML");
  
  // Write the resulting HTML
  var ArgOverwrite = true;
  var ArgUnicode = true;
  if (Application.UnicodeSupported == false) {
    ArgUnicode = false;
  }
  tf = fso.CreateTextFile(htmPath, ArgOverwrite, ArgUnicode);
  tf.Write(htmlout);
  tf.Close();

  // Delete the temporary XML file
  fso.DeleteFile(strTempName);
  fso = null;
  tf = null;
  dlog = null;
 
}

if (CanRunMacros()) {
  doSaveAsHTML();
}

]]></MACRO>

<MACRO name="Import From Word" key="" lang="JScript" id="1306" tooltip="Import From Word" desc="Create new document from an MS Word document"><![CDATA[
function Do_ImportFromWord() {

  try {
    var app = new ActiveXObject("Word.Application");
  }
  catch(exception) {
    var result = reportRuntimeError("Word Import Error:", exception);
    Application.Alert(result + "\nYou need to install MS Word.");
    app = null;
    return;
  }
  
  // Choose the Word doc
  try {
    var obj = new ActiveXObject("SQExtras.FileDlg");
  }
  catch(exception) {
    var result = reportRuntimeError("Word Import Error:", exception);
    Application.Alert(result + "\nYou need to register SQExtras.dll.");
    app = null;
    obj = null;
    return;
  }
  if (!obj.DisplayFileDlg(true, "Open Word Document", "Word Documents (*.doc)|*.doc|All Files (*.*)|*.*||")) return;  // user cancelled
  var name = obj.FullPathName;
  obj = null;
  var exists=Application.FileExists(name);
  if (!exists) {
  	Application.Alert("Could not do import from Word.\nDocument "+name + " does not exist.", "Import From Word");
    	app = null;
  	return;
  }
  
  // Open a template to put the text file into
  var textFile = Application.Path + "\\Template\\IFWtext.tmp";
  var template = Application.Path + "\\Template\\Journalist_IFW.xml";
  if (!Application.ReadableFileExists(template)) {
    Application.Alert("Could not find the import template\n" + template);
    app = null;
    return;
  }
  var curDoc = Application.ActiveDocument;
  var viewtype;
  if (!curDoc) viewtype = sqViewNormal;
  else viewtype = curDoc.ViewType;
    
  var doc = Documents.OpenTemplate(template);
  doc.ViewType = viewtype;
  var rng = doc.Range;

  // Use Word to convert doc to text file
  var wordFile = name;
  var fileFormat = 7;  // wdFormatUnicodeText
  if (Application.UnicodeSupported == false) {
    fileFormat = 2;  // wdFormatText
  }
  app.Documents.Open(wordFile);
  app.ActiveDocument.SaveAs(textFile, fileFormat);
  app.Quit();
  app = null;

  // Open the text file
  var iomode = 1;  // ForReading
  var createmode = false; // a new file is NOT created if the specified filename doesn't exist.
  var formatmode = -1;  // Unicode
  if (Application.UnicodeSupported == false) {
    formatmode = 0;  // ASCII
  }
  try {
    var fso = new ActiveXObject("Scripting.FileSystemObject");
    var f = fso.OpenTextFile(textFile, iomode, createmode, formatmode );
  }
  catch(exception) {
    result = reportRuntimeError("Word Import Error:", exception);
    Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
    fso = null;
    rng = null;
    return;
  }

  // Put the remaining lines into separate paragraphs
  var str;
  rng.MoveToElement("Sect1");
  rng.MoveToElement("Para");
  while (!f.AtEndOfStream) {
    str = f.ReadLine();
    if (str) {
      str = str.replace(/&/g,"&amp;");
      str = str.replace(/</g,"&lt;");
      str = str.replace(/>/g,"&gt;");
      rng.TypeText(str);
      rng.SelectAfterContainer();
      rng.InsertElement("Para");
    }
  }
  // Delete that last empty paragraph
  rng.SelectElement();
  rng.Delete();

  // Close the text file
  f.Close();

  // Make the title look better
  rng.MoveToDocumentStart();
  rng.MoveToElement("Title");
  rng.SelectContainerContents();
  rng.TypeText("Type Title Here");
  rng = null;
  fso = null;
}

// Call the function here
if (CanRunMacros()) {
  Do_ImportFromWord();
}
]]></MACRO> 

<MACRO name="Convert to Subsection" key="Ctrl+Alt+B" lang="JScript" id="1723" tooltip="Convert to Subsection" desc="Change current Para into the Title of a subsection"><![CDATA[
// Convert current paragraph and  everything below it into a new section.
function doConvertToSubsection() {
  if (Selection.IsParentElement("Para")) {
    if (Selection.IsParentElement("Sect4")) Application.Alert("No more levels of subsections available");
    else if (Selection.IsParentElement("Sect3")) StartNewSubsection("Sect4");
    else if (Selection.IsParentElement("Sect2")) StartNewSubsection("Sect3");
    else if (Selection.IsParentElement("Sect1")) StartNewSubsection("Sect2");
    else StartNewSubsection("Sect1");
  }
  else
    Application.Alert("Place insertion point in the paragraph that will become the title of the subsection");
}

if (CanRunMacros()) {
  doConvertToSubsection();
}
]]></MACRO> 
 
<MACRO name="Convert to Section" key="Ctrl+Alt+C" lang="JScript" id="1722" tooltip="Convert to Section" desc="Change current Para into the Title of a new Section at same level as current Section"><![CDATA[
// Convert current paragraph and  everything below it into a new section at the same
// level as the section currently in.
function doConvertToSection() {
  if (Selection.IsParentElement("Para")) {
      if (Selection.IsParentElement("Sect1") || 
          Selection.IsParentElement("Sect2") ||
          Selection.IsParentElement("Sect3") ||
          Selection.IsParentElement("Sect4")) {
        var paraName = "Para";
        var titleName = "Title";
      
        var rng = ActiveDocument.Range;
        var strBody = "";
        var strTitle = "";
      
        // Use the current Para for the Title of the new section
        var node = rng.ContainerNode;
        while (node.nodeName != paraName) {
          node = node.parentNode;
        }
      
        rng.SelectNodeContents(node);
        strTitle = rng.Text;
        rng.SelectElement();
        rng.Delete();
      
        // Copy the rest to a string
        var rng2 = rng.Duplicate;
        node = rng.ContainerNode;
        if (node.lastChild) {
          rng.SelectAfterNode(node.lastChild);
          rng2.ExtendTo(rng);
        }
        strBody = rng2.Text;
        rng2.Delete();
      
        // Put in the new section
        node = rng.ContainerNode;
        rng.SelectAfterContainer();
        rng.InsertElement(node.nodeName);
        rng.InsertElement(titleName);
        rng.TypeText(strTitle);
        rng.SelectAfterContainer();
        if (strBody != "") rng.TypeText(strBody);
        rng.MoveToElement(titleName, false);
        rng.Select();
        rng = null;
        rng2 = null;
      }
      else if (Selection.IsParentElement("Para")) {
        StartNewSubsection("Sect1");
      }
  }
}
if (CanRunMacros()) {
  doConvertToSection();
}
]]></MACRO> 
 
<MACRO name="Convert to Paragraph" key="" lang="JScript" id="20341" tooltip="Convert Subsection to Paragraph" desc="Put cursor in the Title of the section to convert to paragraphs"><![CDATA[
// Convert current Section title to a paragraph.
function doConvertToParagraph() {
  var node = Selection.ContainerNode;
  if ((Selection.IsParentElement("Sect1") ||
      Selection.IsParentElement("Sect2") ||
      Selection.IsParentElement("Sect3") ||
      Selection.IsParentElement("Sect4")) &&
      node.nodeName == "Title") {
    var paraName = "Para";
    var titleName = "Title";
  
    var rng = ActiveDocument.Range;
    var strBody = "";
    var strTitle = "";
  
    // Save title
    rng.SelectNodeContents(node);
    strTitle = rng.Text;

    // Save the Section body
    rng.SelectAfterContainer();
    var rng2 = rng.Duplicate;
    node = rng.ContainerNode;
    var sectName = node.nodeName;
    rng.SelectAfterNode(node.lastChild);
    rng2.ExtendTo(rng);
    strBody = rng2.Text;

    // Find out if the section we're changing to a paragraph contains any subsections
    var containsSections = 0;
    var nodeCheck = node.firstChild;
    while (nodeCheck) {
      if (sectName == "Sect1" && nodeCheck.nodeName == "Sect2") containsSections = 1;
      else if (sectName == "Sect2" && nodeCheck.nodeName == "Sect3") containsSections = 1;
      else if (sectName == "Sect3" && nodeCheck.nodeName == "Sect4") containsSections = 1;
      nodeCheck = nodeCheck.nextSibling;
    }

    // Find out if the section we're changing has any sibling sections before it
    var prevSectnode = node.previousSibling;
    while (prevSectnode.nodeType != 1) // 1 == DOMElement
      prevSectnode = prevSectnode.previousSibling;
    // Save where to delete the whole section
    var rngDelete = rng.Duplicate;

    // Changing to a paragraph may be an invalid thing to do
    var changeValid = 1;
    if (prevSectnode.nodeName == sectName) {
      // Find out if the previous section contains any subsections
      var prevContainsSections = 0;
      nodeCheck = prevSectnode.firstChild;
      while (nodeCheck) {
        if ((nodeCheck.nodeName == "Sect2") || (nodeCheck.nodeName == "Sect3") || (nodeCheck.nodeName == "Sect4")) prevContainsSections = 1;
        nodeCheck = nodeCheck.nextSibling;
      }

      // If there are subsections in the previous sibling section AND the section being
      // changed has subsections then the subsections would have to be demoted or the
      // section would have to be split into its paragraphs and sections -- way too
      // complicated -- let's not do it
      if (prevContainsSections == 1 && containsSections == 1) {
        changeValid = 0;
        Application.Alert("This section contains subsections -- can't change to paragraphs.");
      }
      else {
        // If we don't contain sections then find the last para or title and go after it
        node = prevSectnode.lastChild;
        rng.SelectAfterNode(node);
        rng.FindInsertLocation(paraName, false);
      }
    }
    // There are just paragraphs before this -- promote all the subsections
    else {
      strBody = strBody.replace(/Sect2>/g, "Sect1>");
      strBody = strBody.replace(/Sect3>/g, "Sect2>");
      strBody = strBody.replace(/Sect4>/g, "Sect3>");
      
      // Fix the replaceable text
      strBody = strBody.replace(/xm-replace_text Section 2 Title/g, "xm-replace_text Section 1 Title");
      strBody = strBody.replace(/xm-replace_text Section 3 Title/g, "xm-replace_text Section 2 Title");
      strBody = strBody.replace(/xm-replace_text Section 4 Title/g, "xm-replace_text Section 3 Title");
    }

    // Select the section that we're planning to change


    if (changeValid == 1) {
      // Delete the whole section
      rngDelete.SelectElement();
      rngDelete.Delete();
 
      // Now insert the section as a Para 
      rng.InsertElement(paraName);
      rng.Select();
      strTitle = strTitle.replace(/xm-replace_text Section \d Title/g, "xm-replace_text Paragraph");
      rng.TypeText(strTitle);
      rng.SelectAfterContainer();
      if (strBody != "") rng.TypeText(strBody);
    }
    // Not valid change -- put insertion point in the title of the section
    else {
      Application.Alert("Change not valid");
      node = rngDelete.ContainerNode.firstChild;
      rng.SelectNodeContents(node);
      rng.Collapse(sqCollapseStart);
      rng.Select();
    }
    rng = null;
    rng2 = null;
  }
  else {
    Application.Alert("Put insertion pointer on the title of the subsection you want to convert");
  }
}

if (CanRunMacros()) {
  doConvertToParagraph();
}
 ]]></MACRO> 
 
<MACRO name="Convert to Article Title" key="" lang="JScript" id="1249" tooltip="Convert to Article Title" desc="Copy current Para to the Article Title"><![CDATA[
// Convert current selection or current paragraph to the Article title.  Overwrite title if there is one.
function doConvertToTitle() {
  if (Selection.IsParentElement("Para") || Selection.IsParentElement("Title")) {
    var rng = ActiveDocument.Range;
    if (rng.IsInsertionPoint) {
      rng.SelectContainerContents();
    }
    var title = rng.Text;            // save the text of the paragraph
    rng.MoveToDocumentStart();
    if (!rng.MoveToElement("Title")) { // move to the Title
      rng.MoveToDocumentStart();        // insert Title if it's not there
      rng.MoveToElement("Article");
      rng.InsertElement("Title");
    }
    rng.SelectContainerContents();   // select Title element
    rng.PasteString(title);          // Paste in the saved text.
    rng = null;
  }
}

if (CanRunMacros()) {
  doConvertToTitle();
}
]]></MACRO> 
 
<MACRO name="Join Paragraphs" key="" lang="JScript" id="1018" tooltip="Join Paragraphs" desc="Join selected paragraphs together into one paragraph"><![CDATA[
// Joins all selected paragraphs into one paragraph
function doJoinParagraphs() {
  var rng = ActiveDocument.Range;
  if (rng.IsInsertionPoint) {
    Application.Alert("Select the paragraphs to join");
  }
  else {
    var rng2 = rng.Duplicate;
    rng.Collapse(sqCollapseStart);  // the beginning of the selection
    rng.MoveToElement("Para");  // Go to first paragraph in the selection
    var nd = rng.ContainerNode; // determine the element containing the Para
    var parent = nd.parentNode;

    rng2.Collapse(sqCollapseEnd);  // the end of the selection
    rng2.MoveToElement("Para", false);  // Go to last paragraph in the selection
    var nd2 = rng2.ContainerNode; // determine the element containing the Para
    var parent2 = nd2.parentNode;

    // check that the elements moved to are "Para"s
    if (rng.ContainerName == "Para" && rng2.ContainerName == "Para") {
      rng.SelectContainerContents();
      rng2.SelectContainerContents();
      if (!rng2.IsGreaterThan(rng)) {
        Application.Alert("Select the paragraphs to convert to one paragraph");
      }
      else {
        if (parent == parent2) { // join paragraphs only if contained in same element
          var rng2Node = rng2.ContainerNode;
          var rng2PrevSib = rng2Node.previousSibling;
          while (rng2PrevSib && (rng2PrevSib.nodeType != 1)) // 1 == DOMElement
            rng2PrevSib = rng2PrevSib.previousSibling;
          while (rng2PrevSib && rng2.IsGreaterThan(rng) // Start from the end and join paragraphs one by one
                 && (rng2PrevSib.nodeName == "Para")) { // Stop if an element other than Para is encountered
            rng2.JoinElementToPreceding();
            rng2.SelectContainerContents();
            rng2Node = rng2.ContainerNode;
            rng2PrevSib = rng2Node.previousSibling;
            while (rng2PrevSib && (rng2PrevSib.nodeType != 1)) // 1 == DOMElement
              rng2PrevSib = rng2PrevSib.previousSibling;
          }
          rng2.Select();    // Select the resultant paragraph.
        }
        else {
          Application.Alert("Cannot join paragraphs since they are in separate elements");
        }
      }
    }
    else {
      Application.Alert("Select the paragraphs to convert to one paragraph");
    }
    rng2 = null;
  }
  rng = null;
}

if (CanRunMacros()) {
  doJoinParagraphs();
}
]]></MACRO> 
 
<MACRO name="Promote Section" key="Ctrl+Alt+P" lang="JScript" id="20111" tooltip="Promote Section" desc="Convert current section to next-higher level section"><![CDATA[
// Convert current section into a section 1 smaller. ie. Sect2 to Sect1
function doPromoteSection() {
  // Selection must be in a title.
  var containNode = Selection.ContainerNode;
    if (containNode && containNode.nodeName == "Title") {
    // Not valid for Sect
    if (Selection.IsParentElement("Sect2") || Selection.IsParentElement("Sect3") || Selection.IsParentElement("Sect4")) {

      var rng = ActiveDocument.Range;
      var strTitle = "";
      var strBody = "";
      var strRest = "";
 
      // Copy the title of the section
      var node = rng.ContainerNode;
      rng.SelectNodeContents(node);
      strTitle = rng.Text;
    
      // Copy the rest the section to a string
      rng.SelectAfterContainer();
      var rng2 = rng.Duplicate;
      node = rng.ContainerNode;
      rng.SelectAfterNode(node.lastChild);
      rng2.ExtendTo(rng);
      strBody = rng2.Text;

      // Delete the section
      rng.SelectElement();
      rng.Delete();

      // Fix the subsections of the section we are promoting
      strBody = strBody.replace(/Sect2>/g, "Sect1>");
      strBody = strBody.replace(/Sect3>/g, "Sect2>");
      strBody = strBody.replace(/Sect4>/g, "Sect3>");

      // Fix the replaceable text
      strBody = strBody.replace(/xm-replace_text Section 2 Title/g, "xm-replace_text Section 1 Title");
      strBody = strBody.replace(/xm-replace_text Section 3 Title/g, "xm-replace_text Section 2 Title");
      strBody = strBody.replace(/xm-replace_text Section 4 Title/g, "xm-replace_text Section 3 Title");
      strTitle = strTitle.replace(/xm-replace_text Section 2 Title/g, "xm-replace_text Section 1 Title");
      strTitle = strTitle.replace(/xm-replace_text Section 3 Title/g, "xm-replace_text Section 2 Title");
      strTitle = strTitle.replace(/xm-replace_text Section 4 Title/g, "xm-replace_text Section 3 Title");
      
      // Save the rest of the parent section
      rng2 = rng.Duplicate;
      node = rng.ContainerNode;
      rng.SelectAfterNode(node.lastChild);
      rng2.ExtendTo(rng);
      strRest = rng2.Text;
      rng2.Delete();

      // Put in the new section
      node = rng.ContainerNode;
      rng.SelectAfterContainer();
      rng.InsertElement(node.nodeName);

      // Insert the title and leave the selection there.
      rng.InsertElement("Title");
      rng.TypeText(strTitle);
      rng.Select();

      // Insert the rest of the section that is being promoted
      rng.SelectAfterContainer();
      if (strBody != "") rng.TypeText(strBody);

      // Insert the last part as child to our new section
      node = rng.ContainerNode;
      rng.SelectAfterNode(node.lastChild);
      if (strRest != "") rng.TypeText(strRest);

      rng = null;
      rng2 = null;
    }
    else Application.Alert("This section is already a top level section");
  }
  else Application.Alert("Put your insertion cursor inside the title of the section you want to promote");
}
if (CanRunMacros()) {
  doPromoteSection();
}
]]></MACRO> 
 
<MACRO name="Demote Section" key="Ctrl+Alt+D" lang="JScript" id="20110" tooltip="Demote Section" desc="Convert current section to next-lower level section"><![CDATA[
// Convert current section into a section 1 bigger.  eg. Sect1 to Sect2
function doDemoteSection() {
  // Selection must be in a title.
    var containNode = Selection.ContainerNode;
    if (containNode && containNode.nodeName == "Title") { 
    // If Sect4 or contains Sect4, can't do it!
    var rng = ActiveDocument.Range;
    rng.SelectElement();
    var node = rng.ContainerNode;  // the section node
    var elemlist = node.getElementsByTagName("Sect4");
    // Ask explicitly just to rule out anything crazy
    var sectName = node.nodeName;
    if ((sectName == "Sect1" || sectName == "Sect2" || sectName == "Sect3")
         && (elemlist.length == 0)) {
      // Also can't do it if there is no section at same level as this one before this one.
      rng.SelectBeforeNode(node);       // just before the section to be demoted
      var rngSave = rng.Duplicate;      // save this spot
      node = rng.ContainerNode;         // The parent section
      rng.SelectNodeContents(node);
      rng.Collapse(sqCollapseStart);    // The beginning of the contents of the parent sect
      rng.MoveToElement(sectName);      // Find the first section at the same level
      rng.SelectBeforeContainer();      // Just before the first section found
      if (rngSave.IsGreaterThan(rng)) {  // There is a section at same level before it

        var strTitle = "";
        var strBody = "";
        var strRest = "";
 
        rngSave.MoveToElement(sectName);  // Find the section to be demoted again
        rngSave.SelectElement();
        strBody = rngSave.Text;
        rngSave.Delete();
        
        // Fix the tags of the section we are demoting
        strBody = strBody.replace(/Sect3>/g, "Sect4>");
        strBody = strBody.replace(/Sect2>/g, "Sect3>");
        strBody = strBody.replace(/Sect1>/g, "Sect2>");
        
        // Fix the replaceable text
        strBody = strBody.replace(/<\?xm-replace_text Section 3 Title\?>/g, "<\?xm-replace_text Section 4 Title\?>");
        strBody = strBody.replace(/<\?xm-replace_text Section 2 Title\?>/g, "<\?xm-replace_text Section 3 Title\?>");
        strBody = strBody.replace(/<\?xm-replace_text Section 1 Title\?>/g, "<\?xm-replace_text Section 2 Title\?>");

        rngSave.MoveToElement(sectName, false);  // Find sibling before it
        rngSave.SelectContainerContents();
        rngSave.Collapse(sqCollapseEnd);         // inside the end of the sibling
        rng = rngSave.Duplicate;
        if (strBody != "") rngSave.TypeText(strBody);
        rng.MoveToElement("Title");
        rng.Select();

      }
      else Application.Alert("There has to be a section of the same level before this one");
    }
    else Application.Alert("This section is (or contains) a bottom level section");
    rng = null;
  }
  else Application.Alert("Put your insertion cursor inside the title of the section you want to demote");
}
if (CanRunMacros()) {
  doDemoteSection();
}
]]></MACRO> 

<MACRO name="On_Macro_File_Load" hide="false" lang="JScript"><![CDATA[

  var sqDefaultCursor = 0;
  var sqViewNormal = 0;
  var sqViewTagsOn = 1;
  var sqViewPlainText = 2;
  var sqCollapseEnd = 0;
  var sqCollapseStart = 1;
  var sqCursorHand = 4;
  var sqCursorArrow = 1;

var monthArray = new Array("January", "February", "March",
  "April", "May", "June", "July", "August", "September",
  "October", "November", "December");
var dateElems = new Array("PubDate");
var afDocumentComplete = true;

function num02(num)
{
  if (num < 10)
    return "0" + num;
  else
    return num + "";
}

function convertFromISODate(date)
{
  // date will have form YYYYMMDD. E.g. "19990214"
  // Return value will be Month DD, YYYY. E.g. "February 14, 1999"
  var year = date.substring(0, 4);
  var month = date.substring(4, 6) - 1;
  var day = date.substring(6, 8);
  if (month < 0 || year == "0000") {
    // date wasn't initialized
    // Use current time of day.
    var tod = new Date();
    year = tod.getYear();
    month = tod.getMonth();
    day = tod.getDate();
  }
  return monthArray[month] + " " + day + ", " + year;
}

function convertToDateArray(date)
{
  // Date will have form "February 14, 1999" and will
  // be returned as the array of numbers (1999, 2, 14).
  var dateArray = new Array(1, 1, 1);
  var r = date.match(/^(\S+)\s+([^,]+),\s(.*)$/);
  var i;

  // Convert the month to a number
  for (i=0; i<12; i++) {
    if (RegExp.$1 == monthArray[i]) {
      dateArray[1] = i+1;
      break;
    }
  }

  // Convert the day and year to numbers
  dateArray[2] = RegExp.$2 - 0; //day
  dateArray[0] = RegExp.$3 - 0; // year}

  return dateArray;
}

function fixISODates(fixNewOnly)
{
  var r = ActiveDocument.Range;
  var i;
  for (i = 0; i < 1; i++) {
    var elemName = dateElems[i];
    r.MoveToDocumentStart();
    while (r.MoveToElement(elemName, true)) {
      var cnode = r.ContainerNode;
      if (fixNewOnly &&
        !ActiveDocument.GetNodeState("NewNode", cnode) &&
        !ActiveDocument.GetNodeState("ContentInserted", cnode) &&
        !ActiveDocument.GetNodeState("ContentDeleted", cnode))
      {
        continue;
      }
      else {
        r.SelectContainerContents();
        var date = r.Text;
        if (date.substring(0, 4) == "0000") {
          // Not a valid date. Set to today's date.
          var tod = new Date();
          date = tod.getYear() + num02(tod.getMonth()+1) +
              num02(tod.getDate());
          r.ReadOnlyContainer = false;
          r.Text = date;
        }
        ActiveDocument.SetRenderedContent
          (r.ContainerNode, convertFromISODate(date));
        r.ReadOnlyContainer = true;
      }
    }
  }
  r = null;
  ActiveDocument.ClearAllChangedStates();
}

function hasChildPIs(children)
{
  var i = 0;
  var child = children.item(i);
  while (child) {
    if (child.nodeType == 7) { // PROCESSING_INSTRUCTION
      return i;
    }
    ++i;
    child = children.item(i);
  }
  return -1;
}

function setTextField(nodeName, field, children, rng)
{
  try {
    var i = 0;
    var child = children.item(i);
    while (child) {
      if (child.nodeName == nodeName) {
        if (hasChildPIs(child.childNodes) == -1) {
          rng.SelectNodeContents(child);
          field.value = rng.Text;
          return;
        } else {
          field.value = "";
          return;
        }
      }
      ++i;
      child = children.item(i);
    }
  } catch(e) {
    Application.Alert("Set Text Field\nError " + (e.number&0xFFFF) + ": " + e.description);
  }
}

function getDTDName()
{
   var macroFN = ActiveDocument.MacroFile;
   var slash = macroFN.lastIndexOf("\\");
   var dot = macroFN.lastIndexOf(".");
   var dtdName = macroFN.substring(slash+1, dot);
   return dtdName;
}

function getStructureViewStylesFileName()
{
  var dtdName = getDTDName();

  // find the 2 possible paths for the SV styles file
  // (svsfn = structure view styles file name)
  var svsfn;
  var svsfnWithDoc = ActiveDocument.Path       + "\\" + dtdName + "_structure.css";
  var svsfnInSQDir = Application.Path + "\\display\\" + dtdName + "_structure.css";

  // figure out which one XMetaL is using
  try {
    var fso = new ActiveXObject("Scripting.FileSystemObject");
  }
  catch(exception) {
    result = reportRuntimeError("Structure View Styles Error:", exception);
    Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
    return svsfnInSQDir;
  }
  if (fso.FileExists(svsfnWithDoc)) {
    svsfn = svsfnWithDoc;
  } else {
    svsfn = svsfnInSQDir;
  }
  return svsfn;
}

function switchSVStyles(fileName)
{
  try {
    var fso = new ActiveXObject("Scripting.FileSystemObject");
  }
  catch(exception) {
    var result = reportRuntimeError("Structure View Styles Error:", exception);
    Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
    return;
  }
  try {
    var svsfn = getStructureViewStylesFileName();
    if (fileName) {
      // copy the new one over top of the current one
      var tail = svsfn.lastIndexOf("_structure.css");
      var newSVSFN = svsfn.substring(0, tail+1) + fileName;
      if (fso.FileExists(newSVSFN)) {
         var newCSS = fso.GetFile(newSVSFN);
         newCSS.Copy(svsfn);
      } else {
         Application.Alert(newSVSFN + " does not exist.");
      }
    } else {
      // delete the current one to force XMetaL to generate the default one
      var cssFile = fso.GetFile(svsfn);
      cssFile.Delete();
    }
    ActiveDocument.RefreshCssStyle();
  }
  catch (exception) {
    var result = reportRuntimeError("Structure View Styles Error:", exception);
    Application.Alert(result + "\nUse menu item View/Structure View to display Structure View or\nCheck that all journalist css files in \\Display are not read-only.");
  }
}

// Parse error formatting function
function reportParseError(error)
{
  var r = "XML Error loading '" + error.url + "'.\n" + error.reason;
  if (error.line > 0)
    r += "at line " + error.line + ", character " + error.linepos +"\n" + error.srcText;
  return r;
}

// Run-time error formatting function
function reportRuntimeError(preface, exception)
{
  return preface + " " + exception.description;
}


function getAnnot_ReMa_Styles(element, insideAnnotation){
  var docProps_in = ActiveDocument.CustomDocumentProperties;
  var highlighting_in = docProps_in.item("Highlighting").value;
  var hideannotations_in = docProps_in.item("HideAnnotations").value;
  var style = "";
  if(highlighting_in == "True"){
    if(insideAnnotation){
      if(hideannotations_in == "False"){
        if(element == "Insertion" || element == "Annotation_in_Insertion"){
          style = "color:red;background-color:yellow;text-decoration:underline";
        } else if(element == "Deletion" || element == "Annotation_in_Deletion"){
          style = "color:red;background-color:yellow;text-decoration:line-through";
        } else {            
          style =  "color:black;background-color:yellow";
        }
          
      } else {
        if(element == "Insertion" || element == "Annotation_in_Insertion"){
          style = "color:red;background-color:white;text-decoration:underline";
        } else if(element == "Deletion" || element == "Annotation_in_Deletion"){
          style = "color:red;background-color:white;text-decoration:line-through";
        } else {
          style =  "color:black;background-color:white";
        }
      }
    } else {
      if(element == "Insertion" || element == "Annotation_in_Insertion"){
        style = "color:red;background-color:white;text-decoration:underline";
      } else if(element == "Deletion" || element == "Annotation_in_Deletion"){
        style = "color:red;background-color:white;text-decoration:line-through";
      } else {
        style =  "color:black;background-color:white";
      }
    }
  } else {
    if(insideAnnotation){
      if(hideannotations_in == "False"){
        if(element == "Insertion" || element == "Annotation_in_Insertion"){
          style = "color:black;background-color:yellow";
        } else if(element == "Deletion" || element == "Annotation_in_Deletion"){
          style = "color:black;background-color:yellow";
        } else {
          style =  "color:black;background-color:yellow";
        }
      } else {
        style =  "color:black;background-color:white";
      }
    } else {
      style = "color:black;background-color:white";
    }
  }
  return (style);
}

var UserName;

// Global function for Revision Control and Annotation 
function InitUserData(){
  var environ = new ActiveXObject("WScript.Network");
  UserName = environ.username;
}
  
InitUserData(); 

]]></MACRO> 
 
<MACRO name="Insert PubDate" key="Ctrl+Alt+T" lang="JScript" id="1915" tooltip="Insert PubDate" desc="Insert or update Publication Date element to the current date"><![CDATA[
function doInsertPubDate() {

  var PubDateList = ActiveDocument.getElementsByTagName("PubDate");
  var Rng = ActiveDocument.Range;
  Rng.MoveToDocumentStart();
  
  if (PubDateList.length > 0) {
    Rng.MoveToElement("PubDate");
    Rng.Select();
    Application.Alert("PubDate already present - click on it to change the date.");
    
  } else {

    if (Rng.FindInsertLocation("PubDate")) {
      Rng.InsertElement("PubDate");
      Rng.TypeText("0000");
      fixISODates(true);
      Rng.Select();
    } else {
      Application.Alert("Could not find insert location for PubDate");
    }
  }
  Rng = null;
}

if (CanRunMacros()) {
  doInsertPubDate();
}

]]></MACRO> 

<MACRO name="On_Click" hide="true" lang="jscript"><![CDATA[
function OnClick()
{
  var i;
  var nodeName = Selection.ContainerName;
  for (i = 0; i < 1; i++) {
    if (nodeName == dateElems[i]) {
      var dlg = CreateFormDlg(Application.Path + "/Forms/Calendar.hhf");
      if (!dlg) {
        Application.Alert("You need the calendar form\n"+Application.Path+"\\Forms\\Calendar.hhf");
        return;
      }
      var r = Selection.Duplicate;
      r.SelectContainerContents();
      //var dateArray = convertToDateArray(r.Text);
      var dateArray = convertToDateArray(ActiveDocument.GetRenderedContent(r.ContainerNode));
      var calendar = dlg.UserForm.Calendar;
      calendar.Year = dateArray[0];
      calendar.Month = dateArray[1];
      calendar.Day = dateArray[2];
      var ret = dlg.DoModal();
      if (ret == 1) {
        r.ReadOnlyContainer = false;
        //r.Text = monthArray[calendar.Month-1] + " " +
        //     calendar.Day + ", " + calendar.Year;
        r.Text = calendar.Year + num02(calendar.Month) + num02(calendar.Day);
        r.ReadOnlyContainer = true;
        ActiveDocument.SetRenderedContent
          (r.ContainerNode,
           monthArray[calendar.Month-1] + " " +
             calendar.Day + ", " + calendar.Year);
      }
      dlg = "";
      r = null;
      break;
    }
  }
}
OnClick();
]]></MACRO> 

<MACRO name="On_Mouse_Over" hide="true" lang="JScript"><![CDATA[

var MouseOverElem_Array = new Array("Annotation"); 

function isParentElement(ElemName, node) {
    while (node) {
       if (node.nodeName == ElemName)
         return true;
       node = node.parentNode;
    }
    return false;
}

function OnMouseOver()
{
  // initialize in case mouse out was never called
  Application.SetStatusText("");
  Application.SetCursor(sqDefaultCursor);
  
  var curNode = Application.MouseOverNode;
  if (curNode) {
    var nodeName = curNode.NodeName;
    if (nodeName == "PubDate") {
      Application.SetCursor(sqCursorHand);
      var rng = ActiveDocument.Range;
      rng.SelectNodeContents(curNode);
      rng.ContainerStyle = "color:red";
      rng = null;
      return;
    }
    if (nodeName == "ULink") {
      var rng = ActiveDocument.Range;
      rng.SelectNodeContents(curNode);
      rng.ContainerStyle = "color:red";
      var url = curNode.getAttribute("URL");
      // Check if the attribute value is non-null
      // and set the status text acordingly
      if (url) {
         Application.SetStatusText(url);
      }
      rng = null;
      return;
    }
    for( var i=0; i<MouseOverElem_Array.length; i++){
      if (isParentElement(MouseOverElem_Array[i], Application.MouseOverNode)) {
        Application.SetCursor(sqCursorArrow);
        return;
      }
    }
    
  }
}
OnMouseOver();
 
]]></MACRO> 

<MACRO name="On_Document_Activate" hide="true" lang="JScript"><![CDATA[

Application.Run("On_Mouse_Over");
 
]]></MACRO> 

<MACRO name="On_Mouse_Out" hide="true" lang="JScript"><![CDATA[
function OnMouseOut()
{
  // initialize cursor and status text
  Application.SetCursor(sqDefaultCursor);
  Application.SetStatusText("");
  
  var curNode = Application.MouseOverNode;
  if (curNode) {
    var nodeName = curNode.NodeName;
    if (nodeName == "ULink") {
      var rng = ActiveDocument.Range;
      rng.SelectNodeContents(curNode);
      rng.ContainerStyle = "color:blue";
      rng = null;
      return;
    }
    if (nodeName == "PubDate") {
      var rng = ActiveDocument.Range;
      rng.SelectNodeContents(curNode);
      rng.ContainerStyle = "color:black";
      rng = null;
      return;
    }
  }
}
OnMouseOut();
]]></MACRO> 

<MACRO name="On_Document_Deactivate" hide="true" lang="JScript"><![CDATA[

Application.Run("On_Mouse_Out");

]]></MACRO> 

<MACRO name="On_View_Change" lang="JScript"><![CDATA[

// refreshes the Insertion and Deletion element container styles on view change from
// plain text to Normal or Tags on
function refreshStyles() {
  var docProps = ActiveDocument.CustomDocumentProperties;
  if (docProps.item("Highlighting").value == "True") {
    var rng = ActiveDocument.Range;
    rng.MoveToDocumentStart();
    while(rng.MoveToElement("Insertion")) {
      rng.ContainerStyle = "color:red; text-decoration:underline";
    }
    rng.MoveToDocumentStart();
    while (rng.MoveToElement("Deletion")) {
      rng.ContainerStyle = "color:red; text-decoration:line-through";
    }
    rng = null;
  }
  var hideAnnots = docProps.item( "HideAnnotations" ).value;
  if(hideAnnots == "true"){
    doHideAnnotations();
  } else {
    doShowAnnotations();  
  }
}
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------
function doShowAnnotations(){
  var docProps = ActiveDocument.CustomDocumentProperties;
  var rng_show = ActiveDocument.Range;
  rng_show.MoveToDocumentStart();
  while(rng_show.MoveToElement("Annotation")){
    if(rng_show.isParentElement("Insertion") && rng_show.isParentElement("Annotation")){
      element = "Annotation_in_Insertion";
    } else if (rng_show.isParentElement("Deletion") && rng_show.isParentElement("Annotation")){
      element = "Annotation_in_Deletion";
    } else if(rng_show.isParentElement("Insertion")){
      element = "Annotation_in_Insertion";
    } else if(rng_show.isParentElement("Deletion")) {
      element = "Annotation_in_Deletion";
    } else {
      element = "";
    }
    rng_show.SelectContainerContents();
    var start = rng_show.Duplicate;
    var end = rng_show.Duplicate;
    start.collapse(1);  // set the boundary for the search start
    end.Collapse(0);  // set the boundary for the search end
    if(rng_show.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
  rng_show.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
    readtree(start, end);
  }
  rng_show = null;
}

function readtree(start_rng, end_rng){
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent 
          if(start_rng.isParentElement("Annotation")){
          Annot_parent = true;
        } else {
          Annot_parent = false;
        }
        element = start_rng.ContainerNode.nodeName;
        if(start_rng.isParentElement("Insertion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Insertion";
          } else if (start_rng.isParentElement("Deletion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Deletion";
          } else if(start_rng.isParentElement("Insertion")){
            element = "Annotation_in_Insertion";
          } else if(start_rng.isParentElement("Deletion")) {
            element = "Annotation_in_Deletion";
          } else {
            element = "";
          }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
    }
  start_rng = null;
}
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------
function doHideAnnotations(){
  var rng_hide = ActiveDocument.Range;
  rng_hide.MoveToDocumentStart();
  Annot_parent = true;
  while(rng_hide.MoveToElement("Annotation")){
  if(rng_hide.isParentElement("Insertion") && rng_hide.isParentElement("Annotation")){
      element = "Annotation_in_Insertion";
    } else if (rng_hide.isParentElement("Deletion") && rng_hide.isParentElement("Annotation")){
      element = "Annotation_in_Deletion";
    } else if(rng_hide.isParentElement("Insertion")){
      element = "Annotation_in_Insertion";
    } else if(rng_hide.isParentElement("Deletion")) {
      element = "Annotation_in_Deletion";
    } else {
      element = "";
    }
    rng_hide.SelectContainerContents();
    start = rng_hide.Duplicate;
    start.Collapse(1);  // set the starting boundary for the search
    end = rng_hide.Duplicate;
    end.Collapse(0);  // set the ending boundary for the search
    rng_hide.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
    rng_hide = readtree(start, end);
  }
  Annot_parent = false;
  rng_hide = null;
}

function readtree(start_rng, end_rng){  
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent
          element = start_rng.ContainerNode.nodeName;
          if(start_rng.isParentElement("Insertion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Insertion";
          } else if (start_rng.isParentElement("Deletion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Deletion";
          } else if(start_rng.isParentElement("Insertion")){
            element = "Annotation_in_Insertion";
          } else if(start_rng.isParentElement("Deletion")) {
            element = "Annotation_in_Deletion";
          } else {
            element = "";
          }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
      
    }
  start_rng = null;
  return(end_rng);
}

//*****************************************************************************************************
//*****************************************************************************************************
var docProps = ActiveDocument.CustomDocumentProperties;
var Annot_parent = false;
var start, end, element;

if ((ActiveDocument.ViewType==sqViewNormal ||
     ActiveDocument.ViewType==sqViewTagsOn) &&
     ActiveDocument.PreviousViewType==sqViewPlainText) {
  fixISODates(false);
  var LastModList = ActiveDocument.getElementsByTagName("LastModDate");
  var Rng = ActiveDocument.Range;
  if (LastModList.length > 0) {
    Rng.SelectNodeContents(LastModList.item(0));
    Rng.ReadOnlyContainer = true;
  }
  Rng = null;

  refreshStyles();

}

    
]]></MACRO> 

<MACRO name="AuthorForm_OnInitialize" hide="true" lang="JScript"><![CDATA[
  // This macro is not needed at all if you always want to
  // display the "Author" and child elements with the
  // web browser control...
  var ipeg = Application.ActiveInPlaceControl;
  ipeg.Height = 320;
  ipeg.Width = 580;
  var browser = ipeg.Control;
  var form = Application.Path + "/Forms/AuthorForm.htm";
  afDocumentComplete = false;
  browser.Navigate2(form, 2);
]]></MACRO> 
 
<MACRO name="AuthorForm_DocumentComplete" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  // InternetExplorer WebBrowser controls will fire the dispatch event
 // "DocumentComplete" whenever a URL has completed loading and its contents
 // are displayed...for the AuthorForm, we set the IE control to browser
 // to "AuthorForm.htm" during the "AuthorForm_OnInitialize" script above...
 // ...when it completes loading the the URL for "AuthorForm.htm", this
 // macro will be executed...and we can complete the leftover initialization...
 //
 // Event Parameter 1: IWebBrowser2 interface
 // Event Parameter 2: URL 

function AFDocumentComplete()
{
  var e;  // for catching errors
  try {
    var oleg = Application.ActiveInPlaceControl;
    var browser = oleg.Control;
    var doc = browser.document;
    if (!doc) {
      return;
    }

    var node = oleg.Node;
    var rng = Application.ActiveDocument.Range;
    var frm = doc.AuthorForm;
    var children = node.childNodes;

    // Initialize the fields in the form
    setTextField("FirstName", frm.FirstName, children, rng);
    setTextField("Surname", frm.Surname, children, rng);
    setTextField("JobTitle", frm.JobTitle, children, rng);
    setTextField("OrgName", frm.OrgName, children, rng);

    var i = 0;
    var len = children.length;
    for (i = 0; i < len; i++) {
      if (children.item(i).nodeName == "Address") {
        children = children.item(i).childNodes;
        setTextField("Street", frm.Street, children, rng);
        setTextField("POB", frm.POB, children, rng);
        setTextField("City", frm.City, children, rng);
        setTextField("State", frm.State, children, rng);
        setTextField("Postcode", frm.Postcode, children, rng);
        setTextField("Country", frm.Country, children, rng);
        setTextField("Phone", frm.Phone, children, rng);
        setTextField("Fax", frm.Fax, children, rng);
        setTextField("Email", frm.Email, children, rng);
        break;
      }
    }
    rng = null;

  } catch(e) {
    // caught an error.
    Application.Alert("Author Form DocumentComplete\nError " + (e.number&0xFFFF) + ": " + e.description);
    // just return.
  }
}
var webBrowser = Application.ActiveInPlaceControl.NextEventParam;
var url = Application.ActiveInPlaceControl.NextEventParam;
var i = url.lastIndexOf("AuthorForm.htm");
if (i != -1) {
  AFDocumentComplete();
  afDocumentComplete = true;
}

]]></MACRO> 
 
<MACRO name="AuthorForm_OnSynchronize" hide="true" lang="JScript"><![CDATA[

function setAuthorKid(elemName, newValue, AuthorNode, rng)
{
//  rng.SelectBeforeNode(AuthorNode);
  rng.SelectNodeContents(AuthorNode);
  rng.Collapse(sqCollapseStart);
  var list = AuthorNode.getElementsByTagName(elemName);
  if (list.length == 0) // Element not present in document
  {
    if (newValue == "") return;
    if (rng.FindInsertLocation(elemName)) { // Element has been initialized in form
      rng.InsertElement(elemName);
      if (rng.ContainerName == elemName) {
        rng.Text = newValue;
      }
    }
    return;
  }
  var child = list.item(0);
  rng.SelectNodeContents(child)
  var oldValue = rng.Text;
  if (newValue == oldValue) // Element has not been changed
  {
    return;
  }
  
  if (newValue == "" && elemName != "FirstName" && elemName != "Surname") // Element has been deleted in the form
  {
    child.parentNode.removeChild(child);
    return;
  }  
    
  rng.Text = newValue; // Element has been changed to a different value
}


function updateAuthorKids(node, rng, frm)
{
  var newValue = frm.FirstName.value;
  setAuthorKid("FirstName", newValue, node, rng);
   
  newValue = frm.Surname.value;
  setAuthorKid("Surname", newValue, node, rng);

  newValue = frm.JobTitle.value;
  setAuthorKid("JobTitle", newValue, node, rng);

  newValue = frm.OrgName.value;
  setAuthorKid("OrgName", newValue, node, rng);
 
  var list = node.getElementsByTagName("Address");
  var noAddressinForm = (frm.Street.value == ""
                         && frm.POB.value == ""
                         && frm.City.value == ""
                         && frm.State.value == ""
                         && frm.Postcode.value == ""
                         && frm.Country.value == ""
                         && frm.Phone.value == ""
                         && frm.Fax.value == ""
                         && frm.Email.value == "");
  if (noAddressinForm) {
    if (list.length == 0) return; // no Address in both form and document
    var child = list.item(0); // Address was deleted in form
    child.parentNode.removeChild(child);
    return;
  }
  if (list.length == 0) { // Address has been initialized in form
//    rng.SelectBeforeNode(node);
    rng.SelectNodeContents(node);
    rng.Collapse(sqCollapseStart);
    rng.FindInsertLocation("Address");
    rng.InsertElement("Address");
  }   

  newValue = frm.Street.value;
  setAuthorKid("Street", newValue, node, rng);

  newValue = frm.POB.value;
  setAuthorKid("POB", newValue, node, rng);

  newValue = frm.City.value;
  setAuthorKid("City", newValue, node, rng);

  newValue = frm.State.value;
  setAuthorKid("State", newValue, node, rng);

  newValue = frm.Postcode.value;
  setAuthorKid("Postcode", newValue, node, rng);

  newValue = frm.Country.value;
  setAuthorKid("Country", newValue, node, rng);

  newValue = frm.Phone.value;
  setAuthorKid("Phone", newValue, node, rng);

  newValue = frm.Fax.value;
  setAuthorKid("Fax", newValue, node, rng);

  newValue = frm.Email.value;
  setAuthorKid("Email", newValue, node, rng);
}


function AFOnSync()
{
  var e;  // for catching errors
  try {
    var oleg = Application.ActiveInPlaceControl;
    var browser = oleg.Control;
    var doc = browser.document;
    if (!doc) {
      return;
    }

    var node = oleg.Node;
    var rng = Application.ActiveDocument.Range;
    var frm = doc.AuthorForm;
    var children = node.childNodes;

    if (Application.ActiveInPlaceControl.UserMovedIntoControl) {
      
      setTextField("FirstName", frm.FirstName, children, rng);
      setTextField("Surname", frm.Surname, children, rng);
      setTextField("JobTitle", frm.JobTitle, children, rng);
      setTextField("OrgName", frm.OrgName, children, rng);

      var i = 0;
      var len = children.length;
      for (i = 0; i < len; i++) {
        if (children.item(i).nodeName == "Address") {
          children = children.item(i).childNodes;
          setTextField("Street", frm.Street, children, rng);
          setTextField("POB", frm.POB, children, rng);
          setTextField("City", frm.City, children, rng);
          setTextField("State", frm.State, children, rng);
          setTextField("Postcode", frm.Postcode, children, rng);
          setTextField("Country", frm.Country, children, rng);
          setTextField("Phone", frm.Phone, children, rng);
          setTextField("Fax", frm.Fax, children, rng);
          setTextField("Email", frm.Email, children, rng);
          break;
        }
      }

    } else {
      updateAuthorKids(node, rng, frm);

    }
    rng = null;
    
  } catch(e) {
    // caught an error.
    Application.Alert("Author Form On Synchronize Error\nError " + (e.number&0xFFFF) + ": " + e.description);
    // just return.
  }
}

if (afDocumentComplete) {
  if ((ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn)
       && ActiveDocument.IsXML) {
    AFOnSync();
  }
}

]]></MACRO> 
 
<MACRO name="Import SeeAlso" lang="JScript" id="1362" tooltip="Import 'See Also' Table" desc="Import a 'See Also' table from a database"><![CDATA[
// SoftQuad Script Language JScript:
function RepairXMetaLInstallPath(paramFile) {
	// Open the param.txt
	var iomode = 1;  // ForReading
	var createmode = false; // a new file is NOT created if the specified filename doesn't exist.
	var formatmode = -1;  // Unicode
	if (Application.UnicodeSupported == false) {
		formatmode = 0;  // ASCII
	}

	try {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		var f = fso.OpenTextFile(paramFile, iomode, createmode, formatmode );
	}
	catch(exception) {
		result = reportRuntimeError("Import Table Error:", exception);
		Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
		fso = null;
		rng = null;
		return false;
	}

	// Read the whole file
	var str;
	str = f.ReadAll();
	f.Close();

	// Insert the xmetal install path if necessary.

	if (!str) {
	       Application.Alert("Initialization file for Database Import Wizard is empty.");
		return true; // file empty? Carry on anyway.
	}
	
	var  found = str.search(/XMETAL_INSTALL_PATH/g);
	if (found == -1) {
		return true;  // Not there, don't need to do anything.
	}

	var path = Application.Path;
	str = str.replace(/XMETAL_INSTALL_PATH/g, path);
	
	var iomode = 2;  // ForWriting
	var createmode = true; // a new file is created if the specified filename doesn't exist.
	f = fso.OpenTextFile(paramFile, iomode, createmode, formatmode);
	f.Write(str);

	// Close the text file
	f.Close();
	return true;

}

function doImportSeeAlso() {
// Local variables
  var paramFile = Application.Path + "\\Samples\\Cameras\\SA_param.txt";
  var tableFile = Application.Path + "\\Samples\\Cameras\\SA_table.htm";
  
//Fix XmetaL Install Path in param.txt
  if (!RepairXMetaLInstallPath(paramFile)) return;

// Find a place to insert the table
  var rng = ActiveDocument.Range;
  rng.MoveToDocumentEnd();
  if (rng.MoveToElement("SeeAlso", false)) {
    Application.Alert("SeeAlso table already exists in document");
    rng.Select();
    rng = null;
    return;
  }
  
  rng.MoveToDocumentEnd();
  if (!rng.FindInsertLocation("SeeAlso", false)) {
    Application.Alert("Could not find insert location for SeeAlso table");
    rng = null;
    return;
  }
    
  var result = "";
  // Generate a new, unique, parameter file name
  var newParamFile=Application.UniqueFileName(Application.Path + "\\Samples\\Cameras\\","SA_",".txt");

  // Copy the old parameter file into the new one
  // (so that the wizard won't come up blank)
  if (paramFile != null) {
    try {
      var fso = new ActiveXObject("Scripting.FileSystemObject");
      fso.CopyFile(paramFile,newParamFile);
    }
    catch(exception) {
      result = reportRuntimeError("Import See Also Table Error:", exception);
      Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
      fso = null;
      rng = null;
      return;
    }
    fso = null;
  }

  // Run the wizard
  // Show the dialog
  try {
    var obj = new ActiveXObject("SoftQuad.DBImport");
    var ret = obj.NewDBImport(newParamFile, tableFile);
  }
  catch(exception) {
    result = reportRuntimeError("Import SeeAlso Error:", exception);
    Application.Alert(result + "\nPlease register DBImport.dll");
    rng = null;
    obj = null;
    return;
  }

  // If user chose OK ...
  if (ret) {

    // Read the resulting table into the document
    var str = Application.FileToString(tableFile);
    if (!rng.CanPaste(str)) {
      Application.Alert("Table is invalid.\nSee journalist.dtd for correct structure of the SeeAlso table.");
      rng = null;
      return;
    }
    rng.TypeText(str);
    // The table id is the paramFile, minus the full path
    var splitPath=newParamFile.split('\\');
    var spLength=splitPath.length;
    var tableId=splitPath[spLength-1];

    rng.MoveToElement("SeeAlso", false); // move backwards to table element
    if (rng.ContainerName == "SeeAlso") {
      rng.ContainerAttribute("Id") = tableId; // for later updates
    }

    // Scroll to the location of the inserted table
    rng.Select();
    ActiveDocument.ScrollToSelection();
    Selection.MoveLeft();  // avoid big cursor next to table

    // Copy the new parameter file into the original one
    // (so that the next time the wizard is run, our new parameter file will dictate the initial state)
    if (paramFile != null) {
      try {
        var fso = new ActiveXObject("Scripting.FileSystemObject");
        fso.CopyFile(newParamFile,paramFile);
      }
      catch(exception) {
        result = reportRuntimeError("Import See Also Table Error:", exception);
        Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
        fso = null;
        rng = null;
        return;
      }
      fso = null;
    }

  } 
  rng = null;
  obj = null;
}

if (CanRunMacros()) { 
  doImportSeeAlso();
}
]]></MACRO> 

<MACRO name="Update SeeAlso" lang="JScript" tooltip="Update 'See Also' Table" desc="Update 'See Also' table imported from database" id="1363"><![CDATA[
// SoftQuad Script Language JScript:
function doUpdateSeeAlso() {
  // Local variables
  var rng = ActiveDocument.Range;
  var paramFile = Application.Path + "\\Samples\\Cameras\\SA_param.txt";
  var tableFile = Application.Path + "\\Samples\\Cameras\\SA_table.htm";
  
  // Check that we are inside a table
  var node = rng.ContainerNode;
  while (node && node.nodeName != "SeeAlso") {
    node = node.parentNode;
  }
  
  if (node) {
    // Check we are in the right kind of table
    var tableId=rng.ElementAttribute("Id", "SeeAlso");

    var paramFile = Application.Path + "\\Samples\\Cameras\\" + tableId;
    try {
      var fso = new ActiveXObject("Scripting.FileSystemObject");
    }
    catch(exception) {
      result = reportRuntimeError("Update SeeAlso Error:", exception);
      Application.Alert(result + "\nFailed to invoke Scripting.FileSystemObject\nYou need to get Windows Scripting Host from the Microsoft site.");
      rng = null;
      return;
    }
    if (fso.FileExists(paramFile)) {

      // Insert the new table
      try {
        var obj = new ActiveXObject("SoftQuad.DBImport");
        obj.UpdateDBImport(paramFile, tableFile);
      }
      catch(exception) {
        result = reportRuntimeError("Update SeeAlso Error:", exception);
        Application.Alert(result + "\nPlease register DBImport.dll");
        obj = null;
        rng = null;
        return;
      }

      // Delete the old table
      rng.SelectNodeContents(node);
      rng.SelectElement();
      rng.Delete();

      // Read the resulting table into the document
      var str = Application.FileToString(tableFile);
      rng.TypeText(str);

      // Set the border and id attributes of the table
      rng.MoveToElement("SeeAlso", false); // move backwards to table element
      if (rng.ContainerName == "SeeAlso") {
        rng.ContainerAttribute("Id") = tableId; // for later updates
      }

      // Scroll to the location of the inserted table
      rng.MoveLeft();
      rng.Select();
      ActiveDocument.ScrollToSelection();
      obj = null;
    }
    else {
      Application.Alert("Parameter file "+paramFile+" does not exist.\nCannot update this table.");
    }
  }
  else {
    Application.Alert("You are not currently inside a SeeAlso table.");
  }
  
  rng = null;
}

if (CanRunMacros()) {
  doUpdateSeeAlso();
}
]]></MACRO> 

<MACRO name="Use 1.css for the Structure View" lang="JScript" id="1440" desc="Use 1.css for the Structure View"><![CDATA[
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {
  if (ActiveDocument.StructureViewVisible)
    switchSVStyles("1.css");
  else
    Application.Alert("Structure view not showing");
}
else
  Application.Alert("Change to Tags On or Normal view to run macros.");
]]></MACRO>

<MACRO name="Use 2.css for the Structure View" lang="JScript" id="1441" desc="Use 2.css for the Structure View"><![CDATA[
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {
  if (ActiveDocument.StructureViewVisible)
   switchSVStyles("2.css");
  else
    Application.Alert("Structure view not showing");
}
else
  Application.Alert("Change to Tags On or Normal view to run macros.");
]]></MACRO>

<MACRO name="Use 3.css for the Structure View" lang="JScript" id="1442" desc="Use 3.css for the Structure View"><![CDATA[
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {
  if (ActiveDocument.StructureViewVisible)
   switchSVStyles("3.css");
  else
    Application.Alert("Structure view not showing");
}
else
  Application.Alert("Change to Tags On or Normal view to run macros.");
]]></MACRO>

<MACRO name="Use 4.css for the Structure View" lang="JScript" id="1443" desc="Use 4.css for the Structure View"><![CDATA[
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {
  if (ActiveDocument.StructureViewVisible)
   switchSVStyles("4.css");
  else
    Application.Alert("Structure view not showing");
}
else
  Application.Alert("Change to Tags On or Normal view to run macros.");
]]></MACRO>

<MACRO name="Use 5.css for the Structure View" lang="JScript" id="1444" desc="Use 5.css for the Structure View"><![CDATA[
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {
  if (ActiveDocument.StructureViewVisible)
   switchSVStyles("5.css");
  else
    Application.Alert("Structure view not showing");
}
else
  Application.Alert("Change to Tags On or Normal view to run macros.");
]]></MACRO>

<MACRO name="Use the default (generated) Structure View" lang="JScript" id="1448" desc="Use the default (generated) Structure View"><![CDATA[
if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {
  if (ActiveDocument.StructureViewVisible)
   switchSVStyles();
  else
    Application.Alert("Structure view not showing");
}
else
  Application.Alert("Change to Tags On or Normal view to run macros.");
]]></MACRO>

<MACRO name="Insert Annotation" key="" lang="JScript" id="1800" desc="Annotates the selected text"><![CDATA[
//***********************************************************************************************************
// surrounds the selected text with Annotation Element, if no text is selected inserts an empty
// Annotation element
//************************************************************************************************************
function doinsertAnnotation()
{
  	var docProps = ActiveDocument.CustomDocumentProperties;
  	var hideAnnotations = docProps.item("HideAnnotations").value;

    // display the dialog box for the user to enter a Note for the Annotation and their initials
    var Annot_Dlg = CreateFormDlg(Application.Path + "\\Forms\\Annotation\\Annotation.hhf");
    // exit status 0 for 'Cancel' 1 for 'OK' and 2 if clicked on the 'x' button on the top right corner
    var Term_status = Annot_Dlg.DoModal();
    // enter a note for the annotated text if any
    var comment_str = Annot_Dlg.txtComment.Text;
    var initials = Annot_Dlg.txtInitials.Text.toUpperCase();
    Annot_Dlg = null;
    
    if (Term_status == 1) {
    	var date = new Date();
		var dateStr = "" + date.getMonth() + 1 + "/" + date.getDate() +
           "/" + date.getYear() + " ";
    	dateStr = date.toLocaleString();
    	var r = Selection.Duplicate;

	    // surround the selected with Annotation Element
	    if(r.IsInsertionPoint){  // if the selection is insertion point i.e. no text selected
	      if(r.isParentElement("Insertion")){
	        element = "Annotation_in_Insertion";
	      } else if(r.isParentElement("Deletion"))  {
	        element = "Annotation_in_Deletion";
	      } else {
	        element = "Annotation";
	      }
	      r.InsertElement("Annotation");        
	      // set the name attribute to the current user name 
	      r.ContainerAttribute("UserName") = UserName;
	      // set the Initials attribute to the current user's Initials 
	      r.ContainerAttribute("Initials") = initials;
	      // set the Annotation insertion time 
	      r.ContainerAttribute("Time") = dateStr;
	      // note on the annotated text, if any
	      r.ContainerAttribute("Comment") = comment_str;
	      r.ContainerStyle = getAnnot_ReMa_Styles(element, "true");
	      Selection.GoToNext(0);
	    } else { // text is selected
	      if(r.CanSurround("Annotation")){
	        r.Surround("Annotation");
	        if(r.isParentElement("Insertion")){
	          element = "Annotation_in_Insertion";
	        } else if(r.isParentElement("Deletion"))  {
	          element = "Annotation_in_Deletion";
	        } else {
	          element = "Annotation";
	        }
	        r.ContainerStyle = getAnnot_ReMa_Styles(element, "true");       
	        // set the name attribute to the current user name 
	        r.ContainerAttribute("UserName") = UserName
	        // set the Initials attribute to the current user's Initials 
	        r.ContainerAttribute("Initials") = initials;
	        // set the Annotation insertion time 
	        r.ContainerAttribute("Time") = dateStr;
	        r.ContainerAttribute("Comment") = comment_str;
	        var rng_Ins = ActiveDocument.Range;
	        var start = rng_Ins.Duplicate;
	        var end = rng_Ins.Duplicate;
	        start.Collapse(1);    	// set the starting boundary to the start of the Annotated text
	        end.Collapse(0);    	// set the ending boundary to the end of the Annotated text 
	        readtree(start, end);   // sets the styles for the elements surrounded by Annotation
	        
	      }
	      start = null;       // clean up the ranges
	      end = null;         // clean up the ranges
	      rng_Ins = null;     // dlean up the ranges
		
		  Selection.Select();
		  Selection.Collapse(0);	// Move the selection to the end
		  // incase annotation is surrounding an element tag eg: <Annotation><Para>text</Para></Annotation>
		  // Selection.Collapse(0) moves the selection between</Para> and </Annotation> and allows the user 
		  // to type text in here.  Delete Annotation might not work 'coz this text becomes illegal.
		  Selection.GotoPrevious(3); 
		  Selection.SelectContainerContents();
		  Selection.Collapse(0); 
	   }
  	}
  	
	r = null;
	docProps = "";
	hideAnnotations = "";
	return;
}

//----------------------------------------------------------------------------------------------------------


// sets the styles for all the children of the new Annotation element
function readtree(start_rng, end_rng){
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent 
        	var element = start_rng.ContainerNode.nodeName;
        	if(element == "Annotation"){
        	    if(start_rng.isParentElement("Insertion")){
            		element = "Annotation_in_Insertion";
          		} else if(start_rng.isParentElement("Deletion"))  {
            		element = "Annotation_in_Deletion";
          		} 
       		}
			Annot_parent = true;
			start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else{
          	break;
        }
      }
    }
  temp_rng = null;
  start_rng = null;
  end_rng = null; 
}

//******************************************************************************************************

if (CanRunMacros()) {
  if(Selection.CanSurround("Annotation")){
    doinsertAnnotation();
  }
}]]></MACRO> 
 
<MACRO name="Hide Annotations" key="" lang="JScript" id="1808" desc="Hides all annotations"><![CDATA[
//******************************************************************************************************
// Hides Annotations i.e. does not highlight Annotated the text.
//******************************************************************************************************
function doHideAnnotations(){
  docProps.item("HideAnnotations").value = true;
  var rng_hide = ActiveDocument.Range;  // variable to select the range to hide the annotations
  rng_hide.MoveToDocumentStart();     // start the search for Annotation elements from the document start
  Annot_parent = true;          // one of the parent element in the ancestor list is Annotation
  while(rng_hide.MoveToElement("Annotation")){  // Go to each Annotation element in the document 
    if(rng_hide.isParentElement("Insertion") && rng_hide.isParentElement("Annotation")){
      element = "Annotation_in_Insertion";
    } else if (rng_hide.isParentElement("Deletion") && rng_hide.isParentElement("Annotation")){
      element = "Annotation_in_Deletion";
    } else if(rng_hide.isParentElement("Insertion")){
      element = "Annotation_in_Insertion";
    } else if(rng_hide.isParentElement("Deletion")) {
      element = "Annotation_in_Deletion";
    } else {  // required coz' it might remember the previous value
      element = "";
    }
    rng_hide.SelectContainerContents();   // Select the entire contents sorrounded this Annotation element
    start = rng_hide.Duplicate;       
    start.Collapse(1);  // set the starting boundary to hide
    end = rng_hide.Duplicate;
    end.Collapse(0);  // set the ending boundary to hide
    rng_hide.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);  // global function. sets the styles
    rng_hide = readtree(start, end);  // Traverse thru' this element's children tree and set the styles
  }
  Annot_parent = false;
  rng_hide = null;
}

function readtree(start_rng, end_rng){  
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent
          element = start_rng.ContainerNode.nodeName;
          if(start_rng.isParentElement("Insertion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Insertion";
          } else if (start_rng.isParentElement("Deletion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Deletion";
          } else if(start_rng.isParentElement("Insertion")){
            element = "Annotation_in_Insertion";
          } else if(start_rng.isParentElement("Deletion")) {
            element = "Annotation_in_Deletion";
          }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
      
    }
  start_rng = null;
  return(end_rng);
}

//*******************************************************************************************************

var docProps = ActiveDocument.CustomDocumentProperties;
var Annot_parent = false;
var start, end, element;
if (CanRunMacros()) {  // if not in Plain Text view
  doHideAnnotations(); 
}]]></MACRO>

<MACRO name="Show Annotations" key="" lang="JScript" id="1809" desc="Displays all hidden annotations"><![CDATA[
//****************************************************************************************************
// Highlights the text surrounded by the Annotation elements.
//****************************************************************************************************
function doshowAnnotations(){
  var docProps = ActiveDocument.CustomDocumentProperties;
  docProps.item("HideAnnotations").value = false;
  var rng_show = ActiveDocument.Range;  
  rng_show.MoveToDocumentStart();   // start the search for the Annotations elements from the starting point of the document
  while(rng_show.MoveToElement("Annotation")){  // while more Annotation elements
    if(rng_show.isParentElement("Insertion") && rng_show.isParentElement("Annotation")){
      element = "Annotation_in_Insertion";
    } else if (rng_show.isParentElement("Deletion") && rng_show.isParentElement("Annotation")){
      element = "Annotation_in_Deletion";
    } else if(rng_show.isParentElement("Insertion")){
      element = "Annotation_in_Insertion";
    } else if(rng_show.isParentElement("Deletion")) {
      element = "Annotation_in_Deletion";
    } else {
      element = "";
    }
    rng_show.SelectContainerContents();   // select the entire text surrounded by this Annotation element
    var start = rng_show.Duplicate;
    var end = rng_show.Duplicate;
    start.collapse(1);  // set the boundary for the search start
    end.Collapse(0);  // set the boundary for the search end
    if(rng_show.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
  rng_show.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
    readtree(start, end);
  }
  rng_show = null;
}

//-----------------------------------------------------------------------------------------------------
// Traverses thru' the tree with in the selected range and sets the styles for all elements inside
//-----------------------------------------------------------------------------------------------------
function readtree(start_rng, end_rng){
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent 
          if(start_rng.isParentElement("Annotation")){
          Annot_parent = true;
        } else {
          Annot_parent = false;
        }
        element = start_rng.ContainerNode.nodeName;
        if(start_rng.isParentElement("Insertion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Insertion";
          } else if (start_rng.isParentElement("Deletion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Deletion";
          } else if(start_rng.isParentElement("Insertion")){
            element = "Annotation_in_Insertion";
          } else if(start_rng.isParentElement("Deletion")) {
            element = "Annotation_in_Deletion";
          } else {
            element = "";
          }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
    }
  start_rng = null;
}
var element;
var Annot_parent = false;
if (CanRunMacros()) {
  doshowAnnotations();
}]]></MACRO>

<MACRO name="Delete Annotation" key="" lang="JScript" id="1802" desc="Deletes the current annotation"><![CDATA[
//******************************************************************************************************
// Deletes the current Annotation.  if the selection has more than one parent element
// in the ancestor list the closest/inner most parent until the selected is chosen
//******************************************************************************************************

function doDeleteAnnotation(){
  var rng = ActiveDocument.Range;
  var node_del;
  var elem = Selection.ElementName(0);  // the immediate parent
  if(elem != "Annotation"){         // if the immediate parent is not Annotation
    rng.SelectContainerContents();
    rng.Collapse(1);
    var mainNode = rng.ContainerNode;
    while(rng.MoveToElement("Annotation", false)){
      rng_del = rng.Duplicate;
      node_del = readtree1(rng_del.ContainerNode, mainNode);
      if(node_del){
        break;
      }
    }
  } else {
    node_del = true;
  }
  if(node_del){
    rng.SelectContainerContents();
    var start = rng.Duplicate;
    start.Collapse(1);
      var end = rng.Duplicate;
      end.Collapse(0);
      rng.RemoveContainerTags();
    rng = readtree2(start, end);  
      start = null;
      end = null;
      rng = null;
  }
}

function readtree1(Annot_node, del_node){

  if (Annot_node.hasChildNodes()) {
    var children = Annot_node.childNodes;
    for(var i=0; i<children.length; i++){
      if(children.item(i) == del_node){
        return (true);
      } else {
        found = readtree1(children.item(i), del_node);
      }
    }
  }
  return found;
  
}
  

//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

function readtree2(start_rng, end_rng){  
  while(true){  // Move to next element
    var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent 
          var element = start_rng.ContainerNode.nodeName;
          if(start_rng.isParentElement("Annotation")){
            Annot_parent = true;
          } else {
            Annot_parent = false;
          }
          if(start_rng.isParentElement("Insertion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Insertion";
          } else if (start_rng.isParentElement("Deletion") && start_rng.isParentElement("Annotation")){
            element = "Annotation_in_Deletion";
          } else if(start_rng.isParentElement("Insertion")){
            element = "Insertion";
          } else if(start_rng.isParentElement("Deletion")) {
            element = "Deletion";
          } else if(start_rng.isParentElement("Annotation")) {
            element = "Annotation";
          }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);   
      
        } else {
          break;
        }
      }
    }
    start_rng = null;
  return end_rng;
}



//*******************************************************************************************************
//*******************************************************************************************************
var found = false;
if (CanRunMacros()) {
  if(Selection.IsParentElement("Annotation")){
      doDeleteAnnotation();
    }
}
]]></MACRO>

<MACRO name="On_Double_Click" key="" hide="true" lang="JScript"><![CDATA[
 
 function OnDblClick(){
  var containNode = Selection.ContainerNode;
    if (!containNode) return; // return if the container node is null
    var nodeName = containNode.nodeName;
    if(nodeName == "Annotation"){ 
    // variable to check if comment element exists
    var comment_temp = "";
    var index = getIndex(Selection.Duplicate);
    // initials of author 
    var initials = "[" + Selection.ContainerAttribute("Initials") + index + "]";
    comment = Selection.ContainerAttribute("Comment");
    // display the dialog with comment
    var comment_Dlg = CreateFormDlg(Application.Path + "\\Forms\\Annotation\\Comment.hhf");
    comment_Dlg.txtInitials.Text = initials;
    comment_Dlg.txtComment.Text = comment;
    var Term_status = comment_Dlg.DoModal();
    if(Term_status == 1){
      // if the comment is modified 
      var comment_str = comment_Dlg.txtComment.Text;
      Selection.ContainerAttribute("Comment") = comment_str;
    }
    comment_Dlg = "";
  }
  
}

function getIndex(Annot_Node){
  var index = 0;
  var index_rng = ActiveDocument.Range;
  index_rng.MoveToDocumentStart();
  while(index_rng.MoveToElement("Annotation")){
    index++;
    if(index_rng.ContainerNode == Annot_Node.ContainerNode){
      index_rng = 0;
      return index;
      break;
    }
  }
  index_rng = null;
}

if (CanRunMacros()) {
  OnDblClick();
}
]]></MACRO>

<MACRO name="List All Comments" key="" lang="JScript" id="1805" desc="List all comments associated with the annotations"><![CDATA[
 // Lists all comments associated with Annotations. 
 // Updates the changes if the user makes any changes
function listallComments(){
  var index = 0;
  var comment = "";
  var Item = "";
  var Reviewers = new Array();
  var Initials_Arr = new Array();
  var rng = ActiveDocument.Range;
  var rng_Annot = rng.Duplicate;
  rng_Annot.MoveToDocumentStart();
  
  // read all comments associated with Annotation element
  while(rng_Annot.MoveToElement("Annotation")){
    index++;
    // Initials of the author
    var Initials = rng_Annot.ContainerAttribute("Initials");
    // comment attribute of Annotation element 
    var comment = rng_Annot.ContainerAttribute("Comment");
    // append all comments for display in the dialog box
    Item += "[" + Initials + index + "] " + comment + "\n";
  }
  
  // initialize the form dialog
  var Annot_Dlg = CreateFormDlg(Application.Path + "\\Forms\\Annotation\\ListOfComments.hhf");
  // display the comments in the dialog box
  Annot_Dlg.txtCommentList.Text = Item;
  // if the user clicks "ok" or "cancel"
  Annot_Dlg.DoModal();
  // read the contents of the text box
  var commentString = Annot_Dlg.txtCommentList.Text;
  // update comments in case if the user has made any changes
  updateComments(commentString);
  Annot_Dlg = "";
}
  
function updateComments(commentString){
  var comments = new Array();  // array to store comments
  var comm_index = 0; // comment index for comments array
  var comment = "";
  var rng_comment = ActiveDocument.Range; 
  rng_comment.MoveToDocumentStart();
  var comments_arr1 = commentString.split("["); // split the commentString into separate comments
  
  for(var i=1; i<comments_arr1.length; i++){
    comment = "";
    var comments_arr2 = comments_arr1[i].split("] ");  // split Initials and comment
    comment = comments_arr2[1].substring(0, comments_arr2[1].length-2); // get rid of last new line
    comments[i] = comment;
  }
    
  while(rng_comment.MoveToElement("Annotation")){
    comm_index++;
    rng_comment.ContainerAttribute("Comment") = comments[comm_index];  // update comments
  }   
}

if (CanRunMacros()) {
  listallComments();
}
]]></MACRO>

<MACRO name="Delete All Annotations" key="" lang="JScript" id="1806" desc="Deletes all annotations "><![CDATA[
// Deletes all Annotations in the document

function doDeleteAnnotations(){
  var rng_delall = ActiveDocument.Range;
  rng_delall.MoveToDocumentStart();
  while(rng_delall.MoveToElement("Annotation")){
  rng_delall.SelectContainerContents();
  var start = rng_delall.Duplicate;
  start.Collapse(1);
    var end = rng_delall.Duplicate;
    end.Collapse(0);
    rng_delall.RemoveContainerTags();
  rng_delall = readtree(start, end);  
    start = null;
    end = null;
  }
  rng_delall = null;
}
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

function readtree(start_rng, end_rng){   
  while(true){  // Move to next element
    var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent 
          var element = start_rng.ContainerNode.nodeName;
          if(start_rng.isParentElement("Insertion") && start_rng.isParentElement("Annotation")){
            if(element == "Annotation"){
              start_rng.RemoveContainerTags();
            }
            element = "Insertion";
          } else if (start_rng.isParentElement("Deletion") && start_rng.isParentElement("Annotation")){
            element = "Deletion";
            if(element == "Annotation"){
              start_rng.RemoveContainerTags();
            }
            start_rng.RemoveContainerTags();
          } else if(start_rng.isParentElement("Insertion")){
            element = "Insertion";
          } else if(start_rng.isParentElement("Deletion")) {
            element = "Deletion";
          } else if(element == "Annotation"){
            start_rng.RemoveContainerTags();
          } else {
            element = "";
          }   
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);   
      
        } else {
          break;
        }
      }
    }
    start_rng = null;
  return end_rng;
}


//*****************************************************************************************************
//*****************************************************************************************************
var Annot_parent = false;
if (CanRunMacros()) {
  doDeleteAnnotations();
}]]></MACRO>


<MACRO name="Deletion" key="Ctrl+Alt+F1" lang="JScript" id="1913" desc="Surround the selected text with Deletion element"><![CDATA[
//***************************************************************************************************
// Macro for Revision Control
// Surrounds the selected text with Deletion element and sets the container style accordingly
// if  highlighting  is  true then the selected text color is red and style is strike through.
// if the selected text has an Deletion inside then it merges it with the current parent.
// if the selected text has an Insertion element inside then it deletes the elemetn and it's 
// contents
//***************************************************************************************************
function doDeletion()
{
  var del = ActiveDocument.Range;
  var date = new Date();
    if (!del.IsInsertionPoint) {  // if some text is selected
      if(del.isParentElement("Insertion")){ // if the selection is inside an Insertion element
      var del_txt = del.Text;
      del.Delete();  // delete it temporarily
      del.SplitContainer(); // split the container into two Insertion elements 
      del.ContainerStyle = getAnnot_ReMa_Styles("Insertion", Annot_parent);
      del.SelectBeforeContainer();
      if(!del.IsParentElement("Deletion")){
        if(del.CanInsert("Deletion")){
          del.InsertElement("Deletion");
          del.ContainerAttribute("UserName") = UserName;
          del.ContainerAttribute("Time") = date.toLocaleString();
          del.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
          del.Text = del_txt;
        }
      }
    }else if(!del.isParentElement("Deletion")){
      if(del.CanSurround("Deletion")){
        del.Surround("Deletion");
        
        del.ContainerAttribute("UserName") = UserName;  // name of the current user
        del.ContainerAttribute("Time") = date.toLocaleString(); // time when this change was made
        del.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
        var rng = ActiveDocument.Range;
        rng.SelectContainerContents();
        var start = rng.Duplicate;
        start.Collapse(1);
        var end = rng.Duplicate;
        end.Collapse(0);
        readtree(start, end);
      }
    }
  }
  del = null;
  start = null;
  end = null;
}

function readtree(start_rng, end_rng){
  // If the node represents an "Insertion" element, remove it
  while(true){
    var temp_rng = start_rng.Duplicate;
    start_rng.GoToNext(0);
    if(temp_rng.isEqual(start_rng)){
      temp_rng = null;
      break;
    } else {
      if(start_rng.isLessThan(end_rng)){
        if(start_rng.ContainerNode){
          var element = start_rng.ContainerNode.nodeName;
          if( element == "Deletion"){
            start_rng.RemoveContainerTags();
          } else if(element == "Insertion"){
            start_rng.SelectContainerContents();
            start_rng.Delete();
            start_rng.RemoveContainerTags();
          } else if(element == "Annotation") {
            element = "Annotation_in_Deletion";
            start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, "true");
          } else {
            if(start_rng.isParentElement("Annotation")){
              Annot_parent = true;
            } else {
              Annot_parent = false;
            }
            start_rng.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
            element = "";
          }
        }
      } else {
      	temp_rng = null;
        break;
      }
    }
  }
}

var Annot_parent = false;
if (CanRunMacros()) {
  if(Selection.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
    doDeletion();
}
]]></MACRO>
 
<MACRO name="Insertion" key="Ctrl+Alt+I" lang="JScript" id="1914" desc="Marks the Insertions"><![CDATA[

//******************************************************************************************************
// Allows the users to track changes while inserting any text in the document.
// If the user selects some text and clicks on insertion toolbar button the selected text
// is surrounded by deletion element
//******************************************************************************************************
function getInsertion(){
  if(Selection.IsParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
  if(Selection.IsInsertionPoint){
    doInsertion();  
  }else{
    if(Selection.CanSurround("Deletion")){
      if(Selection.IsParentElement("Insertion")){
        var temp_text = Selection.Text;
        Selection.Delete();
        Selection.SplitContainer();
        Selection.ContainerStyle = getAnnot_ReMa_Styles("Insertion", Annot_parent);
        Selection.SelectBeforeContainer();
        if(Selection.CanInsert("Deletion")){
          Selection.InsertElement("Deletion");
          Selection.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
          Selection.Text = temp_text;
        }
        Selection.MoveToElement("Insertion");
      } else {  
        Selection.Surround("Deletion");
        Selection.ContainerAttribute("UserName") = UserName;
          var date = new Date();
            Selection.ContainerAttribute("Time") = date.toLocaleString();
            Selection.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
        Selection.SelectAfterContainer();
        doInsertion();
      }
    }
  }
}

function doInsertion(){
  if(Selection.ContainerNode){
    if(!Selection.isParentElement("Insertion")){
        if(Selection.CanInsert("Insertion")){
            if(Selection.isParentElement("Deletion")){
              Selection.SplitContainer();
              Selection.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
              Selection.SelectBeforeContainer();
        }  
        // Insert "Insertion"
        Selection.InsertElement("Insertion");
        Selection.InsertReplaceableText("Insert text here");
        Selection.ContainerAttribute("UserName") = UserName;
        var date = new Date();
        Selection.ContainerAttribute("Time") = date.toLocaleString();
        Selection.ContainerStyle = getAnnot_ReMa_Styles("Insertion", Annot_parent);
              
        // Merge if the previous tag name and its user are the same as this 
        if(Selection.ContainerNode){
          var prevSibling = Selection.ContainerNode.previousSibling; 
          var nextSibling = Selection.ContainerNode.nextSibling; 
          if(prevSibling && prevSibling.nodeName == "Insertion"){
              Selection.JoinElementToPreceding();
          }else if(nextSibling && nextSibling.nodeName == "Insertion"){
            Selection.MoveToElement("Insertion");
            Selection.JoinElementToPreceding();
          }
        }

        }else{
        Application.Alert("Cannot Insert 'Insertion' element here");
        }
    }
  }
}

// global variable
var Annot_Parent = false;
if (CanRunMacros()) {
  if(Selection.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
  getInsertion();
}
]]></MACRO>
 
<MACRO name="Accept Changes" key="" lang="JScript" id="1912" desc="Includes all changes in the document"><![CDATA[
//******************************************************************************************************
// Incorporates Reviewer's changes i.e deletes all text surrounded by Deletion element including the tags 
// and merges the contents of Insertion element with the document
//******************************************************************************************************
function mergeChanges()
{
 var r = Selection.Duplicate;
 r.MoveToDocumentStart();
 while (r.MoveToElement("Deletion")) {
  r.SelectContainerContents();
  r.Delete();
  r.RemoveContainerTags();
 }
 r.MoveToDocumentStart();
 while (r.MoveToElement("Insertion")) {
  r.SelectContainerContents();
    if(r.Text == "<?xm-replace_text Insert text here?>"){
      r.Delete();
    }
  r.RemoveContainerTags();
 }
}

if (CanRunMacros()) {
  var confirm = Application.Confirm("Do you want to merge all changes without reviewing them?");
    if(confirm){
      mergeChanges();
    }
}
]]></MACRO>
 
<MACRO name="Accept or Reject Changes" lang="JScript" id="1904" key="Ctrl+Alt+A" desc="Accept or Reject Changes..." tooltip="Accept or Reject Changes... (Ctrl+Alt+A)"><![CDATA[
//*******************************************************************************************************
//  Enables the Reviewers to Incorporates the changes from a dialog box
//*******************************************************************************************************

function doAcceptOrReject(){
  var Accept, Reject, AcceptAll, RejectAll, Undo, FindPrev, FindNext, Insertion_list, Deletion_list;
  //var action = Selection.ContainerName;
  Accept = true;
  Reject = true;
  AcceptAll = true;
  RejectAll = true;
  Undo = false;
  FindPrev = true;
  FindNext = true;
  var AcceptOrReject_Dlg = CreateFormDlg(Application.Path + "\\Forms\\Revision Control\\AcceptOrReject.hhf");
  var rng = ActiveDocument.Range;
  Insertion_list = ActiveDocument.getElementsByTagName("Insertion");
  Deletion_list = ActiveDocument.getElementsByTagName("Deletion");
  if(Insertion_list.length == 0 && Deletion_list.length == 0){
    Accept = false;
    Reject = false;
    AcceptAll = false;
    RejectAll = false;
    Undo = false;
    FindPrev = false;
    FindNext = false;
  }else if(!Selection.IsParentElement("Insertion") && !Selection.IsParentElement("Deletion")){
    Accept = false;
    Reject = false;
  }
    
  AcceptOrReject_Dlg.cmdAccept.Enabled = Accept;
  AcceptOrReject_Dlg.cmdReject.Enabled = Reject;
  AcceptOrReject_Dlg.cmdAcceptAll.Enabled = AcceptAll;
  AcceptOrReject_Dlg.cmdRejectAll.Enabled = RejectAll;
  AcceptOrReject_Dlg.cmdUndo.Enabled = Undo;
  AcceptOrReject_Dlg.cmdFindPrev.Enabled = FindPrev;
  AcceptOrReject_Dlg.cmdFindNext.Enabled = FindNext;

  var docProps = ActiveDocument.CustomDocumentProperties;
  if (docProps.item("Highlighting").value == "True") {
    AcceptOrReject_Dlg.opt_ChangesWH.Value = true;
  }else if (docProps.item("ShowOriginal").value == "True") {
    AcceptOrReject_Dlg.opt_Original.Value = true;
  } else {
    AcceptOrReject_Dlg.opt_ChangesWOH.Value = true;
  }
  if(Selection.ContainerNode.nodeName == "Insertion"){
    AcceptOrReject_Dlg.lblUser.Caption = Selection.ContainerAttribute("UserName");
    AcceptOrReject_Dlg.lblAction.Caption = "Insertion";
    AcceptOrReject_Dlg.lblTime.Caption = Selection.ContainerAttribute("Time");
  } else if(Selection.ContainerNode.nodeName == "Deletion"){
    AcceptOrReject_Dlg.lblUser.Caption = Selection.ContainerAttribute("UserName");
    AcceptOrReject_Dlg.lblAction.Caption = "Deletion";
    AcceptOrReject_Dlg.lblTime.Caption = Selection.ContainerAttribute("Time");
  } 
    
  AcceptOrReject_Dlg.DoModal();
}

if (CanRunMacros()) {
  doAcceptOrReject();
}
]]></MACRO>
 
<MACRO name="Accept Change" key="" lang="JScript" id="1905" desc="Accept the current marked change"><![CDATA[

//****************************************************************************************************
// Incorporates the current marked change i.e. if the selection is inside an Insertion 
// the contents are merged and if inside an Deletion the contents are deleted.
//*****************************************************************************************************
function doAcceptChange()
{
  if (Selection.isParentElement("Insertion")){
    Selection.SelectContainerContents();
    if(Selection.Text == "<?xm-replace_text Insert text here?>"){
      Selection.Delete();
    }
    if(Selection.ElementName(0) != "Insertion"){
      if(Selection.MoveToElement("Insertion", false)){
        Selection.SelectContainerContents();
        var containerContents = Selection.Text;
        Selection.Delete();
        Selection.RemoveContainerTags();
        Selection.Text = containerContents;
        containerContents = "";
      }
    }else{
      Selection.RemoveContainerTags();
    } 
    
  } else if(Selection.isParentElement("Deletion")) {
      if(Selection.ElementName(0) == "Deletion"){
        Selection.SelectContainerContents();
        Selection.Delete();
        Selection.RemoveContainerTags();
      } else {
        while(Selection.isParentElement("Deletion")){
          Selection.MoveToElement("Deletion", false);
          Selection.SelectContainerContents();
          Selection.Delete();
          Selection.RemoveContainerTags();
        }
    }
  }

}

function readtree(node, parent){
  // If the node represents an "Insertion" element, remove it
  if(node.nodeName == "Deletion" && !parent){
    rng_temp.MoveToElement("Deletion");
    rng_temp.ReadOnlyContainer = false;
    rng_temp.RemoveContainerTags();
    return
  } else if (node.hasChildNodes()) {
    var children = node.childNodes;
    for(var i=0; i<children.length; i++){
      readtree(children.item(i), false);
    }
    return; 
  }
}
var rng_temp;
if (CanRunMacros()) {
  doAcceptChange();
}]]></MACRO>
 
<MACRO name="Reject Change" key="" lang="JScript" id="1902" desc="Rejects the current marked change"><![CDATA[
//****************************************************************************************************
// Rejects the current marked change i.e. if the selection is inside an Insertion the contents
// are removed and if  the contents are inside an Deletion they are merged back with the document
//*****************************************************************************************************
function doRejectChange(){
  if(Selection.IsParentElement("Insertion")){
    if(Selection.ElementName(0) != "Insertion"){
      Selection.MoveToElement("Insertion", false);
    }
    Selection.SelectContainerContents();
    Selection.Delete();
    Selection.RemoveContainerTags();
    return;
  } else if(Selection.IsParentElement("Deletion")){
    var rng_reject = ActiveDocument.Range;
    if(Selection.ElementName(0) != "Deletion"){
        rng_reject.MoveToElement("Deletion", false);
    }
    rng_reject.SelectContainerContents();
    start = rng_reject.Duplicate;
      start.Collapse(1);  // set the starting boundary for the search
      end = rng_reject.Duplicate;
      end.Collapse(0);  // set the ending boundary for the search
      rng_reject.RemoveContainerTags();
      rng_reject = readtree(start, end);
    rng_reject= null;
      return;
  }
}

//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------

function readtree(start_rng, end_rng){  
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent
          element = start_rng.ContainerNode.nodeName;
        if(start_rng.isParentElement("Annotation")){
          Annot_parent = true;
        } else {
          Annot_parent = false;
        }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
      
    }
  start_rng = null;
  return(end_rng);
 }
var Annot_parent = false;

if (CanRunMacros()) {
  if(Selection.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
  doRejectChange();
}]]></MACRO>
 
<MACRO name="Reject Changes" key="" lang="JScript" id="1909" desc="Deletes all marked changes"><![CDATA[
//******************************************************************************************************
// Rejects to incorporate all the marked changes
//******************************************************************************************************
function doRejectAllChanges()
{
  var r = ActiveDocument.Range;
  r.MoveToDocumentStart();
  Selection.MoveToDocumentStart();
  while (r.MoveToElement("Deletion")) {
  Selection.MoveToElement("Deletion");
    //Selection.RemoveContainerTags();
    var rng = r.Duplicate;
    doRejectDelChange(r);
  }
  r.MoveToDocumentStart();
  while (r.MoveToElement("Insertion")) {
    r.SelectContainerContents();
    r.Delete();
    r.RemoveContainerTags();
  }
  r = null;
}

//------------------------------------------------------------------------------------------------------

function doRejectDelChange(rng_reject){
    rng_reject.SelectContainerContents();
    start = rng_reject.Duplicate;
      start.Collapse(1);  // set the starting boundary for the search
      end = rng_reject.Duplicate;
      end.Collapse(0);  // set the ending boundary for the search
      rng_reject.RemoveContainerTags();
      rng_reject = readtree(start, end);
    rng_reject= null;
      return;
}

function readtree(start_rng, end_rng){  
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent
          element = start_rng.ContainerNode.nodeName;
        if(start_rng.isParentElement("Annotation")){
          Annot_parent = true;
        } else {
          Annot_parent = false;
        }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
      
    }
  start_rng = null;
  return(end_rng);
 }
//********************************************************************************************************
var Annot_parent = false;
if (CanRunMacros()) {
  var confirm = Application.Confirm("Do you want to Reject all changes without reviewing them?");
  if(confirm){
    doRejectAllChanges();
  }
}
]]></MACRO>
 
<MACRO name="Show Original" key="" lang="JScript" id="20207" desc="Displays the document without any marked changes"><![CDATA[
//*****************************************************************************************************
// displays the original document i.e. without any tracked changes 
//*****************************************************************************************************
function doShowOriginal()
{
  var docProps = ActiveDocument.CustomDocumentProperties;
  docProps.item("Highlighting").value = false;
  docProps.item("ShowOriginal").value = true;
  var r = ActiveDocument.Range;
  r.MoveToDocumentStart();
  while (r.MoveToElement("Deletion")) {
//    r.HiddenContainer = false;
    r.ContainerStyle = "";

    //r.ReadOnlyContainer = false;
    //r.ContainerAttribute("display") = "showNormal";
    //r.ReadOnlyContainer = true;
  }
  r.MoveToDocumentStart();
  while (r.MoveToElement("Insertion")) {
    if(!r.HiddenContainer){
      r.HiddenContainer = true;
    }
  }
  r = null;
}

if (CanRunMacros()) {
  doShowOriginal();
}
]]></MACRO>

<MACRO name="Show Changes With Highlighting" key="" lang="JScript" id="1908" desc="Displays all marked changes with highlighting"><![CDATA[
//****************************************************************************************************** 
// Highlights all the marked changes by setting the container style of all 
// Insertion and Deletion Elements
//******************************************************************************************************
function doShowChangesWithHL(){
  var docProps = ActiveDocument.CustomDocumentProperties;
  var hideannotations = docProps.item("HideAnnotations").value
  docProps.item("Highlighting").value = true;
  docProps.item("ShowOriginal").value = false;
  var rng_HL = ActiveDocument.Range;
  rng_HL.MoveToDocumentStart();
  while(rng_HL.MoveToElement("Insertion")){
    rng_HL.HiddenContainer = false;
    if(rng_HL.isParentElement("Annotation")){
      Annot_parent = true;
    } else {
      Annot_parent = false;
    }
    rng_HL.ContainerStyle = getAnnot_ReMa_Styles("Insertion", Annot_parent);
    var rng2 = rng_HL.Duplicate;
    rng2.SelectElement();
    txt = rng2.ContainerStyle;
    rng2.ContainerStyle = txt;
    rng2 = null;
  }
  rng_HL.MoveToDocumentStart();
  while(rng_HL.MoveToElement("Deletion")){
    rng_HL.SelectContainerContents();
    start = rng_HL.Duplicate;
    start.Collapse(1);  // set the starting boundary for the search
    end = rng_HL.Duplicate;
    end.Collapse(0);  // set the ending boundary for the search
    if(rng_HL.isParentElement("Annotation")){
      Annot_parent = true;
    } else {
      Annot_parent = false;
    }
    rng_HL.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
    rng_HL = readtree(start, end);
  }
  rng_HL= null;
  return;
}

//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------

function readtree(start_rng, end_rng){  
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent
          element = start_rng.ContainerNode.nodeName;
          if(element == "Annotation"){
            if(start_rng.isParentElement("Insertion")){
            element = "Annotation_in_Insertion";
          } else if(start_rng.isParentElement("Deletion"))  {
            element = "Annotation_in_Deletion";
          } 
        } else {
          element = "Deletion";
        }
        if(start_rng.isParentElement("Annotation")){
          Annot_parent = true;
        } else {
          Annot_parent = false;
        }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
      
    }
  start_rng = null;
  return(end_rng);
}
//******************************************************************************************************
//******************************************************************************************************
var Annot_parent = false;
var element;
if (CanRunMacros()) {
  if(Selection.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
    doShowChangesWithHL();
}]]></MACRO>

<MACRO name="Show Changes Without Highlighting" key="" lang="JScript" id="1907" desc="Displays all marked changes without highlighting"><![CDATA[
//****************************************************************************************************** 
// Displays the document with marked changes but without highlighting 
//****************************************************************************************************** 
function doShowChangesWOH(){
  var docProps = ActiveDocument.CustomDocumentProperties;
  var hideannotations = docProps.item("Highlighting").value;
  docProps.item("Highlighting").value = false;
  docProps.item("ShowOriginal").value = false;
  var rng_HL = ActiveDocument.Range;
  rng_HL.MoveToDocumentStart();
  while(rng_HL.MoveToElement("Insertion")){
    rng_HL.HiddenContainer = false;
    if(rng_HL.isParentElement("Annotation")){
      Annot_parent = true;
    } else {
      Annot_parent = false;
    }
    rng_HL.ContainerStyle = getAnnot_ReMa_Styles("Insertion", Annot_parent);
    rng2 = null;  // clean up
  }
  rng_HL.MoveToDocumentStart();
  while(rng_HL.MoveToElement("Deletion")){
    rng_HL.SelectContainerContents();
    start = rng_HL.Duplicate;
    start.Collapse(1);  // set the starting boundary for the search
    end = rng_HL.Duplicate;
    end.Collapse(0);  // set the ending boundary for the search
    if(rng_HL.isParentElement("Annotation")){
      Annot_parent = true;
    } else {
      Annot_parent = false;
    }
    rng_HL.ContainerStyle = getAnnot_ReMa_Styles("Deletion", Annot_parent);
    rng_HL = readtree(start, end);
  }
  rng_HL= null;
  return;
}

//------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------

function readtree(start_rng, end_rng){  
    while(true){  // Move to next element
      var temp_rng = start_rng.Duplicate;
      start_rng.GoToNext(0);
      if(temp_rng.isEqual(start_rng)){
        temp_rng = null;
        break;
      } else {
        if(start_rng.IsLessThan(end_rng)){  // if it is with in the range of the selected parent
          element = start_rng.ContainerNode.nodeName;
          if(element == "Annotation"){
            if(start_rng.isParentElement("Insertion")){
            element = "Annotation_in_Insertion";
          } else if(start_rng.isParentElement("Deletion"))  {
            element = "Annotation_in_Deletion";
          } 
        } else {
          element = "Deletion";
        }
        if(start_rng.isParentElement("Annotation")){
          Annot_parent = true;
        } else {
          Annot_parent = false;
        }
          start_rng.ContainerStyle = getAnnot_ReMa_Styles(element, Annot_parent);
        } else {
          break;
        }
      }
      
    }
  start_rng = null;
  return(end_rng);
 }
var Annot_parent = false;

if (CanRunMacros()) {
  if(Selection.isParentElement("Annotation")){
    Annot_parent = true;
  } else {
    Annot_parent = false;
  }
    doShowChangesWOH();
}]]></MACRO>

<MACRO name="Find Next" key="" lang="JScript" id="1911" desc="Moves the selection to the next marked change if any" tooltip="Find Next Change"><![CDATA[
//******************************************************************************************************
// Moves the selection to the next Marked change in the document
// If the end of the document is reached the search is resumed from the beginning of the document 
//******************************************************************************************************
function doFindNext(){
  var docProps = ActiveDocument.CustomDocumentProperties;
  if(docProps.item("InsNextPrev").value == "True"){
    if(Selection.ContainerNode){
      if(Selection.ContainerNode.parentNode.nodeName == "Insertion"){
        Application.Run("Find Prev");
      }else{
        docProps.item("InsNextPrev").value = false;
        doFindNext();
      }
    }
    docProps.item("InsNextPrev").value = false;
  }
  else {
    if(docProps.item("DelNextPrev").value == "True"){
      if(Selection.ContainerNode){
        if(Selection.ContainerNode.parentNode.nodeName == "Deletion"){
          Application.Run("Find Prev");
        }else{
          docProps.item("DelNextPrev").value = false;
          doFindNext();
        }
      }
      docProps.item("DelNextPrev").value = false;
    }
    else {
      var rng1 = ActiveDocument.Range;
      var rng2 = rng1.Duplicate;

      var Insertion = rng1.MoveToElement("Insertion");
      var Deletion = rng2.MoveToElement("Deletion");
      if(Insertion && Deletion){
        if(rng1.IsLessThan(rng2)){
          if(hasChildren(rng1.Duplicate, "Insertion")){
            Selection.MoveToElement("Insertion");
            Selection.SelectAfterContainer();
            docProps.item("InsNextPrev").value = true;
            Application.Run("Find Prev");
          }else{
            Selection.MoveToElement("Insertion");
            Selection.SelectContainerContents();
          }
        }else{
          if(hasChildren(rng1.Duplicate, "Deletion")){
            Selection.MoveToElement("Deletion");
            Selection.SelectAfterContainer();
            docProps.item("DelNextPrev").value = true;
            Application.Run("Find Prev");
          }else{
            Selection.MoveToElement("Deletion");
            Selection.SelectContainerContents();
          }
        }
      }
      else {
        if(Insertion){
          if(hasChildren(rng1.Duplicate, "Insertion")){
            Selection.MoveToElement("Insertion");
            Selection.SelectAfterContainer();
            docProps.item("InsNextPrev").value = true;
            Application.Run("Find Prev");
          }else{
            Selection.MoveToElement("Insertion");
            Selection.SelectContainerContents();
          }
        }
        else {
          if(Deletion){
            if(hasChildren(rng1.Duplicate, "Deletion")){
              Selection.MoveToElement("Deletion");
              Selection.SelectAfterContainer();
              docProps.item("DelNextPrev").value = true;
              Application.Run("Find Prev");
            }else{
              Selection.MoveToElement("Deletion");
              Selection.SelectContainerContents();
            }
          }
          else {
            var InsertionList = ActiveDocument.getElementsByTagName("Insertion"); 
            var DeletionList = ActiveDocument.getElementsByTagName("Deletion"); 
            if(InsertionList.length != 0 || DeletionList.length != 0){
              var search = Application.Confirm("Reached the end of the Document. Do you want to continue searching from the beginning of the document?");
              if(search){
                Selection.MoveToDocumentStart();
                var rng = ActiveDocument.Range;
                rng.MoveToDocumentStart();
                doFindNext();
              }
            }else{
              Application.Alert("Found no tracked changes");
            }
          }
        }
      }
      rng1 = null;
      rng2 = null;
    }
  }
}
function hasChildren(rng_chld, elemName){
  if(rng_chld.ContainerNode){
    if(rng_chld.ContainerNode.hasChildNodes()){ 
      var children = rng_chld.ContainerNode.childNodes;
      for(var i=0; i<children.length; i++){
        if(children.item(i).nodeName == elemName){
            return true;
        }
      }
      return false;
    }else{
      return false;
    }
  }
}
  
if (CanRunMacros()) {
  doFindNext();
}
]]></MACRO>

<MACRO name="Find Prev" key="" lang="JScript" id="1910" desc="Moves the selection to the previous marked change if any"><![CDATA[
//******************************************************************************************************
// Moves the selection to the previous Marked change in the document
// If the beginning of the document is reached the search is resumed from the end of the document 
//******************************************************************************************************
function doFindPrev(){
  var rng1 = ActiveDocument.Range;
  var rng2 = rng1.Duplicate;

  var Insertion = rng1.MoveToElement("Insertion", false);
  var Deletion = rng2.MoveToElement("Deletion", false);
  if(Insertion && Deletion){
    if(rng1.IsGreaterThan(rng2)){
      Selection.MoveToElement("Insertion", false);
      Selection.SelectContainerContents();
    }else{
      Selection.MoveToElement("Deletion", false);
      Selection.SelectContainerContents();
    }
  } else if(Insertion){
    Selection.MoveToElement("Insertion", false);
    Selection.SelectContainerContents();
  } else if(Deletion){
    Selection.MoveToElement("Deletion", false);
    Selection.SelectContainerContents();
  } else {
    var InsertionList = ActiveDocument.getElementsByTagName("Insertion"); 
    var DeletionList = ActiveDocument.getElementsByTagName("Deletion"); 
    if(InsertionList.length != 0 || DeletionList.length != 0){
      var search = Application.Confirm("Reached the beginning of the Document. Do you want to continue searching from the end of the document?");
      if(search){
        Selection.MoveToDocumentEnd();
        doFindPrev();
      }
    }else{
      Application.Alert("Found no tracked changes");
    }
  }
  rng1 = null;
  rng2 = null;
}

if (CanRunMacros()) {
  doFindPrev();
}
]]></MACRO>

<MACRO name="Clean Up Empty" key="" lang="JScript" id="1810" desc="Deletes all empty annotations i.e. with no content and comment"><![CDATA[
//*******************************************************************************************************
// Removes all empty annotations.  An empty Annotation is one with no comment and is 
// not surrounding any text
//*******************************************************************************************************
function doCleanEmpty(){

  var rng_clean = ActiveDocument.Range;
  rng_clean.MoveToDocumentStart();
  var nodeList = ActiveDocument.getElementsByTagName("Annotation");
  var i;
  var node;
  for (i = 0; i < nodeList.length; i++) {
    node = nodeList.item(i);
    rng_clean.SelectNodeContents(node);
    if (rng_clean.ContainerAttribute("Comment") == "" && rng_clean.Text == "") {
      rng_clean.RemoveContainerTags();
      nodeList = ActiveDocument.getElementsByTagName("Annotation");
      i = -1;
    }
  }
  rng_clean = null;
}

if (CanRunMacros()) {
  doCleanEmpty();
}
]]></MACRO>

<!--
<MACRO name="Graphic_OnShouldCreate" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    // Only create for FileRef's with .avi extensions otherwise default to
    // built-in XMetaL behavior...
    ipog.ShouldCreate = false;
    var domnode = ipog.Node;
    var attrnode = domnode.attributes.getNamedItem("FileRef");
    if (attrnode != null && attrnode.value != null) {
      var i = attrnode.value.lastIndexOf(".avi"); // Don't no if this is case-insensitive
      if (i != -1) {
        ipog.ShouldCreate = true; // Has .avi extension, instruct to create control!
      }
    }
  }
]]></MACRO> 
 
<MACRO name="Graphic_OnInitialize" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    var domnode = ipog.Node;

    // Set width of control (pixels) from Graphic's "Width" attribute
    var attrnode = domnode.attributes.getNamedItem("Width");
    if (attrnode != null) {
      ipog.Width = attrnode.value; // Set width in pixels from Graphic Width attr
    }

    // Set height of control (pixels) from Graphic's "Depth" attribute
    attrnode = domnode.attributes.getNamedItem("Depth");
    if (attrnode != null) {
      ipog.Height = attrnode.value; // Set height in pixels from Graphic Depth attr
    }

    // Set MediaPlayer "FileName" property from Graphic's "FileRef" attribute
    // but note that MediaPlayer needs an absolute filepath...
    attrnode = domnode.attributes.getNamedItem("FileRef");
    if (attrnode != null) {
      var str = ipog.Document.LocalPath;
      str = str + "\\";
      str = str + attrnode.value;
      ipog.Control.ShowControls = false; 
      ipog.Control.ShowDisplay = false;
      ipog.Control.AutoStart    = false; // Don't start until "OpenComplete" event
      ipog.Control.AutoRewind   = false;
      ipog.Control.Enabled      = false; // Disables UI
      var mp = ipog.Control.MediaPlayer;
      if (mp != null) {
        mp.ClickToPlay = false; // Disables special UI feature
        mp.Open(str);
      } else {
        Application.Alert("No MediaPlayer object!");
      }
    }
  }
]]></MACRO>

<MACRO name="Graphic_OnFocus" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    if (ipog.UserMovedIntoControl) {
      ipog.Control.CurrentPosition = 0.0;   // Rewind
      ipog.Control.Run();
    } else {
      ipog.Control.CurrentPosition = ipog.Control.Duration; // Force to last frame
      ipog.Control.Stop();
    }
  }
    
]]></MACRO> 


<MACRO name="Graphic_OpenComplete" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    ipog.Control.Run();
  }
    
]]></MACRO> 
-->

<MACRO name="Graphic_OnShouldCreate" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    // Only create for FileRef's with .html extensions otherwise default to
    // built-in XMetaL behavior...
    ipog.ShouldCreate = false;
    var domnode = ipog.Node;
    if (domnode != null) {
      var attrnode = domnode.attributes.getNamedItem("FileRef");
      if (attrnode != null && attrnode.value != null) {
        var i = attrnode.value.lastIndexOf(".html"); // Don't no if this is case-insensitive
        if (i != -1) {
          ipog.ShouldCreate = true; // Has .html extension, instruct to create control!
        }
      }
    }
  }
]]></MACRO>

<MACRO name="Graphic_OnInitialize" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    var domnode = ipog.Node;

    // Set width of control (pixels) from Graphic's "Width" attribute
    var attrnode = domnode.attributes.getNamedItem("Width");
    if (attrnode != null) {
      ipog.Width = attrnode.value; // Set width in pixels from Graphic Width attr
    }

    // Set height of control (pixels) from Graphic's "Depth" attribute
    attrnode = domnode.attributes.getNamedItem("Depth");
    if (attrnode != null) {
      ipog.Height = attrnode.value; // Set height in pixels from Graphic Depth attr
    }

    // Set IE Control "FileName" property from Graphic's "FileRef" attribute
    // but note that the IE Control needs an absolute filepath...
    attrnode = domnode.attributes.getNamedItem("FileRef");
    if (attrnode != null) {
      var str = ipog.Document.LocalPath;
      str = str + "\\";
      str = str + attrnode.value;
      var mp = ipog.Control;
      if (mp != null) {
        mp.Navigate2(str, 2);
      } else {
        Application.Alert("No IE Control object!");
      }
    }
  }
]]></MACRO>


<!--
<MACRO name="Graphic_OpenComplete" key="" hide="true" lang="JScript"><![CDATA[
  // SoftQuad Script Language JSCRIPT:
  var ipog = Application.ActiveInPlaceControl;
  if (ipog != null) {
    ipog.Control.Run();
  }
    
]]></MACRO>
-->


</MACROS> 
