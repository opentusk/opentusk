<?xml version="1.0"?>
<!DOCTYPE MACROS SYSTEM "macros.dtd">

<MACROS> 

<!--Tufts Customization Macros-->

<MACRO name="View Greek Toolbar" lang="JScript" desc="Insert Greek Toolbar" hide="false"><![CDATA[
 //access the command bar
var cmdBar = Application.CommandBars.item("Greek");
Application.Alert(cmdBar.name);
cmdBar.Visible = true;  // show the command bar
]]></MACRO> 

<MACRO name="View Arrows Toolbar" lang="JScript" desc="Insert Arrows Toolbar" hide="false"><![CDATA[
 //access the command bar
var cmdBar = Application.CommandBars.item("Arrows");
Application.Alert(cmdBar.name);
cmdBar.Visible = true;  // show the command bar
]]></MACRO> 

<MACRO name="Toggle Strong" key="" lang="JScript" id="20403" tooltip="Insert or Remove Strong" desc="Insert, Surround, or Remove Strong (Bold)"><![CDATA[

function doToggleStrong() {
// If strong already present, remove tags.
// If not:  If insertion pt, insert strong template
//          If selection, surround selection with strong tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("strong")) {
    if (rng.ContainerName != "strong") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("strong")) {
        rng.InsertWithTemplate("strong");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert strong element here.");
      }
    }
    else {
      if (rng.CanSurround("strong")) {
        rng.Surround ("strong");
      }
      else {
        Application.Alert("Cannot change Selection to strong element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleStrong();
}
]]> </MACRO> 

<MACRO name="Toggle Foreign" key="" lang="JScript" id="" tooltip="Insert or Remove Foreign" desc="Insert, 

Surround, or Remove Foreign"><![CDATA[

function doToggleForeign() {
// If foreign already present, remove tags.
// If not:  If insertion pt, insert foreign template
//          If selection, surround selection with foreign tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("foreign")) {
    if (rng.ContainerName != "foreign") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("foreign")) {
        rng.InsertWithTemplate("foreign");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert foreign element here.");
      }
    }
    else {
      if (rng.CanSurround("foreign")) {
        rng.Surround ("foreign");
      }
      else {
        Application.Alert("Cannot change Selection to foreign element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleForeign();
}
]]> </MACRO> 

<MACRO name="Toggle Index-Item" key="" lang="JScript" id="" tooltip="Insert or Remove Index-Item" desc="Insert, Surround, or Remove Index-Item"><![CDATA[

function doToggleIndexItem() {
// If index-item already present, remove tags.
// If not:  If insertion pt, insert index-item template
//          If selection, surround selection with index-item tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("index-item")) {
    if (rng.ContainerName != "index-item") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("index-item")) {
        rng.InsertWithTemplate("index-item");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert index item element here.");
      }
    }
    else {
      if (rng.CanSurround("index-item")) {
        rng.Surround ("index-item");
      }
      else {
        Application.Alert("Cannot change Selection to index item element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleIndexItem();
}
]]> </MACRO> 

<MACRO name="Toggle Topic Sentence" key="" lang="JScript" id="" tooltip="Insert or Remove Topic 

Sentence" desc="Insert, Surround, or Remove Topic Sentence"><![CDATA[
function doToggleTopicSentence() {
// If topic-sentence already present, remove tags.
// If not:  If insertion pt, insert topic-sentence template
//          If selection, surround selection with topic-sentence tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("topic-sentence")) {
    if (rng.ContainerName != "topic-sentence") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("topic-sentence")) {
        rng.InsertWithTemplate("topic-sentence");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert topic-sentence element here.");
      }
    }
    else {
      if (rng.CanSurround("topic-sentence")) {
        rng.Surround ("topic-sentence");
      }
      else {
        Application.Alert("Cannot change selection to topic-sentence element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleTopicSentence();
}
]]> </MACRO> 

<MACRO name="Toggle Objective Item" key="" lang="JScript" id="" tooltip="Insert or Remove Objective Item" desc="Insert, Surround, or Remove Objective Item"><![CDATA[
function doToggleObjectiveItem() {
// If objective-item already present, remove tags.
// If not:  If insertion pt, insert objective-item template
//          If selection, surround selection with objective-item tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("objective-item")) {
    if (rng.ContainerName != "objective-item") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("objective-item")) {
        rng.InsertWithTemplate("objective-item");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert objective-item element here.");
      }
    }
    else {
      if (rng.CanSurround("objective-item")) {
        rng.Surround ("objective-item");
      }
      else {
        Application.Alert("Cannot change selection to objective-item element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleObjectiveItem();
}
]]> </MACRO> 

<MACRO name="Toggle Summary" key="" lang="JScript" id="" tooltip="Insert or Remove Summary" desc="Insert, Surround, or Remove Summary"><![CDATA[
function doToggleSummary() {
// If summary already present, remove tags.
// If not:  If insertion pt, insert summary template
//          If selection, surround selection with summary tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("summary")) {
    if (rng.ContainerName != "summary") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("summary")) {
        rng.InsertWithTemplate("summary");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert summary element here.");
      }
    }
    else {
      if (rng.CanSurround("summary")) {
        rng.Surround ("summary");
      }
      else {
        Application.Alert("Cannot change selection to summary element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleSummary();
}
]]> </MACRO> 

<MACRO name="Toggle Nugget" key="" lang="JScript" id="" tooltip="Insert or Remove Nugget" desc="Insert, 

Surround, or Remove Nugget"><![CDATA[
function doToggleNugget() {
// If nugget already present, remove tags.
// If not:  If insertion pt, insert nugget template
//          If selection, surround selection with nugget tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("nugget")) {
    if (rng.ContainerName != "nugget") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("nugget")) {
        rng.InsertWithTemplate("nugget");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert nugget element here.");
      }
    }
    else {
      if (rng.CanSurround("nugget")) {
        rng.Surround ("nugget");
      }
      else {
        Application.Alert("Cannot change selection to nugget element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleNugget();
}
]]> </MACRO> 

<MACRO name="Toggle Keyword" key="" lang="JScript" id="" tooltip="Insert or Remove Keyword" desc="Insert, Surround, or Remove Keyword"><![CDATA[
function doToggleKeyword() {
// If keyword already present, remove tags.
// If not:  If insertion pt, insert keyword template
//          If selection, surround selection with keyword tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("keyword")) {
    if (rng.ContainerName != "keyword") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("keyword")) {
        rng.InsertWithTemplate("keyword");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert keyword element here.");
      }
    }
    else {
      if (rng.CanSurround("keyword")) {
        rng.Surround ("keyword");
      }
      else {
        Application.Alert("Cannot change selection to keyword element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleKeyword();
}
]]> </MACRO> 

<MACRO name="Toggle Emphasis" key="" lang="JScript" id="20409" tooltip="Insert or Remove Emphasis" desc="Insert, Surround, or Remove Emphasis (Italic)"><![CDATA[
function doToggleEmphasis() {
// If emphasis already present, remove tags.
// If not:  If insertion pt, insert emphasis template
//          If selection, surround selection with emphasis tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("emph")) {
    if (rng.ContainerName != "emph") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("emph")) {
        rng.InsertWithTemplate("emph");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert Emphasis element here.");
      }
    }
    else {
      if (rng.CanSurround("emph")) {
        rng.Surround ("emph");
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

<MACRO name="Toggle Superscript" key="" lang="JScript" tooltip="Insert or Remove Superscript" desc="Insert, Surround, or Remove Superscript" id="1209"><![CDATA[
function doToggleSuperscript() {
// If superscript already present, remove tags.
// If not:  If insertion pt, insert superscript template
//          If selection, surround selection with superscript tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("super")) {
    if (rng.ContainerName != "super") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("super")) {
        rng.InsertWithTemplate("super");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert Superscript element here.");
      }
    }
    else {
      if (rng.CanSurround("super")) {
        rng.Surround ("super");
      }
      else {
        Application.Alert("Cannot change Selection to Superscript element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleSuperscript();
}
]]></MACRO> 

<MACRO name="Toggle Subscript" key="" lang="JScript" tooltip="Insert or Remove Subscript" desc="Insert, 

Surround, or Remove Subscript" id="1208"><![CDATA[
function doToggleSubscript() {
// If subscript already present, remove tags.
// If not:  If insertion pt, insert subscript template
//          If selection, surround selection with subscript tags.
  var rng = ActiveDocument.Range;
  if (rng.IsParentElement("sub")) {
    if (rng.ContainerName != "sub") {
      rng.SelectElement();
    }
    rng.RemoveContainerTags();
  }
  else {
    if (rng.IsInsertionPoint) {
      if (rng.CanInsert("sub")) {
        rng.InsertWithTemplate("sub");
        rng.SelectContainerContents();
        rng.Select();
      }
      else {
        Application.Alert("Cannot insert Subscript element here.");
      }
    }
    else {
      if (rng.CanSurround("sub")) {
        rng.Surround ("sub");
      }
      else {
        Application.Alert("Cannot change Selection to Subscript element.");
      }
    }
  }
  rng = null;
}

if (CanRunMacros()) {
  doToggleSubscript();
}
]]></MACRO> 

<MACRO name="Init_JScript_Macros" lang="JScript" id="" desc="initialize JScript macros" hide="true"><![CDATA[

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

]]></MACRO> 

<MACRO name="Insert Lower Alpha" key="" lang="JScript" tooltip="Lower Alpha" desc="Insert Lower Alpha" id="2000"><![CDATA[
Selection.PasteString ("&alpha;");
]]></MACRO> 

<MACRO name="Insert Lower Beta" key="" lang="JScript" tooltip="Lower Beta" desc="Insert Lower Beta" id="2001"><![CDATA[
Selection.PasteString ("&beta;");
]]></MACRO> 

<MACRO name="Insert Lower Gamma" key="" lang="JScript" tooltip="Lower Gamma" desc="Insert Lower 

Gamma" id="2002"><![CDATA[
Selection.PasteString ("&gamma;");
]]></MACRO> 

<MACRO name="Insert Lower Delta" key="" lang="JScript" tooltip="Lower Delta" desc="Insert Lower Delta" id="2003"><![CDATA[
Selection.PasteString ("&delta;");
]]></MACRO> 

<MACRO name="Insert Lower Epsilon" key="" lang="JScript" tooltip="Lower Epsilon" desc="Insert Lower 

Epsilon" id="2004"><![CDATA[
Selection.PasteString ("&epsilon;");
]]></MACRO> 

<MACRO name="Insert Lower Zeta" key="" lang="JScript" tooltip="Lower Zeta" desc="Insert Lower Zeta" id="2005"><![CDATA[
Selection.PasteString ("&zeta;");
]]></MACRO> 

<MACRO name="Insert Lower Eta" key="" lang="JScript" tooltip="Lower Eta" desc="Insert Lower Eta" id="2006"><![CDATA[
Selection.PasteString ("&eta;");
]]></MACRO> 

<MACRO name="Insert Lower Theta" key="" lang="JScript" tooltip="Lower Theta" desc="Insert Lower Theta" id="2007"><![CDATA[
Selection.PasteString ("&theta;");
]]></MACRO> 

<MACRO name="Insert Lower Iota" key="" lang="JScript" tooltip="Lower Iota" desc="Insert Lower Iota" id="2008"><![CDATA[
Selection.PasteString ("&iota;");
]]></MACRO> 

<MACRO name="Insert Lower Kappa" key="" lang="JScript" tooltip="Lower Kappa" desc="Insert Lower Kappa" id="2009"><![CDATA[
Selection.PasteString ("&kappa;");
]]></MACRO> 

<MACRO name="Insert Lower Lambda" key="" lang="JScript" tooltip="Lower Lambda" desc="Insert Lower 

Lambda" id="2010"><![CDATA[
Selection.PasteString ("&lambda;");
]]></MACRO> 

<MACRO name="Insert Lower Mu" key="" lang="JScript" tooltip="Lower Mu" desc="Insert Lower Mu" id="2011"><![CDATA[
Selection.PasteString ("&mu;");
]]></MACRO> 

<MACRO name="Insert Lower Nu" key="" lang="JScript" tooltip="Lower Nu" desc="Insert Lower Nu" id="2012"><![CDATA[
Selection.PasteString ("&nu;");
]]></MACRO> 

<MACRO name="Insert Lower Xi" key="" lang="JScript" tooltip="Lower Xi" desc="Insert Lower Xi" id="2013"><![CDATA[
Selection.PasteString ("&xi;");
]]></MACRO> 

<MACRO name="Insert Lower Omicron" key="" lang="JScript" tooltip="Lower Omicron" desc="Insert Lower 

Omicron" id="2014"><![CDATA[
Selection.PasteString ("&omicron;");
]]></MACRO> 

<MACRO name="Insert Lower Pi" key="" lang="JScript" tooltip="Lower Pi" desc="Insert Lower Pi" id="2015"><![CDATA[
Selection.PasteString ("&pi;");
]]></MACRO> 

<MACRO name="Insert Lower Rho" key="" lang="JScript" tooltip="Lower Rho" desc="Insert Lower Rho" id="2016"><![CDATA[
Selection.PasteString ("&rho;");
]]></MACRO> 

<MACRO name="Insert Lower Sigma 1" key="" lang="JScript" tooltip="Lower Sigma (Final)" desc="Insert 

Lower Sigma 1" id="2017"><![CDATA[
Selection.PasteString ("&sigmaf;");
]]></MACRO> 

<MACRO name="Insert Lower Sigma 2" key="" lang="JScript" tooltip="Lower Sigma (2)" desc="Insert Lower 

Sigma 2" id="2018"><![CDATA[
Selection.PasteString ("&sigma;");
]]></MACRO> 

<MACRO name="Insert Lower Tau" key="" lang="JScript" tooltip="Lower Tau" desc="Insert Lower Tau" id="2019"><![CDATA[
Selection.PasteString ("&tau;");
]]></MACRO> 

<MACRO name="Insert Lower Upsilon" key="" lang="JScript" tooltip="Lower Upsilon" desc="Insert Lower 

Upsilon" id="2020"><![CDATA[
Selection.PasteString ("&upsilon;");
]]></MACRO> 

<MACRO name="Insert Lower Phi" key="" lang="JScript" tooltip="Lower Phi" desc="Insert Lower Phi" id="2021"><![CDATA[
Selection.PasteString ("&phi;");
]]></MACRO> 

<MACRO name="Insert Lower Chi" key="" lang="JScript" tooltip="Lower Chi" desc="Insert Lower Chi" id="2022"><![CDATA[
Selection.PasteString ("&chi;");
]]></MACRO> 

<MACRO name="Insert Lower Psi" key="" lang="JScript" tooltip="Lower Psi" desc="Insert Lower Psi" id="2023"><![CDATA[
Selection.PasteString ("&psi;");
]]></MACRO> 

<MACRO name="Insert Lower Omega" key="" lang="JScript" tooltip="Lower Omega" desc="Insert Lower 

Omega" id="2024"><![CDATA[
Selection.PasteString ("&omega;");
]]></MACRO> 

<MACRO name="Insert Upper Gamma" key="" lang="JScript" tooltip="Upper Gamma" desc="Insert Upper 

Gamma" id="2030"><![CDATA[
Selection.PasteString ("&Gamma;");
]]></MACRO> 

<MACRO name="Insert Upper Delta" key="" lang="JScript" tooltip="Upper Delta" desc="Insert Upper Delta" id="2031"><![CDATA[
Selection.PasteString ("&Delta;");
]]></MACRO> 

<MACRO name="Insert Upper Theta" key="" lang="JScript" tooltip="Upper Theta" desc="Insert Upper Theta" id="2032"><![CDATA[
Selection.PasteString ("&Theta;");
]]></MACRO> 

<MACRO name="Insert Upper Lambda" key="" lang="JScript" tooltip="Upper Lambda" desc="Insert Upper 

Lambda" id="2033"><![CDATA[
Selection.PasteString ("&Lambda;");
]]></MACRO> 

<MACRO name="Insert Upper Xi" key="" lang="JScript" tooltip="Upper Xi" desc="Insert Upper Xi" id="2034"><![CDATA[
Selection.PasteString ("&Xi;");
]]></MACRO> 

<MACRO name="Insert Upper Pi" key="" lang="JScript" tooltip="Upper Pi" desc="Insert Upper Pi" id="2035"><![CDATA[
Selection.PasteString ("&Pi;");
]]></MACRO> 

<MACRO name="Insert Upper Sigma" key="" lang="JScript" tooltip="Upper Sigma" desc="Insert Upper Sigma" id="2036"><![CDATA[
Selection.PasteString ("&Sigma;");
]]></MACRO> 

<MACRO name="Insert Upper Phi" key="" lang="JScript" tooltip="Upper Phi" desc="Insert Upper Phi" id="2037"><![CDATA[
Selection.PasteString ("&Phi;");
]]></MACRO> 

<MACRO name="Insert Upper Psi" key="" lang="JScript" tooltip="Upper Psi" desc="Insert Upper Psi" id="2038"><![CDATA[
Selection.PasteString ("&Psi;");
]]></MACRO> 

<MACRO name="Insert Upper Omega" key="" lang="JScript" tooltip="Upper Omega" desc="Insert Upper 

Omega" id="2039"><![CDATA[
Selection.PasteString ("&Omega;");
]]></MACRO> 

<MACRO name="Insert One-third Fraction" key="" lang="JScript" tooltip="One-third Fraction" desc="Insert 

One-third Fraction" id="2218"><![CDATA[
Selection.PasteString ("&frac13;");
]]></MACRO> 

<MACRO name="Insert Two-thirds Fraction" key="" lang="JScript" tooltip="Two-thirds Fraction" desc="Insert 

Two-thirds Fraction" id="2219"><![CDATA[
Selection.PasteString ("&frac23;");
]]></MACRO> 

<MACRO name="Insert Prescription Take" key="" lang="JScript" tooltip="Prescription Take" desc="Insert 

Prescription Take" id="2202"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&rx;</span>");
]]></MACRO> 

<MACRO name="Insert L B Bar" key="" lang="JScript" tooltip="L B Bar (pound)" desc="Insert  L B Bar 

(pound)" id="2201"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&lbbar;</span>");
]]></MACRO> 

<MACRO name="Insert Care Of" key="" lang="JScript" tooltip="Care Of" desc="Insert Care Of Symbol" id="2200"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&co;</span>");
]]></MACRO> 

<MACRO name="Insert Ounce" key="" lang="JScript" tooltip="Ounce" desc="Insert Ounce" id="2203"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ounce;</span>");
]]></MACRO> 

<MACRO name="Insert Mho" key="" lang="JScript" tooltip="Mho" desc="Insert Mho (inverted Ohm)" id="2204"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&mho;</span>");
]]></MACRO> 

<MACRO name="Insert One-eighth Fraction" key="" lang="JScript" tooltip="One-eighth Fraction" desc="Insert 

One-eighth Fraction" id="2220"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&frac18;</span>");
]]></MACRO> 

<MACRO name="Insert Three-eighths Fraction" key="" lang="JScript" tooltip="Three-eighths Fraction" desc="Insert Three-eighths Fraction" id="2221"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&frac38;</span>");
]]></MACRO> 

<MACRO name="Insert Five-eighths Fraction" key="" lang="JScript" tooltip="Five-eighths Fraction" desc="Insert Five-eighths Fraction" id="2222"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&frac58;</span>");
]]></MACRO> 

<MACRO name="Insert Seven-eighths Fraction" key="" lang="JScript" tooltip="Seven-eighths Fraction" desc="Insert Seven-eighths Fraction" id="2223"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&frac78;</span>");
]]></MACRO> 

<MACRO name="Insert Leftwards Arrow" key="" lang="JScript" tooltip="Leftwards Arrow" desc="Insert 

Leftwards Arrow" id="2100"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&larr;</span>");
]]></MACRO> 

<MACRO name="Insert Rightwards Arrow" key="" lang="JScript" tooltip="Rightwards Arrow" desc="Insert 

Rightwards Arrow" id="2102"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&rarr;</span>");
]]></MACRO> 

<MACRO name="Insert Upwards Arrow" key="" lang="JScript" tooltip="Upwards Arrow" desc="Insert Upwards 

Arrow" id="2101"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&uarr;</span>");
]]></MACRO> 

<MACRO name="Insert Downwards Arrow" key="" lang="JScript" tooltip="Downwards Arrow" desc="Insert 

Downwards Arrow" id="2103"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&darr;</span>");
]]></MACRO> 

<MACRO name="Insert Left-Right Arrow" key="" lang="JScript" tooltip="Left-Right Arrow" desc="Insert 

Left-Right Arrow" id="2104"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&harr;</span>");
]]></MACRO> 

<MACRO name="Insert Diagonal Northwest Arrow" key="" lang="JScript" tooltip="Diagonal Northwest Arrow" desc="Insert Diagonal Northwest Arrow" id="2106"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&nwarr;</span>");
]]></MACRO> 

<MACRO name="Insert Diagonal Northeast Arrow" key="" lang="JScript" tooltip="Diagonal Northeast Arrow" desc="Insert Diagonal Northeast Arrow" id="2107"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&nearr;</span>");
]]></MACRO> 

<MACRO name="Insert Diagonal Southeast Arrow" key="" lang="JScript" tooltip="Diagonal Southeast Arrow" desc="Insert Diagonal Southeast Arrow" id="2108"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&searr;</span>");
]]></MACRO> 

<MACRO name="Insert Diagonal Southwest Arrow" key="" lang="JScript" tooltip="Diagonal Southwest Arrow" desc="Insert Diagonal Southwest Arrow" id="2109"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&swarr;</span>");
]]></MACRO> 

<MACRO name="Insert Anticlockwise Open Circle Arrow" key="" lang="JScript" tooltip="Anticlockwise Open 

Circle Arrow" desc="Insert Anticlockwise Open Circle Arrow" id="2120"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&acwharp;</span>");
]]></MACRO> 

<MACRO name="Insert Clockwise Open Circle Arrow" key="" lang="JScript" tooltip="Clockwise Open Circle 

Arrow" desc="Insert Clockwise Open Circle Arrow" id="2121"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&cwharp;</span>");
]]></MACRO> 

<MACRO name="Insert Leftwards Harpoon, Barb Up" key="" lang="JScript" tooltip=" Leftwards Harpoon, Barb 

Up" desc="Insert Leftwards Harpoon, Barb Up" id="2122"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&luharp;</span>");
]]></MACRO> 

<MACRO name="Insert Leftwards Harpoon, Barb Down" key="" lang="JScript" tooltip="Leftwards Harpoon, 

Barb Down" desc="Insert Leftwards Harpoon, Barb Down" id="2123"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ldharp;</span>");
]]></MACRO> 

<MACRO name="Insert Rightwards Harpoon, Barb Up" key="" lang="JScript" tooltip="Rightwards Harpoon, 

Barb Up" desc="Insert Rightwards Harpoon, Barb Up" id="2126"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ruharp;</span>");
]]></MACRO> 

<MACRO name="Insert Rightwards Harpoon, Barb Down" key="" lang="JScript" tooltip="Rightwards Harpoon, 

Barb Down" desc="Insert Rightwards Harpoon, Barb Down" id="2127"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&rdharp;</span>");
]]></MACRO> 

<MACRO name="Insert Upwards Harpoon, Barb Right" key="" lang="JScript" tooltip="Upwards Harpoon, Barb 

Right" desc="Insert Upwards Harpoon, Barb Right" id="2124"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&urharp;</span>");
]]></MACRO> 

<MACRO name="Insert Upwards Harpoon, Barb Left" key="" lang="JScript" tooltip="Upwards Harpoon, Barb 

Left" desc="Insert Upwards Harpoon, Barb Left" id="2125"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ulharp;</span>");
]]></MACRO> 

<MACRO name="Insert Downwards Harpoon, Barb Right" key="" lang="JScript" tooltip="Downwards Harpoon, 

Barb Right" desc="Insert Downwards Harpoon, Barb Right" id="2128"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&drharp;</span>");
]]></MACRO> 

<MACRO name="Insert Downwards Harpoon, Barb Left" key="" lang="JScript" tooltip="Downwards Harpoon, 

Barb Left" desc="Insert Downwards Harpoon, Barb Leftt" id="2129"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&dlharp;</span>");
]]></MACRO> 

<MACRO name="Insert Right Arrow Over Left Arrow" key="" lang="JScript" tooltip="Right Arrow Over Left 

Arrow" desc="Right Arrow Over Left Arrow" id="2110"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&rolarr;</span>");
]]></MACRO> 

<MACRO name="Insert Up Arrow next to Down Arrow" key="" lang="JScript" tooltip="Up Arrow next to Down 

Arrow" desc="Insert Up Arrow next to Down Arrow" id="2111"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ubdarr;</span>");
]]></MACRO> 

<MACRO name="Insert Left Arrow Over Right Arrow" key="" lang="JScript" tooltip="Left Arrow Over Right 

Arrow" desc="Insert Left Arrow Over Right Arrow" id="2112"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&lorarr;</span>");
]]></MACRO> 

<MACRO name="Insert Left  Over Right Harpoons" key="" lang="JScript" tooltip="Left  Over Right Harpoons" desc="Insert Left  Over Right Harpoons" id="2113"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&lorharp;</span>");
]]></MACRO> 

<MACRO name="Insert Right Over Left Harpoons" key="" lang="JScript" tooltip="Right Over Left Harpoons" desc="Insert Right Over Left Harpoons" id="2114"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&rolharp;</span>");
]]></MACRO> 

<MACRO name="Insert Up-Down Arrow" key="" lang="JScript" tooltip="Up-Down Arrow" desc="Insert Up-Down 

Arrow" id="2105"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&varr;</span>");
]]></MACRO> 

<MACRO name="Insert Leftwards Double Arrow" key="" lang="JScript" tooltip="Leftwards Double Arrow" desc="Insert Leftwards Double Arrow" id="2115"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&lArr;</span>");
]]></MACRO> 

<MACRO name="Insert Upwards Double Arrow" key="" lang="JScript" tooltip="Upwards Double Arrow" desc="Insert Upwards Double Arrow" id="2116"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&uArr;</span>");
]]></MACRO> 

<MACRO name="Insert Rightwards Double Arrow" key="" lang="JScript" tooltip="Rightwards Double Arrow" desc="Insert Rightwards Double Arrow" id="2117"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&rArr;</span>");
]]></MACRO> 

<MACRO name="Insert Downwards Double Arrow" key="" lang="JScript" tooltip="Downwards Double Arrow" desc="Insert Downwards Double Arrow" id="2118"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&dArr;</span>");
]]></MACRO> 

<MACRO name="Insert Left-Right Double Arrow" key="" lang="JScript" tooltip="Left-Right Double Arrow" desc="Insert Left-Right Double Arrow" id="2119"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&hArr;</span>");
]]></MACRO> 

<MACRO name="Insert Liter" key="" lang="JScript" tooltip="Liter" desc="Insert Liter" id="2229"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&liter;</span>");
]]></MACRO> 

<MACRO name="Insert Not Equal" key="" lang="JScript" tooltip="Not Equal" desc="Insert Not Equal" id="2228"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ne;</span>");
]]></MACRO> 

<MACRO name="Insert Infinity" key="" lang="JScript" tooltip="Infinity" desc="Insert Infinity" id="2225"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&infin;</span>");
]]></MACRO> 

<MACRO name="Insert Degree" key="" lang="JScript" tooltip="Degree" desc="Insert Degree" id="2224"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&deg;</span>");
]]></MACRO> 

<MACRO name="Insert Almost Equal" key="" lang="JScript" tooltip="Almost Equal, Asymptotic To" desc="Insert Almost Equal" id="2227"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&asymp;</span>");
]]></MACRO> 

<MACRO name="Insert Approximately Equal" key="" lang="JScript" tooltip="Approximately Equal" desc="Insert Approximately Equal" id="2226"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&cong;</span>");
]]></MACRO> 

<MACRO name="Insert Nabla" key="" lang="JScript" tooltip="Nabla" desc="Insert Nabla" id="2210"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&nabla;</span>");
]]></MACRO> 

<MACRO name="Insert Therefore" key="" lang="JScript" tooltip="Therefore" desc="Insert Therefore" id="2212"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&there4;</span>");
]]></MACRO> 

<MACRO name="Insert Because" key="" lang="JScript" tooltip="Because" desc="Insert Because" id="2213"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&because;</span>");
]]></MACRO> 

<MACRO name="Insert Less Than or Equal To" key="" lang="JScript" tooltip="Less Than or Equal To" desc="Insert Less Than or Equal To" id="2214"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&le;</span>");
]]></MACRO> 

<MACRO name="Insert Greater Than or Equal To" key="" lang="JScript" tooltip="Greater Than or Equal To" desc="Insert Greater Than or Equal To" id="2215"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&ge;</span>");
]]></MACRO> 

<MACRO name="Insert Female Symbol" key="" lang="JScript" tooltip="Female Symbol" desc="Insert Female 

Symbol" id="2216"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&female;</span>");
]]></MACRO> 

<MACRO name="Insert Male Symbol" key="" lang="JScript" tooltip="Male Symbol" desc="Insert Male Symbol" id="2217"><![CDATA[
Selection.PasteString ("<span class=\"unicode\">&male;</span>");
]]></MACRO> 

<MACRO name="cdata" key="" lang="JScript" tooltip="cdata" desc="cdata" id=""><![CDATA[
Selection.PasteString ("&lt;![CDATA[ ]]&gt;");
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
]]></MACRO> 





