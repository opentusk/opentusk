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



<MACRO name="Insert Para" key="" lang="JScript" id="1217" tooltip="Insert Paragraph" desc="Insert a paragraph element."><![CDATA[



function doInsertPara() {

// If insertion pt, insert para template

// If selection, surround selection with para tags.

  var rng = ActiveDocument.Range;

  if (rng.IsInsertionPoint) {

    if (rng.CanInsert("para")) {

      rng.InsertWithTemplate("para");

      rng.SelectContainerContents();

      rng.Select();

    }

    else if (rng.ContainerName=="para") {

      rng.TypingSplit();

    }

    else {

      Application.Alert("Cannot insert paragraph element here.");

    }

  }

  else {

    if (rng.CanSurround("para")) {

      rng.Surround ("para");

    }

    else if (rng.ContainerName=="para") {

      rng.SplitContainer();

      rng.MoveRight(0);

      rng.TypingSplit();

    }

    else {

      Application.Alert("Cannot change selection to paragraph element.");

    }

  }

  rng = null;

}



if (CanRunMacros()) {

  doInsertPara();

}

 ]]></MACRO> 



<MACRO name="Insert block-quote" key="" lang="JScript" id="1518" tooltip="Insert block quote" desc="Insert a block quote element."><![CDATA[



function doInsertBlockquote() {

// If insertion pt, insert block-quote template

// If selection, surround selection with block-quote tags.

  var rng = ActiveDocument.Range;

  if (rng.IsInsertionPoint) {

  	// If we're in a <para>, move to after it, and then put in the quote

  	if (rng.IsParentElement("para")) {

  		rng.TypingSplit();

	    rng.SelectBeforeContainer();

	    if (rng.CanInsert("block-quote")) {

	    	rng.InsertWithTemplate("block-quote");

	    	rng.SelectContainerContents();

	    	rng.Select();

	    	if (! rng.ContainerNode.nextSibling.hasChildNodes()) {

	    		rng.SelectNodeContents(rng.ContainerNode.nextSibling);

	    		rng.SelectElement();

	    		rng.Select();

	    		rng.Delete();

	    		rng.MoveLeft();

	    	}

	    }

	    else {

	    	Application.Alert("Cannot insert block quote element here.");

	    }

  	}

  	// If we're NOT in a <para>, but we can insert a quote, then do it

	else if (rng.CanInsert("block-quote")) {

    	rng.InsertWithTemplate("block-quote");

    	rng.SelectContainerContents();

    	rng.Select();

   	}

   	// Otherwise, fail with an alert

    else {

      Application.Alert("Cannot insert block quote element here.");

    }

  }

  else {

  	// If the selection is in the middle of a paragraph, convert that

  	// paragraph to three elements: a <para> for the stuff BEFORE the selection,

  	// a <block-quote> for the selection, and a <para> for the stuff AFTER

  	// the selection.  We won't make empty <para>'s, obviously.

  }

  rng = null;

}



if (CanRunMacros()) {

  doInsertBlockquote();

}

 

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



<MACRO name="Toggle Foreign" key="" lang="JScript" id="1530" tooltip="Insert or Remove Foreign" desc="Insert, 



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



<MACRO name="Toggle Species" key="" lang="JScript" id="1531" tooltip="Insert or Remove Species" desc="Insert, 



Surround, or Remove Species"><![CDATA[



function doToggleSpecies() {

// If species already present, remove tags.

// If not:  If insertion pt, insert species template

//          If selection, surround selection with species tags.

  var rng = ActiveDocument.Range;

  if (rng.IsParentElement("species")) {

    if (rng.ContainerName != "species") {

      rng.SelectElement();

    }

    rng.RemoveContainerTags();

  }

  else {

    if (rng.IsInsertionPoint) {

      if (rng.CanInsert("species")) {

        rng.InsertWithTemplate("species");

        rng.SelectContainerContents();

        rng.Select();

      }

      else {

        Application.Alert("Cannot insert species element here.");

      }

    }

    else {

      if (rng.CanSurround("species")) {

        rng.Surround ("species");

      }

      else {

        Application.Alert("Cannot change Selection to species element.");

      }

    }

  }

  rng = null;

}



if (CanRunMacros()) {

  doToggleSpecies();

}

]]> </MACRO> 



<MACRO name="Toggle Media" key="" lang="JScript" id="1532" tooltip="Insert or Remove Media" desc="Insert, 



Surround, or Remove Media"><![CDATA[



function doToggleMedia() {

// If media already present, remove tags.

// If not:  If insertion pt, insert media template

//          If selection, surround selection with media tags.

  var rng = ActiveDocument.Range;

  if (rng.IsParentElement("media")) {

    if (rng.ContainerName != "media") {

      rng.SelectElement();

    }

    rng.RemoveContainerTags();

  }

  else {

    if (rng.IsInsertionPoint) {

      if (rng.CanInsert("media")) {

        rng.InsertWithTemplate("media");

        rng.SelectContainerContents();

        rng.Select();

      }

      else {

        Application.Alert("Cannot insert media element here.");

      }

    }

    else {

      if (rng.CanSurround("media")) {

        rng.Surround ("media");

      }

      else {

        Application.Alert("Cannot change Selection to media element.");

      }

    }

  }

  rng = null;

}



if (CanRunMacros()) {

  doToggleMedia();

}

]]> </MACRO> 



<MACRO name="Toggle Warning" key="" lang="JScript" id="1533" tooltip="Insert or Remove Warning" desc="Insert, 



Surround, or Remove Warning"><![CDATA[



function doToggleWarning() {

// If warning already present, remove tags.

// If not:  If insertion pt, insert warning template

//          If selection, surround selection with warning tags.

  var rng = ActiveDocument.Range;

  if (rng.IsParentElement("warning")) {

    if (rng.ContainerName != "warning") {

      rng.SelectElement();

    }

    rng.RemoveContainerTags();

  }

  else {

    if (rng.IsInsertionPoint) {

      if (rng.CanInsert("warning")) {

        rng.InsertWithTemplate("warning");

        rng.SelectContainerContents();

        rng.Select();

      }

      else {

        Application.Alert("Cannot insert warning element here.");

      }

    }

    else {

      if (rng.CanSurround("warning")) {

        rng.Surround ("warning");

      }

      else {

        Application.Alert("Cannot change Selection to warning element.");

      }

    }

  }

  rng = null;

}



if (CanRunMacros()) {

  doToggleWarning();

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



<MACRO name="Toggle Topic Sentence" key="" lang="JScript" id="1525" tooltip="Insert or Remove Topic 



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
    doObjectiveChooser();
  }
  rng = null;
}

function doObjectiveChooser() {
  var rng = ActiveDocument.Range;
  var strBody;
  var intID;
  var blnPrompt = 0;
  try {
  	var token = Application.CustomProperties.item("logonToken").value;
	if (token.Length < 1) {
		Application.Alert("Please log in to the HSDB.");
		return;
	}
  } catch (e) {
  	Application.Alert("Please log in to the HSDB.","Objective Chooser");
  	return;
  }
  if (!rng.IsInsertionPoint) {
  	var response = 7; // Default is no
    	var dlgConfig = 35;
    	var dlgMsg = "Make objective with selected text?";
  	response = Application.MessageBox(dlgMsg,dlgConfig);
      	if (response==6) {
      		intID = "";
      		strBody = Application.Selection.Text;
    	}
    	else if (response==7) {
    		blnPrompt = 1;
    	}
  }
  else {
  	blnPrompt = 1;
  }
  if (blnPrompt) {
  	if (rng.CanInsert("objective-item")) {
  		var Form = FormFuncs.CreateFormDlg("Forms\\HSDB\\dialogs\\ObjectiveChooser.hhf");
  		Form.DoModal();
  		strBody = Form.XMLstrBody.Value;
  		intID = Form.XMLstrID.Value;
  		Form = null;
      	}
      	else {
      		Application.Alert("Cannot insert objective element here.");
      		return;
    	}
  	
  }
  if (!intID && strBody) {
  	//if there is no ID at this point we need to make_objective
	try {
		var xmlhttp = new ActiveXObject ("MSXML2.XMLHTTP");
	} catch (e) {
		     Application.Alert(e.description, "Objective Chooser");
		     return;
	}

        //create a new
        var strHSDB = Application.CustomProperties.item("SecureHSDB").value; 
   	var header = strHSDB + "objective_make?token=" + Application.CustomProperties.item("logonToken").value;
   	header = header + "&password=" + Application.CustomProperties.item("logonPassword").value;
   	header = header + "&body=" + strBody; 
	xmlhttp.open("POST",header,"false");
	xmlhttp.send("");

    	try {
		var response = new ActiveXObject("MSXML2.DOMDOCUMENT");
	}
	catch (e) {
		Application.Alert(e.description, "Objective Chooser");
		return;
	}

	response.loadXML(xmlhttp.responseText);
    	var nodStatus = response.documentElement.selectSingleNode("STATUS");
    	if (!(nodStatus && nodStatus.text == "00" )) {
        	TuftsErrHandle(nodStatus.text);       
          	response = null; 
          	xmlhttp = null;
          	intID = "";
          	strBody = "";        
    	} else {
          	// Retrieved the XML successfully  
          	UpdateToken(response.documentElement.selectSingleNode("TOKEN").text);
		intID = response.selectSingleNode("//ID").text;
	}	
           
    }

  if (intID && strBody) {
  	//paste in the new XMLstructure
  	rng.Cut();
  	rng.InsertElement("objective-item");
  	rng.ContainerAttribute("objective-id") = intID;
  	rng.PasteString(strBody);
  }
  Form.XMLstrBody.Value = "";
  Form.XMLstrID.Value = "";
  intID = "";
  strBody = "";
  
}

if (CanRunMacros()) {
  doToggleObjectiveItem();
}
 ]]></MACRO> 


<MACRO name="Toggle Summary" key="" lang="JScript" id="1521" tooltip="Insert or Remove Summary" desc="Insert, Surround, or Remove Summary"><![CDATA[

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



<MACRO name="Toggle Nugget" key="" lang="JScript" id="1520" tooltip="Insert or Remove Nugget" desc="Insert, 



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



<MACRO name="Toggle Keyword" key="" lang="JScript" id="1523" tooltip="Insert or Remove Keyword" desc="Insert, Surround, or Remove Keyword"><![CDATA[

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

<span class=\"unicodetimes\"></span>

<MACRO name="Insert Lower Alpha" key="" lang="JScript" tooltip="Lower Alpha" desc="Insert Lower Alpha" id="2000"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&alpha;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Beta" key="" lang="JScript" tooltip="Lower Beta" desc="Insert Lower Beta" id="2001"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&beta;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Gamma" key="" lang="JScript" tooltip="Lower Gamma" desc="Insert Lower 



Gamma" id="2002"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&gamma;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Delta" key="" lang="JScript" tooltip="Lower Delta" desc="Insert Lower Delta" id="2003"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&delta;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Epsilon" key="" lang="JScript" tooltip="Lower Epsilon" desc="Insert Lower 



Epsilon" id="2004"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&epsilon;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Zeta" key="" lang="JScript" tooltip="Lower Zeta" desc="Insert Lower Zeta" id="2005"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&zeta;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Eta" key="" lang="JScript" tooltip="Lower Eta" desc="Insert Lower Eta" id="2006"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&eta;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Theta" key="" lang="JScript" tooltip="Lower Theta" desc="Insert Lower Theta" id="2007"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&theta;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Iota" key="" lang="JScript" tooltip="Lower Iota" desc="Insert Lower Iota" id="2008"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&iota;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Kappa" key="" lang="JScript" tooltip="Lower Kappa" desc="Insert Lower Kappa" id="2009"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&kappa;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Lambda" key="" lang="JScript" tooltip="Lower Lambda" desc="Insert Lower 

Lambda" id="2010"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&lambda;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Mu" key="" lang="JScript" tooltip="Lower Mu" desc="Insert Lower Mu" id="2011"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&mu;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Nu" key="" lang="JScript" tooltip="Lower Nu" desc="Insert Lower Nu" id="2012"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&nu;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Xi" key="" lang="JScript" tooltip="Lower Xi" desc="Insert Lower Xi" id="2013"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&xi;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Omicron" key="" lang="JScript" tooltip="Lower Omicron" desc="Insert Lower 



Omicron" id="2014"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&omicron;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Pi" key="" lang="JScript" tooltip="Lower Pi" desc="Insert Lower Pi" id="2015"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&pi;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Rho" key="" lang="JScript" tooltip="Lower Rho" desc="Insert Lower Rho" id="2016"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&rho;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Sigma 1" key="" lang="JScript" tooltip="Lower Sigma (Final)" desc="Insert 

Lower Sigma 1" id="2017"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&sigmaf;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Sigma 2" key="" lang="JScript" tooltip="Lower Sigma (2)" desc="Insert Lower 

Sigma 2" id="2018"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&sigma;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Tau" key="" lang="JScript" tooltip="Lower Tau" desc="Insert Lower Tau" id="2019"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&tau;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Upsilon" key="" lang="JScript" tooltip="Lower Upsilon" desc="Insert Lower 

Upsilon" id="2020"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&upsilon;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Phi" key="" lang="JScript" tooltip="Lower Phi" desc="Insert Lower Phi" id="2021"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&phi;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Chi" key="" lang="JScript" tooltip="Lower Chi" desc="Insert Lower Chi" id="2022"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&chi;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Psi" key="" lang="JScript" tooltip="Lower Psi" desc="Insert Lower Psi" id="2023"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&psi;</span>");

]]></MACRO> 



<MACRO name="Insert Lower Omega" key="" lang="JScript" tooltip="Lower Omega" desc="Insert Lower 

Omega" id="2024"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&omega;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Gamma" key="" lang="JScript" tooltip="Upper Gamma" desc="Insert Upper 

Gamma" id="2030"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Gamma;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Delta" key="" lang="JScript" tooltip="Upper Delta" desc="Insert Upper Delta" id="2031"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Delta;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Theta" key="" lang="JScript" tooltip="Upper Theta" desc="Insert Upper Theta" id="2032"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Theta;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Lambda" key="" lang="JScript" tooltip="Upper Lambda" desc="Insert Upper 

Lambda" id="2033"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Lambda;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Xi" key="" lang="JScript" tooltip="Upper Xi" desc="Insert Upper Xi" id="2034"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Xi;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Pi" key="" lang="JScript" tooltip="Upper Pi" desc="Insert Upper Pi" id="2035"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Pi;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Sigma" key="" lang="JScript" tooltip="Upper Sigma" desc="Insert Upper Sigma" id="2036"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Sigma;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Phi" key="" lang="JScript" tooltip="Upper Phi" desc="Insert Upper Phi" id="2037"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Phi;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Psi" key="" lang="JScript" tooltip="Upper Psi" desc="Insert Upper Psi" id="2038"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Psi;</span>");

]]></MACRO> 



<MACRO name="Insert Upper Omega" key="" lang="JScript" tooltip="Upper Omega" desc="Insert Upper 

Omega" id="2039"><![CDATA[

Selection.PasteString ("<span class=\"unicodetimes\">&Omega;</span>");

]]></MACRO> 



<MACRO name="Insert One-third Fraction" key="" lang="JScript" tooltip="One-third Fraction" desc="Insert 

One-third Fraction" id="2218"><![CDATA[

Selection.PasteString ("<span class=\"unicode\">&frac13;</span>");

]]></MACRO> 



<MACRO name="Insert Two-thirds Fraction" key="" lang="JScript" tooltip="Two-thirds Fraction" desc="Insert 

Two-thirds Fraction" id="2219"><![CDATA[

Selection.PasteString ("<span class=\"unicode\">&frac23;</span>");

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



<MACRO name="Insert Anticlockwise Open Circle Arrow" key="" lang="JScript" tooltip="Anticlockwise Open Circle Arrow" desc="Insert Anticlockwise Open Circle Arrow" id="2120"><![CDATA[

Selection.PasteString ("<span class=\"unicode\">&acwharp;</span>");

]]></MACRO> 



<MACRO name="Insert Clockwise Open Circle Arrow" key="" lang="JScript" tooltip="Clockwise Open Circle 

Arrow" desc="Insert Clockwise Open Circle Arrow" id="2121"><![CDATA[

Selection.PasteString ("<span class=\"unicode\">&cwharp;</span>");

]]></MACRO> 



<MACRO name="Insert Leftwards Harpoon, Barb Up" key="" lang="JScript" tooltip=" Leftwards Harpoon, Barb Up" desc="Insert Leftwards Harpoon, Barb Up" id="2122"><![CDATA[

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



<!--SoftQuad Customization Macros-->



<MACRO name="Release" key="Ctrl+Alt+W" lang="JScript" id="1144"><![CDATA[

// Document Release

// Used to release or cancel check-out of the current document





function nulReleaseCurrentDocument() {



if ( ActiveDocument.documentElement.getAttribute("content-id") == "" ) {

    var strErr = "This document does not have a Content Id.\n";

    strErr += "It has not been checked out from the HSDB Database.";

    Application.Alert( strErr); 

    return; 

} 

try { 

        var strToken = Application.CustomProperties.item("logonToken").value;

} catch (e) {

         Application.Alert("Please logon to the database.","Document Release Cancelled");

         return;

}   

try {  var xmlhttp = new ActiveXObject ("MSXML2.XMLHTTP");

} catch (e) { 

	Application.Alert( "Please verify that you have the Microsoft MSXML Parser Installed");

        return;

} 

	

  

// Get the HTTP URL TO HSDB

var strHSDB = Application.CustomProperties.Item("HSDB").Value

var strContentID = ActiveDocument.documentElement.getAttribute("content-id");

xmlhttp.open("POST", strHSDB + "release?token=" + strToken +"&content_id=" + strContentID, false);

xmlhttp.send("") //no data to send

    

var xmlDoc = new ActiveXObject("Msxml2.DOMDocument");

xmlDoc.async = false;

if (!xmlDoc.loadXML(xmlhttp.responseText)){

		    Application.Alert("Invalid response from the server.\nCancel Checkout/Release was not successful.\n" + xmlhttp.responseText);

		    return; 

	}       

	var nodStatus = xmlDoc.documentElement.selectSingleNode("STATUS");

	if (!(nodStatus && nodStatus.text == "00" )) {

	      TuftsErrHandle( nodStatus.text );

          Application.Alert("Cancel Checkout/Release was not successful");       

          xmlDoc = null; 

	      xmlhttp = null; 

          return;          

     } else {

	  // Retrieved the XML successfully

	  UpdateToken(xmlDoc.documentElement.selectSingleNode("TOKEN").text);

	  Application.Alert("The current document was Released");

      var objDoc = ActiveDocument; 

	  objDoc.Close(2);

     }

}

nulReleaseCurrentDocument(); 

]]></MACRO> 



<MACRO name="On_Update_UI" lang="JScript" hide="true" id="144"><![CDATA[

// #######################################################################

//  Starting  Code. -

// ####################################################################### 

// Disable most macros if in Plain Text view or if the document is not XML

// ######################################################################

if (!ActiveDocument.IsXML ||

    (ActiveDocument.ViewType != sqViewNormal && ActiveDocument.ViewType != sqViewTagsOn)) {

   Application.DisableMacro ("Insert New Section");

   Application.DisableMacro ("Insert Section or Subsection"); 

   Application.DisableMacro ("Promote Section");

   Application.DisableMacro ("Demote Section");

   Application.DisableMacro ("Convert to Section");

   Application.DisableMacro ("Convert to Subsection");

   Application.DisableMacro ("Join Paragraphs");

}



// Disable some macros if the view is Normal or Tags On

if (ActiveDocument.ViewType == sqViewNormal || ActiveDocument.ViewType == sqViewTagsOn) {

// Structural elements

   if (Selection.IsParentElement("header")) {

      Application.DisableMacro("Insert New Section");

      Application.DisableMacro ("Insert Section or Subsection"); 

      Application.DisableMacro ("Promote Section");

      Application.DisableMacro ("Demote Section");

      Application.DisableMacro ("Convert to Section");

      Application.DisableMacro ("Convert to Subsection");

      Application.DisableMacro ("Join Paragraphs");

   }

   if (!Selection.IsParentElement("section-level-1")) {

      Application.DisableMacro("Insert New Section");

   }

   // Word Import Macros

   if (!Selection.IsParentElement("para")) {

      Application.DisableMacro("Convert to Subsection");

      Application.DisableMacro("Convert to Section");

   } else {

      if (Selection.IsParentElement("section-level-5")) {

         Application.DisableMacro("Convert to Subsection");

      }

      if ((!Selection.IsParentElement("section-level-1")) &&

          (!Selection.IsParentElement("section-level-2")) &&

          (!Selection.IsParentElement("section-level-3")) &&

          (!Selection.IsParentElement("section-level-4")) &&

          (!Selection.IsParentElement("section-level-5"))) {

         Application.DisableMacro("Convert to Subsection");

         Application.DisableMacro("Convert to Section");

      }

   }

   if (!Selection.IsParentElement("section-title")) {

      Application.DisableMacro("Promote Section");

      Application.DisableMacro("Demote Section");

   } else {  

      if (!Selection.IsParentElement("section-level-2") ){

         Application.DisableMacro("Promote Section");

      }

      if (!Selection.IsParentElement("section-level-1") || Selection.IsParentElement("section-level-5")){

         Application.DisableMacro("Demote Section");

      }

   }

   if (Selection.IsInsertionPoint) {

      Application.DisableMacro("Join Paragraphs");

   }

}

//  End  Code.                                             

// #######################################################################

]]></MACRO> 







<MACRO name="On_Document_Open_Complete" lang="JScript" hide="true"><![CDATA[



// GLOBAL VARIABLE DECLARATIONS	



var DEBUG = false; 

var strAppTitle= "Tufts HSDB: XMetaL 2.1"; 



// LOAD TOP-LEVEL FUNCTIONS

Application.Run("LoadLocalImageLibrary"); 

Application.Run("LoadHTMLFunctions"); 

Application.Run("LoadLoginFunctions");

Application.Run("LoadJournalSyncFunctions");

Application.Run("LoadSyncFunctions");

Application.Run("LoadXMHelperFunctions");



// ######################################################################

//  Starting  Code. -

// #######################################################################

ActiveDocument.AcceptDropFormat("HTML Format", "HTML");

ActiveDocument.AcceptDropFormat(1, "TEXT");

Application.run ("Init_JScript_Macros");



//*************************************************************************

// StartNewSubsection (sectname)

//

// DESCRIPTION:

//    - Create a new "section" from the given section name "sectname".

//      this function can only be called if it is known that <para> is a

//      parent element.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - sectname: The section level name in string.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************



function StartNewSubsection(sectName) {

   var paraName = "para";

   var titleName = "section-title";

  

   var rng = ActiveDocument.Range;

   var strBody = "";

   var strTitle = "";

   // Use the current Para for the Title of the new section

   var node = Selection.ContainerNode;

   while (node.nodeName != paraName) {

      node = node.parentNode;

   }

   // Look for Any DOM Element before and after current Selection and set a the

   // fElementBeforePara and fElementAfterPara accordingly. This way when a

   // Section or Subsection is added, we'll know weather or not to put in

   // a <para> to satisfy the new Section or Subsection's content model.

   var fElementBeforePara = false;

   var tmpnode = node.parentNode;

   tmpnode = tmpnode.firstChild;

   // Move Selection pointer to after <section-title>.

   while (tmpnode.nodeName != "section-title") {

      tmpnode = tmpnode.nextSibling;

   }

   tmpnode = tmpnode.nextSibling;

   // Look for any DOM Element after <section-title>, if there is, we don't need to

   // preserved current para for the existing section to satisfy its content model.

   while (tmpnode != node) {

      if (tmpnode.nodeType == 1) {   // DOM Element.

         fElementBeforePara = true;

      }

      tmpnode = tmpnode.nextSibling;

   }

   // Search for Any DOM Element after current para, if there is, we don't need to create

   // a new <para> for the new section. Otherwise, create a new <para>.

   var fElementAfterPara = false;

   tmpnode = tmpnode.nextSibling;

   while (tmpnode) {

      if (tmpnode.nodeType == 1) {   // DOM Element.

         fElementAfterPara = true;

      }

      tmpnode = tmpnode.nextSibling;

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

   } else { // no subsections, so move to end of container

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

   if (strBody != "") {

      rng.TypeText(strBody);

   }

   // If there're elements after the Selection (<para> content), then just

   // copy them to below the new Subsection. Otherwise, create a new <para>

   // tag with current Selection's content to satisfy the content model.

   if (! fElementAfterPara) {

     rng.InsertElement (paraName);

     rng.TypeText("<?xm-replace_text {Paragraph}?>");

   }

   rng.MoveToElement(titleName, false);

   rng.Select();

   rng = null;

   rng3 = null;

   rng2 = null;

   tmpnode = null;

}



// Image Chooser.

Application.Run("Display Online Image Chooser");

// ######################################################################

//  End  Code.                                             

// #######################################################################

]]></MACRO> 





<MACRO name="On_Document_Close" hide="true" lang="JScript"><![CDATA[

// ######################################################################

//  Starting  Code. -

// #######################################################################

  if ( Documents.Count == 1 ) {

     // Close the Online Image Chooser if this is the last document

     Application.Run("Remove Online Image Chooser"); 

  }

// ######################################################################

//  End  Code.                                             

// #######################################################################

]]></MACRO> 



<MACRO name="Send Local Images To Tufts" lang="JScript" id="1112" hide="true"><![CDATA[

// DESCRIPTION

// This macros allows users to manually run a Batch Image Upload

//

// The "Run Batch Image Upload" macro is declared in the Startup Directory

// and is therefore a system-level hidden macro 



Application.Run("Run Batch Image Upload"); 



]]></MACRO> 



<!-- ######################################################################

-  Starting  Code. -

####################################################################### -->



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



<MACRO name="Insert New Section" key="Ctrl+Alt+N" lang="JScript" id="1744" tooltip="Insert New Section" desc="Insert the same level section where allowed after current point"><![CDATA[



//*************************************************************************

// doInsertNewSection ()

//

// DESCRIPTION:

//    - Inserts a new section at the same level as current selection's

//      level. Current selection must be within a "section-level-#" where

//      # is a decimal number.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doInsertNewSection () {

   var rng = ActiveDocument.Range;

  

   rng.Collapse();

   if (rng.IsParentElement("section-level-5")) {

      // Just because we're in a section-level-5 doesn't mean it's our

      // container. Move up the hierarchy until the section-level-5 is

      // our parent

      while (rng.ContainerNode.nodeName != "section-level-5") {

        rng.SelectElement();

      } 



      // Move the selection to after the current section-level-5

      rng.SelectAfterNode(rng.ContainerNode);



      // Insert a new section-level-5

      rng.InsertWithTemplate("section-level-5");

   } else {

      if (rng.IsParentElement("section-level-4")) {

         // Just because we're in a section-level-4 doesn't mean it's our

         // container. Move up the hierarchy until the section-level-4 is

         // our parent

         while (rng.ContainerNode.nodeName != "section-level-4") {

           rng.SelectElement();

         } 

 

         // Move the selection to after the current section-level-4

         rng.SelectAfterNode(rng.ContainerNode);

 

         // Insert a new section-level-4

         rng.InsertWithTemplate("section-level-4");

      } else {

         if (rng.IsParentElement("section-level-3")) {

            while (rng.ContainerNode.nodeName != "section-level-3") {

              rng.SelectElement();

            } 

 

            rng.SelectAfterNode(rng.ContainerNode);

 

            rng.InsertWithTemplate("section-level-3");

         } else {

            if (rng.IsParentElement("section-level-2")) {

              while (rng.ContainerNode.nodeName != "section-level-2") {

                rng.SelectElement();

              } 

 

              rng.SelectAfterNode(rng.ContainerNode);

 

              rng.InsertWithTemplate("section-level-2");

            } else { 

               if (rng.IsParentElement("section-level-1")) {

                  while (rng.ContainerNode.nodeName != "section-level-1") {

                    rng.SelectElement();

                  } 

 

                  rng.SelectAfterNode(rng.ContainerNode);

 

                  rng.InsertWithTemplate("section-level-1");

               }  else {

                  if (rng.IsParentElement("header")) {

                     Application.Alert("You cannot insert sections inside a header.");

                  } else { 

                     Application.Alert("You are not currently inside a section.  Try inserting a subsection instead.");

                  }

               } 

            } 

         } 

      } 

   }

   rng.Select();

   rng = null;

}



//if CanRunMacrosVB { 

  doInsertNewSection();

//}



]]></MACRO> 



<MACRO name="Insert Section or Subsection" key="Ctrl+Alt+S" lang="JScript" id="1754" tooltip="Insert Section or Subsection" desc="Insert the next-lower level section where allowed after current point"><![CDATA[



//*************************************************************************

// doInsertSection ()

//

// DESCRIPTION:

//    - Inserts a Section if current selection is not within a Section

//      or Subsection. Or Inserts a Subsection if current selection is

//      within a Section or Subsection.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doInsertSection () {

   var Rng = ActiveDocument.Range;

   var UserRng = ActiveDocument.Range;

   var RngNode;

   Rng.Collapse();

   if (Rng.IsParentElement("section-level-5")) {

      if (! Rng.CanInsert("section-level-5")) {

         if (Rng.ContainerNode.nodeName != "section-level-5") {

            RngNode = Rng.ContainerNode;

            while (RngNode.parentNode.nodeName != "section-level-5") {

               RngNode = RngNode.parentNode;

            }

            Rng.SelectNodeContents (RngNode);

            Rng.SelectAfterContainer();

         }

         if (! Rng.CanInsert("section-level-5")) {

            // Find the Insert location starting from firstChild.

            RngNode = Rng.ContainerNode.firstChild;

            while (! Rng.CanInsert("section-level-5")) {

               Rng.SelectAfterNode(RngNode);

               RngNode = RngNode.nextSibling;

            }

         }

      }

      Rng.InsertWithTemplate("section-level-5");

      Rng.Select();

   } else { 

      if (Rng.IsParentElement("section-level-4")) {

         if (! Rng.CanInsert("section-level-5")) {

            if (Rng.ContainerNode.nodeName != "section-level-4") {

               RngNode = Rng.ContainerNode;

               while (RngNode.parentNode.nodeName != "section-level-4") {

                  RngNode = RngNode.parentNode;

               }

               Rng.SelectNodeContents (RngNode);

               Rng.SelectAfterContainer();

            }

            if (! Rng.CanInsert("section-level-5")) {

               // Find the Insert location starting from firstChild.

               RngNode = Rng.ContainerNode.firstChild;

               while (! Rng.CanInsert("section-level-5")) {

                  Rng.SelectAfterNode(RngNode);

                  RngNode = RngNode.nextSibling;

               }

            }

         }

         Rng.InsertWithTemplate("section-level-5");

         Rng.Select();

      } else {

         if (Rng.IsParentElement("section-level-3")) {

            if (! Rng.CanInsert("section-level-4")) {

               if (Rng.ContainerNode.nodeName != "section-level-3") {

                  RngNode = Rng.ContainerNode;

                  while (RngNode.parentNode.nodeName != "section-level-3") {

                     RngNode = RngNode.parentNode;

                  }

                  Rng.SelectNodeContents (RngNode);

                  Rng.SelectAfterContainer();

               }

               if (! Rng.CanInsert("section-level-4")) {

                  // Find the Insert location starting from firstChild.

                  RngNode = Rng.ContainerNode.firstChild;

                  while (! Rng.CanInsert("section-level-4")) {

                     Rng.SelectAfterNode(RngNode);

                     RngNode = RngNode.nextSibling;

                  }

               }

            }

            Rng.InsertWithTemplate("section-level-4");

            Rng.Select();

         } else {

            if (Rng.IsParentElement("section-level-2")) {

               if (! Rng.CanInsert("section-level-3")) {

                  if (Rng.ContainerNode.nodeName != "section-level-2") {

                     RngNode = Rng.ContainerNode;

                     while (RngNode.parentNode.nodeName != "section-level-2") {

                        RngNode = RngNode.parentNode;

                     }

                     Rng.SelectNodeContents (RngNode);

                     Rng.SelectAfterContainer();

                  }

                  if (! Rng.CanInsert("section-level-3")) {

                     // Find the Insert location starting from firstChild.

                     RngNode = Rng.ContainerNode.firstChild;

                     while (! Rng.CanInsert("section-level-3")) {

                        Rng.SelectAfterNode(RngNode);

                        RngNode = RngNode.nextSibling;

                     }

                  }

               }

               Rng.InsertWithTemplate("section-level-3");

               Rng.Select();

            } else {

               if (Rng.IsParentElement("section-level-1")) {

                  if (! Rng.CanInsert("section-level-2")) {

                     if (Rng.ContainerNode.nodeName != "section-level-1") {

                        RngNode = Rng.ContainerNode;

                        while (RngNode.parentNode.nodeName != "section-level-1") {

                           RngNode = RngNode.parentNode;

                        }

                        Rng.SelectNodeContents (RngNode);

                        Rng.SelectAfterContainer();

                     }

                     if (! Rng.CanInsert("section-level-2")) {

                        // Find the Insert location starting from firstChild.

                        RngNode = Rng.ContainerNode.firstChild;

                        while (! Rng.CanInsert("section-level-2")) {

                           Rng.SelectAfterNode(RngNode);

                           RngNode = RngNode.nextSibling;

                        }

                     }

                  }

                  Rng.InsertWithTemplate("section-level-2");

                  Rng.Select();

               } else {

                  if (Rng.IsParentElement("body")) {

                     if (Rng.ContainerNode.nodeName == "body") {

                        Rng.InsertWithTemplate("section-level-1");

                        Rng.Select();

                     } else {

                        RngNode = Rng.ContainerNode;

                        while (RngNode.parentNode.nodeName != "body") {

                           RngNode = RngNode.parentNode;

                        }

                        Rng.SelectNodeContents (RngNode);

                        Rng.SelectAfterContainer();

                        Rng.InsertWithTemplate("section-level-1");

                        Rng.Select();

                     }

                  } else {

                     Application.Alert("Cannot insert Section or subsection here.");

                     //UserRng.Select;

                  }

               } 

            } 

         } 

      } 

   } 

   Rng = null;

   UserRng = null;

   RngNode = null;

}



//if (CanRunMacros()) {

   doInsertSection();

//}

]]></MACRO> 



<MACRO name="Promote Section" key="Ctrl+Alt+P" lang="JScript" id="20111" tooltip="Promote Section" desc="Convert current section to next-higher level section"><![CDATA[

//*************************************************************************

// doPromoteSection ()

//

// DESCRIPTION:

//    - Convert current section into a section 1 smaller. ie.

//      section-level-2 to section-level-1.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doPromoteSection() {

   // Selection must be in a title.

   var containNode = Selection.ContainerNode;

   if (containNode && containNode.nodeName == "section-title") {

      // Not valid for Sect

      if (Selection.IsParentElement("section-level-2") || Selection.IsParentElement("section-level-3") || Selection.IsParentElement("section-level-4") || Selection.IsParentElement("section-level-5")) {

         var rng = ActiveDocument.Range;

         RngNode = rng.ContainerNode;

         // Move to the beginning of the current Section tag.

         while ((RngNode.nodeName != "section-level-2") && (RngNode.nodeName != "section-level-3") && (RngNode.nodeName != "section-level-4") && (RngNode.nodeName != "section-level-5")) {

            RngNode = RngNode.parentNode;

         }

         // Keep looking backward for an Element Node from the DOM tree.

         while (RngNode.previousSibling.nodeType != 1) {      // DOM Element.

            RngNode = RngNode.previousSibling;

         }

         // if found "section-title", don't promote this section. Otherwise, the section above

         // this will become invalid because there is no other elements following the

         // "section-title" element.

         if (RngNode.previousSibling.nodeName == "section-title") {

            Application.alert ("This section can not be promoted, the Section above this one is not a valid after promoting this Section. Please add one or more Elements after section-title of the Section above before trying again.");

            return;

         }

         var strTitle = "";

         var strBody = "";

         var strRest = "";

 

         // Copy the title of the section

         var node = rng.ContainerNode;

         rng.SelectNodeContents(node);

         strTitle = rng.Text;

    

         // Copy the rest of the section to a string

         rng.SelectAfterContainer();

         var rng2 = rng.Duplicate;

         node = rng.ContainerNode;

         rng.SelectAfterNode(node.lastChild);

         rng2.ExtendTo(rng);

         strBody = rng2.Text;



         // Delete the section

         rng.SelectElement();

         rng.Delete();



         if (! rng2.IsParentElement("section-level-4")) {

            // Fix the subsections of the section we are promoting

            strBody = strBody.replace(/section-level-2>/g, "section-level-1>");

            strBody = strBody.replace(/section-level-3>/g, "section-level-2>");

            strBody = strBody.replace(/section-level-4>/g, "section-level-3>");

            strBody = strBody.replace(/<section-level-5>/, "<section-level-4>");

            strBody = strBody.replace (/[\n]/g, "");

            strBody = strBody.replace(/(.+)<\/section-level-5>/, "$1</section-level-4>\n");

            // Fix the replaceable text

            strBody = strBody.replace(/xm-replace_text Section 2 Title/g, "xm-replace_text Section 1 Title");

            strBody = strBody.replace(/xm-replace_text Section 3 Title/g, "xm-replace_text Section 2 Title");

            strBody = strBody.replace(/xm-replace_text Section 4 Title/g, "xm-replace_text Section 3 Title");

            strBody = strBody.replace(/xm-replace_text Section 5 Title/, "xm-replace_text Section 4 Title");

         }

         strTitle = strTitle.replace(/xm-replace_text Section 2 Title/g, "xm-replace_text Section 1 Title");

         strTitle = strTitle.replace(/xm-replace_text Section 3 Title/g, "xm-replace_text Section 2 Title");

         strTitle = strTitle.replace(/xm-replace_text Section 4 Title/g, "xm-replace_text Section 3 Title");

         strTitle = strTitle.replace(/xm-replace_text Section 5 Title/, "xm-replace_text Section 4 Title");

      

         // Save the rest of the parent section

         rng = rng2.Duplicate;

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

         rng.InsertElement("section-title");

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

      } else {

         Application.Alert("This section is already a top level section");

      }

   } else {

      Application.Alert("Put your insertion cursor inside the title of the section you want to promote");

   }

}

if (CanRunMacros()) {

  doPromoteSection();

}

]]></MACRO> 



<MACRO name="Demote Section" key="Ctrl+Alt+D" lang="JScript" id="1755" tooltip="Demote Section" desc="Convert current section to next-lower level section"><![CDATA[

//*************************************************************************

// doDemoteSection ()

//

// DESCRIPTION:

//    - Convert current section into a section 1 bigger.  eg.

//      section-level-1 to section-level-2.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doDemoteSection() {

  // Selection must be in a title.

   var containNode = Selection.ContainerNode;

   if (containNode && containNode.nodeName == "section-title") { 

      // if Sect4 or contains Sect4, can't do it!

      var rng = ActiveDocument.Range;

      rng.SelectElement();

      var node = rng.ContainerNode;  // the section node

//      var elemlist = node.getElementsByTagName("section-level-5");

      // Ask explicitly just to rule out anything crazy

      var sectName = node.nodeName;

      if ((sectName == "section-level-1" || sectName == "section-level-2" || sectName == "section-level-3") || (sectName == "section-level-4")) {

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

            strBody = strBody.replace(/section-level-4>/g, "section-level-5>");

            strBody = strBody.replace(/section-level-3>/g, "section-level-4>");

            strBody = strBody.replace(/section-level-2>/g, "section-level-3>");

            strBody = strBody.replace(/section-level-1>/g, "section-level-2>");

           

            // Fix the replaceable text

            strBody = strBody.replace(/<\?xm-replace_text Section 4 Title\?>/g, "<\?xm-replace_text Section 5 Title\?>");

            strBody = strBody.replace(/<\?xm-replace_text Section 3 Title\?>/g, "<\?xm-replace_text Section 4 Title\?>");

            strBody = strBody.replace(/<\?xm-replace_text Section 2 Title\?>/g, "<\?xm-replace_text Section 3 Title\?>");

            strBody = strBody.replace(/<\?xm-replace_text Section 1 Title\?>/g, "<\?xm-replace_text Section 2 Title\?>");

 

            rngSave.MoveToElement(sectName, false);  // Find sibling before it

            rngSave.SelectContainerContents();

            rngSave.Collapse(sqCollapseEnd);         // inside the end of the sibling

            rng = rngSave.Duplicate;

            if (strBody != "") rngSave.TypeText(strBody);

            rng.MoveToElement("section-title");

            rng.Select();

         } else {

            Application.Alert("There has to be a section of the same level before this one");

         }

      } else {

         Application.Alert("This section is (or contains) a bottom level section");

      }

      rng = null;

   } else {

      Application.Alert("Put your insertion cursor inside the title of the section you want to demote");

   }

}

if (CanRunMacros()) {

  doDemoteSection();

}

]]></MACRO> 



<MACRO name="Convert to Subsection" key="Ctrl+Alt+B" lang="JScript" id="1753" tooltip="Convert to Subsection" desc="Change current Para into the Title of a subsection"><![CDATA[

//*************************************************************************

// doConvertToSubsection ()

//

// DESCRIPTION:

//    - Convert current paragraph and everything below it into a new section.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doConvertToSubsection() {

  if (Selection.IsParentElement("para")) {

    if (Selection.IsParentElement("section-level-5")) Application.Alert("No more levels of subsections available");

    else if (Selection.IsParentElement("section-level-4")) StartNewSubsection("section-level-5");

    else if (Selection.IsParentElement("section-level-3")) StartNewSubsection("section-level-4");

    else if (Selection.IsParentElement("section-level-2")) StartNewSubsection("section-level-3");

    else if (Selection.IsParentElement("section-level-1")) StartNewSubsection("section-level-2");

    else StartNewSubsection("section-level-1");

  }

  else

    Application.Alert("Place insertion point in the paragraph that will become the title of the subsection");

}



if (CanRunMacros()) {

  doConvertToSubsection();

}]]></MACRO> 



<MACRO name="Convert to Section" key="Ctrl+Alt+C" lang="JScript" id="1722" tooltip="Convert to Section" desc="Change current para into the Title of a new Section at same level as current Section"><![CDATA[

//*************************************************************************

// doConvertToSection ()

//

// DESCRIPTION:

//    - Convert current paragraph and everything below it into a new

//      section at the same level as the section currently in.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doConvertToSection() {

   if (Selection.IsParentElement("para")) {

      if (Selection.IsParentElement("section-level-1") || 

         Selection.IsParentElement("section-level-2") ||

         Selection.IsParentElement("section-level-3") ||

         Selection.IsParentElement("section-level-4") ||

         Selection.IsParentElement("section-level-5")) {

         var paraName = "para";

         var titleName = "section-title";

      

         var rng = ActiveDocument.Range;

         var strBody = "";

         var strTitle = "";

      

         // Use the current para for the Title of the new section

         var node = rng.ContainerNode;

         while (node.nodeName != paraName) {

            node = node.parentNode;

         }

         // Look for Any DOM Element before and after current Selection and set a the

         // fElementBeforePara and fElementAfterPara accordingly. This way when a

         // Section or Subsection is added, we'll know weather or not to put in

         // a <para> to satisfy the new Section or Subsection's content model.

         var fElementBeforePara = false;

         var tmpnode = node.parentNode;

         tmpnode = tmpnode.firstChild;

         // Move Selection pointer to after <section-title>.

         while (tmpnode.nodeName != "section-title") {

            tmpnode = tmpnode.nextSibling;

         }

         tmpnode = tmpnode.nextSibling;

         // Look for any DOM Element after <section-title>, if there is, we don't need to

         // preserved current para for the existing section to satisfy its content model.

         while (tmpnode != node) {

            if (tmpnode.nodeType == 1) {   // DOM Element.

               fElementBeforePara = true;

            }

            tmpnode = tmpnode.nextSibling;

         }

         // Search for Any DOM Element after current para, if there is, we don't need to create

         // a new <para> for the new section. Otherwise, create a new <para>.

         var fElementAfterPara = false;

         tmpnode = tmpnode.nextSibling;

         while (tmpnode) {

            if (tmpnode.nodeType == 1) {   // DOM Element.

               fElementAfterPara = true;

            }

            tmpnode = tmpnode.nextSibling;

         }   

      

         rng.SelectNodeContents(node);

         strTitle = rng.Text;

         rng.SelectElement();

         if (fElementBeforePara) {

            rng.Delete();

         } else {

            rng.Collapse(0);

         }

     

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

         if (strBody != "") {

            rng.TypeText(strBody);

         } 

         if (! fElementAfterPara) {

            rng.InsertElement(paraName);

            rng.TypeText ("<?xm-replace_text {Paragraph}?>");

         }

         rng.MoveToElement(titleName, false);

         rng.Select();

         rng = null;

         rng2 = null;

         tmpnode = null;

      } else if (Selection.IsParentElement("para")) {

         StartNewSubsection("section-level-1");

      }

   }

}

if (CanRunMacros()) {

  doConvertToSection();

}

]]></MACRO> 



<MACRO name="Join Paragraphs" key="" lang="JScript" id="1018" tooltip="Join Paragraphs" desc="Join selected paragraphs together into one paragraph"><![CDATA[

//*************************************************************************

// doJoinParagraphs ()

//

// DESCRIPTION:

//    - Joins all selected paragraphs into one paragraph.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function doJoinParagraphs() {

  var rng = ActiveDocument.Range;

  if (rng.IsInsertionPoint) {

    Application.Alert("Select the paragraphs to join");

  }

  else {

    var rng2 = rng.Duplicate;

    rng.Collapse(sqCollapseStart);  // the beginning of the selection

    rng.MoveToElement("para");  // Go to first paragraph in the selection

    var nd = rng.ContainerNode; // determine the element containing the para

    var parent = nd.parentNode;



    rng2.Collapse(sqCollapseEnd);  // the end of the selection

    rng2.MoveToElement("para", false);  // Go to last paragraph in the selection

    var nd2 = rng2.ContainerNode; // determine the element containing the Para

    var parent2 = nd2.parentNode;



    // check that the elements moved to are "Para"s

    if (rng.ContainerName == "para" && rng2.ContainerName == "para") {

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

                 && (rng2PrevSib.nodeName == "para")) { // Stop if an element other than Para is encountered

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



<MACRO name="Itemized-List" key="" lang="JScript" id="20404"><![CDATA[

//*************************************************************************

// fInsertListItem ()

//

// DESCRIPTION:

//    - Insert an List-Item content of current selection for data. 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 9/7/01, Initial creation.

//*************************************************************************

function fInsertListItem () {

   var rng = ActiveDocument.Range;

   var rng2 = ActiveDocument.Range;

   if (rng.ContainerNode.nodeName == "para") {

      rng.SelectContainerContents();

      var strListItemText = rng.Text;

      rng2 = rng.Duplicate;

      var nde = rng.ContainerNode;

      while ((nde.previousSibling != null) && (nde.previousSibling.nodeType == 3)) {       // Text node.

         nde.parentNode.removeChild(nde.previousSibling);

      }

      // If there's a same List right before this, merge it in together

      // with previous list.

      if ((nde.previousSibling) && (nde.previousSibling.nodeName == "itemized-list")) {

         nde = nde.previousSibling;

         rng.SelectNodeContents(nde.lastChild); 

         rng.SelectElement();

         rng.Collapse(sqCollapseEnd);

         if (rng.FindInsertLocation("list-item")) {

            rng.InsertElementWithRequired("list-item");

            rng.TypeText(strListItemText);

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         // If there's a same List right after this, merge it in together

         // with next list.

         nde = rng2.ContainerNode;

         if ((nde.nextSibling) && (nde.nextSibling.nodeName == "itemized-list")) {

            nde = nde.nextSibling;

            rng2.SelectElement();

            rng2.Delete();

            rng2.SelectNodeContents(nde);

            rng2.JoinElementToPreceding();

         } else {

            rng2.SelectElement();

            rng2.Delete();

         }

         rng.Select();

         // Els If there's a same List right after this, merge it in together

         // with next list.

      } else if ((nde.nextSibling) && (nde.nextSibling.nodeName == "itemized-list")) {

         nde = nde.nextSibling;

         rng.SelectNodeContents(nde.firstChild); 

         rng.SelectElement();

         rng.Collapse(sqCollapseStart);

         if (rng.FindInsertLocation("list-item")) {

            rng.InsertElementWithRequired("list-item");

            rng.TypeText(strListItemText);

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         rng2.SelectElement();

         rng2.Delete();

         rng.Select();

      } else {

         if (rng.FindInsertLocation("itemized-list")) {

            rng.InsertElementWithRequired("itemized-list");

            rng.TypeText(strListItemText);

            rng.Select();

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         rng2.SelectElement();

         rng2.Delete();

      }

   } else {

      Application.Alert ("Unable to insert List.");

   }

}

//*************************************************************************

// fInsertItemizedList ()

//

// DESCRIPTION:

//    - Insert an Itemized List using the content of current selection

//      for list data. 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function fInsertItemizedList () {

   var rng = ActiveDocument.Range;

   if (rng.ContainerNode.nodeName == "para") {

      fInsertListItem();

   } else {

      var rng2 = rng.Duplicate;

      rng.Collapse(sqCollapseStart);

      rng2.Collapse(sqCollapseEnd);

      rng2.MoveToElement();

      rng.MoveToElement();     // Move to the next element.

      if ((rng.ContainerNode.nodeName == "para") && (rng.ContainerNode != rng2.ContainerNode)) {

         while ((rng.ContainerNode.nodeName == "para") && (rng.ContainerNode != rng2.ContainerNode)) {

            rng.Select();

            var rng3 = rng.Duplicate;

            rng3.SelectAfterContainer();

            rng3.MoveToElement();

            fInsertListItem();

            rng = rng3;

            rng.Select();

         }

         rng.MoveToElement("",false);

         rng.Select();

      } else {

         rng = ActiveDocument.Range;

         if (rng.CanInsert("itemized-list")) {

            if (rng.ContainerNode.nodeName != "body") {

               rng.SelectContainerContents();

            }

            rng.Collapse (sqCollapseEnd);

            if (rng.IsInsertionPoint) {

               rng.InsertElementWithRequired("itemized-list");

               rng.TypeText("<?xm-replace_text {list-item}?>");

               rng.Select();

            }

         }

      }

   }

}

fInsertItemizedList();

]]></MACRO> 



<MACRO name="Enumerated-List" key="" lang="JScript" id="20412"><![CDATA[

//*************************************************************************

// fInsertListItemEnum ()

//

// DESCRIPTION:

//    - Insert an List-Item using the content of current selection for list data. 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function fInsertListItemEnum () {

   var rng = ActiveDocument.Range;

   var rng2 = ActiveDocument.Range;

   if (rng.ContainerNode.nodeName == "para") {

      rng.SelectContainerContents();

      var strListItemText = rng.Text;

      rng2 = rng.Duplicate;

      var nde = rng.ContainerNode;

      while ((nde.previousSibling != null) && (nde.previousSibling.nodeType == 3)) {       // Text node.

         nde.parentNode.removeChild(nde.previousSibling);

      }

      // If there's a same List right before this, merge it in together

      // with previous list.

      if ((nde.previousSibling) && (nde.previousSibling.nodeName == "enumerated-list")) {

         nde = nde.previousSibling;

         rng.SelectNodeContents(nde.lastChild); 

         rng.SelectElement();

         rng.Collapse(sqCollapseEnd);

         if (rng.FindInsertLocation("list-item")) {

            rng.InsertElementWithRequired("list-item");

            rng.TypeText(strListItemText);

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         // If there's a same List right after this, merge it in together

         // with next list.

         nde = rng2.ContainerNode;

         if ((nde.nextSibling) && (nde.nextSibling.nodeName == "enumerated-list")) {

            nde = nde.nextSibling;

            rng2.SelectElement();

            rng2.Delete();

            rng2.SelectNodeContents(nde);

            rng2.JoinElementToPreceding();

         } else {

            rng2.SelectElement();

            rng2.Delete();

         }

         rng.Select();

         // Els If there's a same List right after this, merge it in together

         // with next list.

      } else if ((nde.nextSibling) && (nde.nextSibling.nodeName == "enumerated-list")) {

         nde = nde.nextSibling;

         rng.SelectNodeContents(nde.firstChild); 

         rng.SelectElement();

         rng.Collapse(sqCollapseStart);

         if (rng.FindInsertLocation("list-item")) {

            rng.InsertElementWithRequired("list-item");

            rng.TypeText(strListItemText);

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         rng2.SelectElement();

         rng2.Delete();

         rng.Select();

      } else {

         if (rng.FindInsertLocation("enumerated-list")) {

            rng.InsertElementWithRequired("enumerated-list");

            rng.TypeText(strListItemText);

            rng.Select();

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         rng2.SelectElement();

         rng2.Delete();

      }

   }

}

//*************************************************************************

// fInsertEnumeratedList ()

//

// DESCRIPTION:

//    - Insert an Enumerated List using the content of current selection

//      for list data. 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function fInsertEnumeratedList () {

   var rng = ActiveDocument.Range;

   if (rng.ContainerNode.nodeName == "para") {

      fInsertListItemEnum();

   } else {

      var rng2 = rng.Duplicate;

      rng.Collapse(sqCollapseStart);

      rng2.Collapse(sqCollapseEnd);

      rng2.MoveToElement();

      rng.MoveToElement();     // Move to the next element.

      if ((rng.ContainerNode.nodeName == "para") && (rng.ContainerNode != rng2.ContainerNode)) {

         while ((rng.ContainerNode.nodeName == "para") && (rng.ContainerNode != rng2.ContainerNode)) {

            rng.Select();

            var rng3 = rng.Duplicate;

            rng3.SelectAfterContainer();

            rng3.MoveToElement();

            fInsertListItemEnum();

            rng = rng3;

            rng.Select();

         }

         rng.MoveToElement("",false);

         rng.Select();

      } else {

         rng = ActiveDocument.Range;

         if (rng.CanInsert("enumerated-list")) {

            if (rng.ContainerNode.nodeName != "body") {

               rng.SelectContainerContents();

            }

            rng.Collapse (sqCollapseEnd);

            if (rng.IsInsertionPoint) {

               rng.InsertElementWithRequired("enumerated-list");

               rng.TypeText("<?xm-replace_text {list-item}?>");

               rng.Select();

            }

         }

      }

   }

}

fInsertEnumeratedList();

]]></MACRO> 



<MACRO name="Definition-List" key="" lang="JScript" id="1750"><![CDATA[

//*************************************************************************

// fInsertDefListData ()

//

// DESCRIPTION:

//    - Insert an Definition List using the content of current selection

//      for definition-term. 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function fInsertDefListData (strDefData) {

   var rng = ActiveDocument.Range;

   var rng2 = ActiveDocument.Range;

   if (rng.ContainerNode.nodeName == "para") {

      rng.SelectContainerContents();

      var strDefTerm = rng.Text;

      rng2 = rng.Duplicate;

      var nde = rng.ContainerNode;

      while ((nde.previousSibling != null) && (nde.previousSibling.nodeType == 3)) {       // Text node.

         nde.parentNode.removeChild(nde.previousSibling);

      }

      // If there's a same List right before this, merge it in together

      // with previous list.

      if ((nde.previousSibling) && (nde.previousSibling.nodeName == "definition-list")) {

         nde = nde.previousSibling;

         rng.SelectNodeContents(nde.lastChild); 

         rng.SelectElement();

         rng.Collapse(sqCollapseEnd);

         if (rng.FindInsertLocation("definition-term")) {

            rng.InsertWithTemplate("definition-term");

            rng.TypeText(strDefTerm);

            rng.SelectAfterContainer();

            rng.InsertWithTemplate("definition-data");

            rng.TypeText(strDefData);

         }

         // If there's a same List right after this, merge it in together

         // with next list.

         nde = rng2.ContainerNode;

         if ((nde.nextSibling) && (nde.nextSibling.nodeName == "definition-list")) {

            nde = nde.nextSibling;

            rng2.SelectElement();

            rng2.Delete();

            rng2.SelectNodeContents(nde);

            rng2.JoinElementToPreceding();

         } else {

            rng2.SelectElement();

            rng2.Delete();

         }

         rng.Select();

         // Els If there's a same List right after this, merge it in together

         // with next list.

      } else if ((nde.nextSibling) && (nde.nextSibling.nodeName == "definition-list")) {

         nde = nde.nextSibling;

         rng.SelectNodeContents(nde.firstChild); 

         rng.SelectElement();

         rng.Collapse(sqCollapseStart);

         if (rng.FindInsertLocation("definition-term")) {

            rng.InsertWithTemplate("definition-term");

            rng.TypeText(strDefTerm);

            rng.SelectAfterContainer();

            rng.InsertWithTemplate("definition-data");

            rng.TypeText(strDefData);

            rng.Select();

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         rng2.SelectElement();

         rng2.Delete();

         rng.Select();

      } else {

         if (rng.FindInsertLocation("definition-list")) {

            rng.InsertElement ("definition-list");

            rng.InsertWithTemplate("definition-term");

            rng.TypeText(strDefTerm);

            rng.SelectAfterContainer();

            rng.InsertWithTemplate("definition-data");

            rng.TypeText(strDefData);

            rng.MoveToElement();

            rng.Select();

         } else {

            Application.Alert ("Unable to insert List here.");

            return;

         }

         rng2.SelectElement();

         rng2.Delete();

      }

   }

}

//*************************************************************************

// fInsertDefinitionList ()

//

// DESCRIPTION:

//    - Insert an Definition List using the content of current selection

//      for definition-term. 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function fInsertDefinitionList () {

   var rng = ActiveDocument.Range;

   if (rng.ContainerNode.nodeName == "para") {

      fInsertDefListData("<?xm-replace_text {definition-data}?>");

   } else {

      var rng2 = rng.Duplicate;

      rng.Collapse(sqCollapseStart);

      rng2.Collapse(sqCollapseEnd);

      rng2.MoveToElement();

      rng.MoveToElement();     // Move to the next element.

      if ((rng.ContainerNode.nodeName == "para") && (rng.ContainerNode != rng2.ContainerNode)) {

         while ((rng.ContainerNode.nodeName == "para") && (rng.ContainerNode != rng2.ContainerNode)) {

            rng.Select();

            var rng3 = rng.Duplicate;

            rng3.SelectAfterContainer();

            rng3.MoveToElement();

            if (rng3.ContainerNode == rng2.ContainerNode) {

               fInsertDefListData("<?xm-replace_text {definition-data}?>");

               rng = rng2;

            } else {

               rng3.SelectContainerContents();

               fInsertDefListData(rng3.Text);

               rng = rng3;

               rng3.SelectElement();

               rng3.Delete();

               rng.MoveToElement();

               rng.Select();

            }

         }

         rng.Select();

      } else {

         rng = ActiveDocument.Range;

         if (rng.CanInsert("definition-list")) {

            if (rng.ContainerNode.nodeName != "body") {

               rng.SelectContainerContents();

            }

            rng.Collapse (sqCollapseEnd);

            if (rng.IsInsertionPoint) {

               rng.InsertWithTemplate("definition-list");

               rng.TypeText("<?xm-replace_text {definition-term}?>");

               rng.Select();

            }

         }

      }

   }

}

fInsertDefinitionList();

]]></MACRO> 



<MACRO name="Remove-Lists" key="" lang="JScript" id="1751"><![CDATA[

var fFoundNode = false;

var arrChildNodes = new Array();

//#####################################################################

// A2. arrRngToNodes (rng, arr) 

//

// DESCRIPTION

// The function returns an array filled with DOMnodes that

// represent the selection.  This array's length equals

// the number of elements selected at this level

// in the DOMnode tree

// The method in which we determine which nodes belong to the selection

// is by iterating through all of the selection's parent node's 

// children.  The selection must be represented by one or a range

// of these child nodes.  Therefore, we iterate through the child nodes

// until we find a matching range.

//                       

// RETURN VALUE

// Nothing

// 

// PARAMETERS

// rng rngObject

// arr arrNodes Array of DOMnodes 

// 

// NOTES

// The return array is not ordered

// arrStyles is a global array

//

// PSEUDOCODE DESCRIPTION

// A.2.1. Initialize the array

// A.2.2. Find the start node for the selection intStartPosition

//        Search from the beginning of the array

//        for the first selected node

// A.2.3. Check if the range has been matched 

// A.2.4. Check if the range is matched when all the nodes 

//        have been selected

// A.2.5. Find the end node for the selection intEndPosition

//        Search from the end of the array

//        to find the last selected nodes

// A.2.6. Create the temporary array

//        Loop through the nodes

//        Check each text node for whitespace.

//        If a text node only contains white space,

//        do not add that node to the temporary array

//        Add all other nodes to the temporary array

// A.2.7. Traverse the entire temporary array

//        If a text node is found, mixed content,

//        stop traversal, set arrNodes length to zero

//        and return function

//        Else, copy the temporary array to arrNodes 

//        and return function

// A.2.8. By definition, if node's parent is null, 

//        the node is the root element 

// 

// HISTORY

// Yas Etessam January 16, 2000 Creation Date

//



function arrRngToNodes (rngObject, arrNodes) {

    var intStartPosition, intEndPosition, intMax; 

    var arrTemp = new Array();

    var rng = rngObject.Duplicate; // Create a new range object

    var rng2 = rngObject.Duplicate; // Create a new range object

    var nd_parent = rngObject.ContainerNode;

    // A.2.1.

    arrNodes.length=0;

    // A.2.2.

    if (nd_parent)  {

    var nd; 

	  

        // A.2.6.

        var reWS = /^\s*$/;

 

     var rngTest = ActiveDocument.Range;

     for ( var i = 0; i < nd_parent.childNodes.length; i ++ ) {

        nd=nd_parent.childNodes.item(i);

        rngTest.SelectNodeContents(nd);

        if ( rngObject.Contains( rngTest ) && !(nd.nodeName=="#text" && reWS.test(nd.data))) 

            arrTemp[arrTemp.length] = nd;

}// for 	 

	 



	// A.2.7.

	for ( x = 0; x< arrTemp.length; x++ ) {

            nd=arrTemp[x];

            if (nd.nodeName=="#text") {

                arrNodes.length=0;

		return; 

	    }

            else arrNodes[arrNodes.length]=nd;

	} 

       } 

  // A.2.8.

   else

   arrNodes[arrNodes.length]=rngObject.Document.documentElement;

}

//*************************************************************************

// hasNodes (node, strElementName)

//

// DESCRIPTION:

//    - Traverse the DOM tree and search for an Element name from the given

//    - strElementName.

//

// RETURN VALUE:

//    - True if found.

//    - False otherwise.

//

// PARAMETERS:

//    - node: DOM Node.

//    - strElementName: String containing the name of the Element looking

//      for.

//

// HISTORY:

//    David Ngo 7/19/01, Initial creation.

//*************************************************************************

function hasNode (node, strElementName) {

   if ((node.nodeType==1) && (node.nodeName == strElementName)) {

      fFoundNode = true;

   }

   // Process this node's children

   if ((node.hasChildNodes()) && (! fFoundNode)) {

      hasNode (node.firstChild, strElementName);

   }

   // Continue with this node's siblings

   if ((node.nextSibling!=null) && (! fFoundNode)) {

      hasNode(node.nextSibling, strElementName)

   }

}

//*************************************************************************

// fRemoveListNode ()

//

// DESCRIPTION:

//    - 

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

function fRemoveListNode () {

   var rng = ActiveDocument.Range;

   var strRestofLists = "";

   if ((rng.IsParentElement ("definition-term")) ||

       (rng.IsParentElement ("list-item")) ||

       (rng.IsParentElement ("list-title")) ||

       (rng.IsParentElement ("definition-data"))) {

      // Get the Content of list in Text form and Delete the Element.

      var nde = rng.ContainerNode;

      while ((nde.nodeName != "definition-term") &&

             (nde.nodeName != "list-item") &&

             (nde.nodeName != "list-title") &&

             (nde.nodeName != "definition-data") &&

             (nde.nodeName != "enumerated-list") &&

             (nde.nodeName != "itemized-list") &&

             (nde.nodeName != "definition-list")) {

         nde = nde.ParentNode;

      }

      // Check see if there're nested list within this list, if it is, stop.

      if ((nde.nodeName != "enumerated-list") &&

          (nde.nodeName != "itemized-list") &&

          (nde.nodeName != "definition-list")) {

         fFoundNode = false;

         hasNode (nde.firstChild, "itemized-list");

         if (! fFoundNode) {

            hasNode (nde.firstChild, "enumerated-list");

            if (! fFoundNode) {

               hasNode (nde.firstChild, "definition-list");

            }

         }

         if (fFoundNode) {

            Application.Alert ("Please remove nested List first.");

            return 0;

         }

      }

      if ((nde.nodeName == "definition-data") && (nde.previousSibling != null)) {

         nde = nde.previousSibling;

      }

      rng.SelectNodeContents(nde);

      rng.SelectElement();

      if ((nde.nodeName != "list-item") && 

          (nde.nodeName != "list-title") &&

          (nde.nodeName != "enumerated-list") &&

          (nde.nodeName != "itemized-list")) {

         var nde2 = nde.nextSibling;

         var rng2 = rng.Duplicate;

         rng.SelectAfterNode(nde2);

         rng2.ExtendTo(rng);

         rng = rng2;

      }

      var strListItemContent = rng.Text;

      // rng should be pointing to list and ready for delete.

      // Figure out the location of Selection, Is it at the first node, last

      // node or in the middle.

      // Remove any blank spaces after list-item.

      while ((nde.nextSibling != null) && (nde.nextSibling.nodeType == 3)) {       // Text node.

         nde.parentNode.removeChild(nde.nextSibling);

      }

      // Remove any blank spaces before list-item.

      while ((nde.previousSibling != null) && (nde.previousSibling.nodeType == 3)) {       // Text node.

         nde.parentNode.removeChild(nde.previousSibling);

      }

      if (((nde.previousSibling == null) ||

          (nde.previousSibling.nodeName == "list-title")) &&

          ((nde.nextSibling == null))) {                // Is the only Child for itemized & enumerated lists.

         rng.SelectContainerContents();

         rng.SelectElement();

         rng.Delete();

      } else if (((nde.previousSibling == null) ||

          (nde.previousSibling.nodeName == "list-title")) &&

          ((nde.nodeName != "list-item") &&

           (nde.nodeName != "list-title") &&

           (nde.nextSibling.nextSibling == null))) {   // Is the only Child for Definition list.

         rng.SelectContainerContents();

         rng.SelectElement();

         rng.Delete();

      } else if ((nde.previousSibling == null) ||

                 (nde.previousSibling.nodeName == "list-title")) {  // Is the fist child.

         rng2 = rng.Duplicate;

         rng2.Delete();

         rng.SelectBeforeContainer();

      } else if ((nde.nodeName != "list-item") && 

                 (nde.nodeName != "list-title") &&

                (nde2.nextSibling == null)) {      // Is last child for Definition list.

         rng2 = rng.Duplicate;

         rng2.Delete();

         rng.SelectAfterContainer();

      } else if (nde.nextSibling == null) {       // Is last child for the other two lists.

         rng2 = rng.Duplicate;

         rng2.Delete();

         rng.SelectAfterContainer();

      } else {

         // Selection is in the middle of a List. Save everything after

         // Selection and remove it.

         if ((nde.nodeName != "list-item") && (nde.nodeName != "list-title")) {

            nde = nde.nextSibling;

         }

         var strNodeName = nde.ParentNode.nodeName;

         var nde = nde.nextSibling;

         rng.Delete();

         rng.SelectNodeContents(nde);

         rng.SelectElement();

         var rng2 = rng.Duplicate;

         rng.SelectAfterNode(nde.ParentNode.lastChild);

         rng2.ExtendTo(rng);

         var strRestofLists = rng2.Text;    // Contents of rest of nodes.



         // Delete the rest of nodes.

         rng2.Delete();

         rng.SelectAfterContainer();

      }

      // Replace List tags with <para> tags, insert additional <para> tags

      // to make the content model valid.

      var preMatch, postMatch, matchArray, newStr = "";

      while (((matchArray = strListItemContent.match (/<equation>.+?<\/equation>|<figure>.+?<\/figure>|<table>.+?<\/table>|<hsdb-cite-include\s.+?\/>/))) != null) {

         preMatch = strListItemContent.substring (0, matchArray.index);

         preMatch = preMatch.replace (/<para>(.+?)<\/para>/g, "<\/para><para>$1</para><para>");

         newStr = newStr + preMatch + "<\/para>" + strListItemContent.substring (matchArray.index, matchArray.lastIndex) + "<para>";

         strListItemContent = strListItemContent.substring (matchArray.lastIndex, strListItemContent.length);

      }

      strListItemContent = strListItemContent.replace (/<para>(.+?)<\/para>/g, "<\/para><para>$1</para><para>");

      newStr = newStr + strListItemContent;

      strListItemContent = newStr;

      // Replace the outter most tags with <para> tags.

      strListItemContent = strListItemContent.replace (/list-item>/g, "para>");

      strListItemContent = strListItemContent.replace (/list-title>/g, "para>");

      strListItemContent = strListItemContent.replace (/definition-term>/g, "para>");

      strListItemContent = strListItemContent.replace (/definition-data>/g, "para>");

      strListItemContent = strListItemContent.replace (/<para><\/para>/g, "");

      // Insert the new Paragraphs with list-item's contents.

      rng.TypeText(strListItemContent);

      rng2 = rng.Duplicate;

      // If the Selection is in the middle, insert a new "lists" with all the

      // "list-item" following the Selection.

      if (strRestofLists.length > 0) {

         rng.InsertElement (strNodeName);

         rng.TypeText (strRestofLists);

      }

      // Move the pointer back into the original selection's Element.

      rng2.GoToPrevious(sqElement);

      rng2.Select();

   }

   return 1;

}

function fRemoveLists () {

   var rng = ActiveDocument.Range;

   var nde = rng.ContainerNode;

   var nde2 = nde;

   while ((nde2.nodeName != "itemized-list") &&

          (nde2.nodeName != "enumerated-list") &&

          (nde2.nodeName != "definition-list")) {

      nde2 = nde2.parentNode;

      if (nde.nodeName == "content") {

         return 1;

      }

   }

   nde2 = nde2.firstChild;

   while (nde2 != null) {   // Text node.

      var nde3 = nde2.nextSibling;

      if (nde2.nodeType == 3) {

         nde2.parentNode.removeChild(nde2);

      }

      nde2 = nde3;

   }

   while ((nde.nodeName != "list-title") &&

          (nde.nodeName != "list-item") &&

          (nde.nodeName != "definition-term") &&

          (nde.nodeName != "definition-data") &&

          (nde.nodeName != "enumerated-list") &&

          (nde.nodeName != "itemized-list") &&

          (nde.nodeName != "definition-list")) {

      nde = nde.parentNode;

      if (nde.nodeName == "content") {

         return 1;

      }

   }

   if ((nde.nodeName == "list-title") ||

       (nde.nodeName == "list-item") ||

       (nde.nodeName == "definition-term") ||

       (nde.nodeName == "definition-data")) {

      if ((nde.nodeName == "definition-term") && (nde.nextSibling != null)) {

         rng.SelectNodeContents(nde);     

         rng.SelectElement();

         nde = nde.nextSibling;

         var rng2 = rng.Duplicate;

         rng2.SelectNodeContents(nde);

         rng2.SelectElement();

         rng2.Collapse(sqCollapseEnd);

         rng.ExtendTo(rng2);

      } else if ((nde.nodeName == "definition-data") && (nde.previousSibling != null)) {

         rng.SelectNodeContents(nde);     

         rng.SelectElement();

         nde = nde.previousSibling;

         var rng2 = rng.Duplicate;

         rng2.SelectNodeContents(nde);

         rng2.SelectElement();

         rng2.Collapse(sqCollapseStart);

         rng.ExtendTo(rng2);

      } else {

         rng.SelectNodeContents(nde);     

         rng.SelectElement();

      }

   }

   arrRngToNodes (rng, arrChildNodes);

   for (i=0; i<arrChildNodes.length; i++) {

      fFoundNode = false;

      hasNode (arrChildNodes[i].firstChild, "itemized-list");

      if (! fFoundNode) {

         hasNode (arrChildNodes[i].firstChild, "enumerated-list");

         if (! fFoundNode) {

            hasNode (arrChildNodes[i].firstChild, "definition-list");

         }

      }

   }

   if (fFoundNode) {

      Application.Alert ("Please remove nested List first.");

      return 0;

   }

   if (rng.Text != "") {   // multiple list-item selected.

      // Splitup the Container before and after the Selection and then

      // remove the individual items of the Selection.

      var strTitleText = "";

      var rng2 = rng.Duplicate;

      rng.Collapse(sqCollapseStart);

      rng2.Collapse(sqCollapseEnd);

      var rng3 = rng.Duplicate;

      rng3.MoveToElement();

      var nde = rng.ContainerNode.firstChild;

      var rngFirstChild = ActiveDocument.Range;

      rngFirstChild.SelectNodeContents(nde);

      // If the Selection does not contains the First Child node in

      // the list, Split the Container node.

      if (rngFirstChild.ContainerNode != rng3.ContainerNode) {

         if ((nde.nextSibling == rng3.ContainerNode) &&

             (nde.nodeName == "list-title")) {

            strTitleText = rngFirstChild.Text;

            rngFirstChild.SelectElement();

            rngFirstChild.Delete();

            //rng.SplitContainer();

         } else {

            rng.SplitContainer();

         }

      }

      rng3 = rng2.Duplicate;

      rng3.MoveToElement ("", false);

      var nde = rng.ContainerNode.lastChild;

      var rngLastChild = ActiveDocument.Range;

      rngLastChild.SelectNodeContents(nde);

      //rngLastChild.Collapse(sqCollapseEnd);

      if (rngLastChild.ContainerNode != rng3.ContainerNode) {

         rng2.SplitContainer();

      }

      rng2.Select();

      if ((strTitleText.length > 0) && (rng2.CanInsert("list-title"))) {

         rng2.InsertElement ("list-title");

         rng2.typeText (strTitleText);

      }

   }

   rng.Select();

   var nde = rng.ContainerNode;

   nde = nde.firstChild;     // <list-title>.

   while (nde != null) {    // First list item.

      rng.SelectNodeContents(nde);

      rng.Select();

      while ((nde.nextSibling != null) && (nde.nextSibling.nodeType == 3)) {  // if Text node, remove them.

         nde.parentNode.removeChild (nde.nextSibling);

      }   

      nde = nde.nextSibling;

      if ((nde != null) && (nde.nodeName != "list-item") && (nde.nodeName != "list-title")) {

         nde = nde.nextSibling;

      }

      if (! fRemoveListNode()) {

         return 0;

      }

   }

}

fRemoveLists();

]]></MACRO> 



<MACRO name="Change-List-Type" key="" lang="JScript" id="1752"><![CDATA[

//*************************************************************************

// fChangeLists ()

//

// DESCRIPTION:

//    - Change from "itemized-list" to "enumerated-list" and

//      "enumerated-list" to "definition-list" and vice versa.

//

// RETURN VALUE:

//    - None.

//

// PARAMETERS:

//    - None.

//

// HISTORY:

//    David Ngo 7/10/01, Initial creation.

//*************************************************************************

var fFoundNode = false;

function hasNode (node, arrElementName) {

   if (node.nodeType==1) {

      for (i=0; i<arrElementName.length; i++) {

         if (node.nodeName == arrElementName[i]) {

            fFoundNode = true;

         }

      }

   }

   // Process this node's children

   if ((node.hasChildNodes()) && (! fFoundNode)) {

      hasNode (node.firstChild, arrElementName);

   }

   // Continue with this node's siblings

   if ((node.nextSibling!=null) && (! fFoundNode)) {

      hasNode (node.nextSibling, arrElementName)

   }

}

function fChangeLists () {

   var rng = ActiveDocument.Range;

   if ((rng.IsParentElement ("itemized-list")) ||

       (rng.IsParentElement ("enumerated-list")) ||

       (rng.IsParentElement ("definition-list"))) {

      var nde = rng.ContainerNode;

      while ((nde.nodeName != "itemized-list") &&

             (nde.nodeName != "enumerated-list") &&

             (nde.nodeName != "definition-list")) {

         nde = nde.ParentNode;

      }

      rng.SelectNodeContents(nde);

      rng.SelectElement();

      rng.Collapse(sqCollapseStart);

      var ndeParent = nde;

      var nde2 = nde.firstChild;

      while (nde2 != null) {   // Text node.

         var nde3 = nde2.nextSibling;

         if (nde2.nodeType == 3) {

            nde2.parentNode.removeChild(nde2);

         }

         nde2 = nde3;

      }

      if (nde.nodeName == "enumerated-list") {

         nde = nde.firstChild;

         if (rng.CanInsert ("itemized-list")) {

            rng.InsertElement ("itemized-list");

            var rng2 = rng.Duplicate;

            while (nde != null) {

               var nde3 = nde.nextSibling;

               rng2.SelectNodeContents(nde);

               rng.InsertElement (nde.nodeName);

               rng.TypeText (rng2.Text);

               rng.SelectAfterContainer();

               nde = nde3;

            }

            ndeParent.parentNode.removeChild(ndeParent);

         }

      } else if (nde.nodeName == "itemized-list") {

         nde = nde.firstChild;

         if (rng.CanInsert ("definition-list")) {

            rng.InsertElement ("definition-list");

            var rng2 = rng.Duplicate;

            var arrEleName = new Array ("enumerated-list", "itemized-list", "definition-list", "para", "block-quote", "equation", "figure", "table", "hsdb-cite-include");

            while (nde != null) {

               var nde3 = nde.nextSibling;

               rng2.SelectNodeContents(nde);

               if (nde.nodeName == "list-title") {

                  rng.InsertElement (nde.nodeName);

                  rng.TypeText (rng2.Text);

                  rng.SelectAfterContainer();

                  nde = nde3;

               } else {

                  fFoundNode = false;

                  hasNode (nde.firstChild, arrEleName);

                  if (fFoundNode) {

                     Application.Alert ("*** Unable to change list type, list-item can not be converted into definition-term\n\n." + rng2.Text);

                     nde3 = rng.ContainerNode;

                     nde3.parentNode.removeChild(nde3);

                     return;

                  }

                  rng.InsertElement ("definition-term");

                  rng.TypeText (rng2.Text);

                  rng.SelectAfterContainer();

                  nde = nde3;

                  if (nde != null) {

                     var nde3 = nde.nextSibling;

                     rng2.SelectNodeContents(nde);

                     rng.InsertElement ("definition-data");

                     rng.TypeText (rng2.Text);

                     rng.SelectAfterContainer();

                     nde = nde3;

                  } else {

                     rng.InsertElement ("definition-data");

                     rng.TypeText("<?xm-replace_text {definition-data}?>");

                     rng.SelectAfterContainer();

                  }

               }

            }

            ndeParent.parentNode.removeChild(ndeParent);

         }

      } else if (nde.nodeName == "definition-list") {

         nde = nde.firstChild;

         if (rng.CanInsert ("enumerated-list")) {

            rng.InsertElement ("enumerated-list");

            var rng2 = rng.Duplicate;

            while (nde != null) {

               var nde3 = nde.nextSibling;

               rng2.SelectNodeContents(nde);

               if (nde.nodeName == "list-title") {

                  rng.InsertElement (nde.nodeName);

               } else {

                  rng.InsertElement ("list-item");

               }

               rng.TypeText (rng2.Text);

               rng.SelectAfterContainer();

               nde = nde3;

            }

            ndeParent.parentNode.removeChild(ndeParent);

         }

      }

      rng.Select();

      var rng2 = rng.Duplicate;

      rng2.MoveToElement();

      if ((rng2.ContainerNode.nodeName == "itemized-list") ||

          (rng2.ContainerNode.nodeName == "enumerated-list") ||

          (rng2.ContainerNode.nodeName == "definition-list")) {

         rng.MoveToElement();

      } else {

         rng.MoveToElement ("", false);

      }

      rng.Select();

   }

}

fChangeLists();

]]></MACRO> 

<MACRO name="Display Online Image Chooser" key="" lang="JScript" id="1311"><![CDATA[
function DisplayOnlineImagePage () {
   try {
      try {
         ResourceManager.SelectTab("Content Chooser");
      } catch(e) {
         ResourceManager.AddTab("Content Chooser","XMOLImageChooser.ImageChooserControl");
      } // catch
   } catch(e) {
      Application.MessageBox("Failed to load the Online Image Chooser", 48, "Tufts");
      Application.Run("Remove Online Image Chooser"); 
      return; 
   }
//   ResourceManager.SelectTab("Content Chooser");
   // ctlDictionary: global control variable
   ctlDictionary = ResourceManager.ControlInTab("Image Chooser");
   if ( ctlDictionary == null ) {
      Application.Alert("Failed to load the Online Image Chooser", 48, "Tufts");
      return; 
   }
}
// Global Var
var ctlDictionary; 
DisplayOnlineImagePage();

]]></MACRO> 

<MACRO name="Remove Online Image Chooser" hide="false" lang="JScript" id="1416"><![CDATA[

function RemoveImageChooser () {

   try {    

      ctlDictionary = null; 

      ResourceManager.RemoveTab("Image Chooser");

   } catch (e) { }

}

RemoveImageChooser(); 

]]></MACRO> 



<MACRO name="On_Drop_HTML" lang="JScript" hide="true"><![CDATA[

function fImageDrop () {

   var imgFileName;

   ctlDictionary = ResourceManager.ControlInTab("Image Chooser");

   imgString = ctlDictionary.getSourceImage;

   if (imgString != "") {

      if (imgString.search (/text/) == -1) {   // GIF Image.

         imgString = imgString.replace (/chooser_icon\//, "");

         try {

            var fso = new ActiveXObject("XMOLImageChooser.ImageChooserControl");

            fso.showDialog();

         } catch(exception) {

            Application.Alert ( exception );

            fso = null;

         }

         var curDocProps=Application.CustomProperties;

         var matchArray = imgString.match (/.+\/(.+)\/(.+)/);

         if (matchArray != null) {

            try {

               if (curDocProps.item("ReturnStatus").Value != "vbOK") {

                  return;

               }

               // Create filename for image to copy to local path.

               if (curDocProps.item("ImageSize").Value == "thumb") {

                  imgString = imgString.replace (/(.+)\/(.+)\/(.+)/, "$1/thumbnail/") + matchArray[2];

               } else if (curDocProps.item("ImageSize").Value == "half") {

                  imgString = imgString.replace (/(.+)\/(.+)\/(.+)/, "$1/small_data/") + matchArray[2];

               } else if (curDocProps.item("ImageSize").Value == "full") {

                  imgString = imgString.replace (/(.+)\/(.+)\/(.+)/, "$1/data/") + matchArray[2];

               }

//               imgFileName = Application.ActiveDocument.Path + "\\images\\" + matchArray[2];

               imgFileName = Application.Path + "\\document\\images\\" + matchArray[2];

               Application.CopyAssetFile (imgString, imgFileName, true);

               var Dp = Application.DropPoint;

               Dp.Select();

               Selection.InsertImage(imgFileName);

               Selection.ContainerAttribute ("image-class") = curDocProps.item("ImageSize").Value;

               Selection.ContainerAttribute ("link-type") = curDocProps.item("ImageLinkType").Value;

               Selection.ContainerAttribute ("description") = curDocProps.item("ImageDescription").Value;

               Selection.ContainerAttribute ("content-id") =  matchArray[2];

            } catch (e) {

            }

         }

      } else {

         //var matchArray = imgString.match (/.+\/(.+)/);   // DN - 11-16-01

         var matchArray = imgString.match (/.+\/(.+)\/(.+)/);     // DN - 11-16-01

         if (matchArray != null) {

            try {

               // Create hsdb-cite-include node.

               var Dp = Application.DropPoint;

               Dp.Select();

               if (Dp.CanInsert("hsdb-cite-include")) {

                  Dp.InsertWithTemplate ("hsdb-cite-include");

               } else {

                  if (Dp.FindInsertLocation ("hsdb-cite-include")) {

                     Dp.InsertWithTemplate ("hsdb-cite-include");

                  }

               }

               Dp.Select();

               Selection.ContainerAttribute ("content-id") = matchArray[1];

               Selection.ContainerAttribute ("node-ids") = matchArray[2];

            } catch (e) {

               Application.Alert ("Unable to create hsdb-cite-include tag.");

            }

         }

      }

   } 

   ctldictionary = null;

   fso = null;

}

fImageDrop();

]]></MACRO> 



<MACRO name="On_Drop_TEXT" lang="JScript" hide="true"><![CDATA[

function fTextDrop () {

   var imgFileName;

   ctlDictionary = ResourceManager.ControlInTab("Image Chooser");

   imgString = ctlDictionary.getSourceImage;

   if (imgString != "") {

      imgString = imgString.replace (/chooser_icon\//, "");

      try {

         var fso = new ActiveXObject("XMOLImageChooser.ImageChooserControl");

         fso.showDialog();

      } catch(exception) {

         var strErr = "Unable to load form for Online Image Chooser.\n";

         Application.Alert ( exception );

         fso = null;

      }

      var curDocProps=Application.CustomProperties;

      var matchArray = imgString.match (/.+\/(.+)\/(.+)/);

      if (matchArray != null) {

         try {

            if (curDocProps.item("ReturnStatus").Value != "vbOK") {

               return;

            }

            // Create filename for image to copy to local path.

            if (curDocProps.item("ImageSize").Value == "thumb") {

               imgString = imgString.replace (/(.+)\/(.+)\/(.+)/, "$1/thumbnail/") + matchArray[2];

            } else if (curDocProps.item("ImageSize").Value == "half") {

               imgString = imgString.replace (/(.+)\/(.+)\/(.+)/, "$1/small_data/") + matchArray[2];

            } else if (curDocProps.item("ImageSize").Value == "full") {

               imgString = imgString.replace (/(.+)\/(.+)\/(.+)/, "$1/data/") + matchArray[2];

            }

//            imgFileName = Application.ActiveDocument.Path + "\\images\\" + matchArray[2];

            imgFileName = Application.Path + "\\document\\images\\" + matchArray[2];

            Application.CopyAssetFile (imgString, imgFileName, true);

            var Dp = Application.DropPoint;

            Dp.Select();

            Selection.InsertImage(imgFileName);

            Selection.ContainerAttribute ("image-class") = curDocProps.item("ImageSize").Value;

            Selection.ContainerAttribute ("link-type") = curDocProps.item("ImageLinkType").Value;

            Selection.ContainerAttribute ("description") = curDocProps.item("ImageDescription").Value;

            Selection.ContainerAttribute ("content-id") =  matchArray[2];

         } catch (e) {

         }

      }

   } else {

      imgString = ctlDictionary.getURLLocation;

      if (imgString != "") {

         //var matchArray = imgString.match (/.+\/(.+)\/(.+)/);  // DN - 11-16-01

         var matchArray = imgString.match (/.+\/(.+)\/(.+)/);    // DN - 11-16-01

         if (matchArray != null) {

            try {

               // Create hsdb-cite-include node.

               var Dp = Application.DropPoint;

               Dp.Select();

               if (Dp.CanInsert("hsdb-cite-include")) {

                  Dp.InsertWithTemplate ("hsdb-cite-include");

               } else {

                  if (Dp.FindInsertLocation ("hsdb-cite-include")) {

                     Dp.InsertWithTemplate ("hsdb-cite-include");

                  }

               }

               Dp.Select();

               Selection.ContainerAttribute ("content-id") = matchArray[2];

               Selection.ContainerAttribute ("node-ids") = matchArray[2];

            } catch (e) {

            }

         }

      }

   }

   ctldictionary = null;

   fso = null;

}

fTextDrop();

]]></MACRO>



<!-- ######################################################################

-  End  Code.                                             

####################################################################### -->



<MACRO name="Collapse Header Form" key="" lang="JScript" id="1143"><![CDATA[



 var rng = ActiveDocument.Range;

 if ( ActiveDocument.getElementsByTagName("header").length > 0 ) {

     rng.SelectNodeContents(ActiveDocument.getElementsByTagName("header").item(0));

     rng.CollapsedContainerTags = true;

     ActiveDocument.RefreshCssStyle(); 

 }]]></MACRO> 



<MACRO name="Expand Header Form" key="" lang="JScript" id="1142"><![CDATA[

var rng = ActiveDocument.Range;

 if ( ActiveDocument.getElementsByTagName("header").length > 0 ) {

     rng.SelectNodeContents(ActiveDocument.getElementsByTagName("header").item(0));

     rng.CollapsedContainerTags = false;

 }

]]></MACRO> 



<MACRO name="HSDB Check In" key="" lang="JScript" id="1744"><![CDATA[
// FUNCTIONS
///////////////////////////////////////////////////////////////////////////////////

function blnHasTitle () {
    // Check whether a title has already been selected
    var rng = ActiveDocument.Range;    
    var ndeHeader = ActiveDocument.getElementsByTagName("header").item(0);
    if ( ndeHeader ) {
        if ( ndeHeader.getElementsByTagName("title").length == 0 ) 
            return false; 
        var ndeTitle = ndeHeader.getElementsByTagName("title").item(0);
	    if (ndeTitle) {
	       rng.SelectNodeContents(ndeTitle);
	       var strTitle = rng.Text; 
	       if (!(strTitle == null || strTitle == "" )) return true;
               else return false;
        } 
    }
    return false; 
} 	  


function blnHasCourseSelected () {
// Check whether a course has already been selected
    var rng = ActiveDocument.Range;
    var ndeHeader = ActiveDocument.getElementsByTagName("header").item(0);
    if ( ndeHeader ) {
         if ( ndeHeader.getElementsByTagName("course-ref").length == 0 ) 
            return false; 
         var ndeCourse = ndeHeader.getElementsByTagName("course-ref").item(0);
	   if (ndeCourse && ndeCourse.hasAttribute("course-id")) 
	       var strCourseID = ndeCourse.getAttribute("course-id");  
	   if (!(strCourseID == null || strCourseID == "" )) return true;
         else return false; 
    }
    return false; 
} 	


function nulDoCheckIn () {
    var doc = Application.ActiveDocument;
    var rng = ActiveDocument.Range;

    try { 
    var strToken = Application.CustomProperties.item("logonToken").value;
    var strPassword = Application.CustomProperties.item("logonPassword").value;
    } catch (e) {
        Application.Alert("Please log onto the database","Check In Cancelled."); 
        return;
    }
    

    if (!doc) {
      // No document open
      return;
    }

    if (!doc.IsValid) {
      // Document is not valid. It must be valid before it can  
      // be checked in.
      var strErr = "The current document is not valid.\n";
      strErr += "Please ensure that the current document is valid\n";
      strErr += "before checking in the document.";
      Application.Alert(strErr, "Check-in Operation Cancelled");
      doc.Validate(); 
      return; // cancel the check in
    }

    if (!blnHasTitle()) {
    // Check if the Document has a title
      var strErr = "The current document does not contain a title.\n";
      strErr += "Please ensure that a title is added\n";
      strErr += "before checking in the document.";
      Application.Alert(strErr, "Check-in Operation Cancelled");
      return; // cancel the check in
    }

    if (! blnHasCourseSelected()) {
      var strErr = "A course has not been selected for this document.\n";
      strErr += "Please ensure that a course is added\n";
      strErr += "before checking in the document.";
      Application.Alert(strErr, "Check-in Operation Cancelled");
      return; // cancel the check in
    }

    // Check if Image Upload is required
    if ( blnNeedImageUpload ()) {
        // Run Image Upload 
        nulCheckInImageUpload ()
        if ( blnNeedImageUpload() ) return; 
    }

 Application.Run("Add Status");
 var strStatus = Application.CustomProperties.item("strStatus").value;
 if (!strStatus) {
	     return;
 }
 var strStatusNote = Application.CustomProperties.item("strStatusNote").value;
 var strModifiedNote = Application.CustomProperties.item("strModifiedNote").value;
 if (Application.CustomProperties.item("strStatus") != null) 
				Application.CustomProperties.item("strStatus").Delete();
 if (Application.CustomProperties.item("strStatusNote") != null)
    Application.CustomProperties.item("strStatusNote").Delete();
if (Application.CustomProperties.item("strModifiedNote") != null)
    Application.CustomProperties.item("strModifiedNote").Delete();

   // Get the URL to HSDB
   var strHSDB = Application.CustomProperties.item("HSDB").value; 
   try {  
       var xmlhttp = new ActiveXObject ("MSXML2.XMLHTTP");
	} catch (e) { 
	      Application.Alert( "Please verify that you have the Microsoft MSXML Parser Installed");
	      return;
	 } 

  var strContentID = ActiveDocument.documentElement.getAttribute("content-id");
  if ( strContentID == null || strContentID == "" ) {
	var strNewDoc = "This document seems to be new. Would you like to add it to the database?";
	if(!Application.Confirm(strNewDoc)){
		return;
	}

	//document is not in the database. create a new blank doc to get a content-id
	var docCourse = Application.Activedocument.getElementsByTagName("course-ref").item(0).getAttribute("course-id");
	var header = strHSDB + "document_make?token=" + Application.CustomProperties.item("logonToken").value;
	header = header + "&password=" + Application.CustomProperties.item("logonPassword").value;
	header = header + "&course_id=" + docCourse; 
	header = header + "&content=";
	xmlhttp.open("POST",header, "false");
	xmlhttp.send("");

	var response = new ActiveXObject("MSXML2.DOMDOCUMENT");
 	response.loadXML(xmlhttp.responseText);
	strContentID = response.selectSingleNode("//ID").text;
	ActiveDocument.documentElement.setAttribute("content-id",strContentID);
	UpdateToken(response.selectSingleNode("TOKEN").text);
	xmlhttp.abort();	//reset the object so it can be used again
  }  

   // Get the parameters to pass to the Checkin form 
   // Save a Copy of the Original Document

   try {   
	   rng = ActiveDocument.Range; 
	   var rngOrig = rng.Duplicate; 
	   rng.SelectAll();
	   // Strip the Temporary URI's out and make a copy of that document without the 
	   // temp-uri's.  This is the text that will be sent to the HSDB
	   Application.Run("Strip TempURI");
	   var strDocument = rng.Text;
	   ActiveDocument.Undo(); 
	  
   } catch ( e ) {
       Application.Alert(e.description, "HSDB CheckIn"); 
   }
   
   // Add the XML version
   strDocument = '<?xml version="1.0" encoding="ISO-8859-1"?><!DOCTYPE content SYSTEM "hscml.dtd">' + strDocument; 

    // Load Internet Explorer  
    try {
	    var objIE = new ActiveXObject ("InternetExplorer.Application");
	   // objIE.Visible = 0;  // keep MSIE invisible
	    
	    objIE.Navigate2(Application.Path + "//Forms//HSDB//Checkin.htm"); 
	    while ( objIE.Busy ) { 
	        Application.DisplayAlerts = 0;
	        Application.Alert("Screen refresh");
	        Application.DisplayAlerts = -1;  
	    
	    }; // wait til MSIE is ready
	    var objDoc = objIE.Document;
	    // Add the token, password and course_id 
	    objDoc.all.item("token").value = Application.CustomProperties.item("logonToken").value; 
	    objDoc.all.item("password").value = Application.CustomProperties.item("logonPassword").value;
	    objDoc.all.item("content_id").value = strContentID; 
	    objDoc.all.item("status").value = strStatus;
     objDoc.all.item("status_note").value = strStatusNote;
     objDoc.all.item("modified_note").value = strModifiedNote;
     objDoc.all.item("data").value = strDocument; 
	    objDoc.all.item("submitbutton").click();
	     
	    var obj=new ActiveXObject("SQExtras.Methods");
	    while ( objIE.Busy ) {
	        obj.GoToSleep(2000);
	    }; // wait til MSIE is ready
        obj = null; 	  
	    var strResponseText; 
	    if ( objIE.Document.XMLDocument ) 
	        strResponseText = objIE.Document.XMLDocument.xml;
	    else 
	        strResponseText = objIE.Document.body.innerHTML; 
	
	   
	 
	} catch (e) {
	    Application.Alert(e.description, "HSDB Check In");
	}
    var xmlDoc = new ActiveXObject("Msxml2.DOMDocument");
    xmlDoc.async = false;
    if (!xmlDoc.loadXML(strResponseText)){
         var strErr = "Invalid response from the server.\n.";
         strErr += "Check in failed for.\n" + strResponseText;
         Application.Alert( strErr ); 
         return; 
    }   
    
    
    objIE.Quit();
	objIE = null;     
    var nodStatus = xmlDoc.documentElement.selectSingleNode("STATUS");
    if (!(nodStatus && nodStatus.text == "00" )) {
          TuftsErrHandle( nodStatus.text );       
          xmlDoc = null; 
          xmlhttp = null; 
          return;          
    } else {
          // Retrieved the XML successfully  
           
          UpdateToken(xmlDoc.documentElement.selectSingleNode("TOKEN").text);
          var strMsg = "The current document ";
          strMsg += ActiveDocument.Name + "\n";
          strMsg += "was checked in.\n\n";
          Application.Alert(strMsg); 
          doc.Close(2);
          // Now that the document is closed, remove any temporary files from the 
          // local machine
          Application.Run("Strip Local Images");  
           
    }

xmlDoc = null;
xmlhttp = null; 
objToken = null;
objAppProps = null; 
    

}


// MAIN
///////////////////////////////////////////////////////////////////////////////////

// Check if there are local images that
// require uploading to the CMS

// Inform the user that the local file will 
// be removed if the checkin is successful


    nulDoCheckIn(); 
]]></MACRO> 


<MACRO name="Insert Image" key="" lang="JScript" id="1112"><![CDATA[

function nulInsertImage () {

	// If On-Line

	if ( Application.CustomProperties.item("logonToken") == null ){

	     // 

	     // Throw up the Image Dialog, two choices, 

	     

	     // 1. Logon to the HSDB Database

	     // 2. Insert an image now, add metadata to the image later

	     

	     var strErr = "To insert an image in the current document\n";

	     strErr += "and upload to the HSDB Database,\n";

	     strErr += "please logon to the HSDB Database\n\n";

	     strErr += "Would you like to Logon now?";

	     if ( Application.Confirm( strErr) ) {

	         ResourceManager.Visible = true;

	         ResourceManager.SelectTab("HSDB"); 

	         return;	     

	     } else {

	         // Find a valid place to insert the image 

	         if ( !blnFindInsertionLocation ("hsdb-graphic")){

	              if (!blnFindInsertionLocation("figure")) {

	                  Application.Alert("Could not find a valid location to insert an image", "Insert Image Cancelled");

	                  return; 

	              }    

	         }

	         

	         // Insert an image now, add metadata to the image

	         // Please select an image, you will be prompted to upload

	         // the Image to the HSDB database when checking in this document

	         strErr = "Please browse to a local image.\n";

	         strErr += "You will be prompted to upload \n";

	         strErr += "the Image to the HSDB when\n";

	         strErr += "checking in this document";

	         Application.Alert( strErr ); 

	         var Dlg = new ActiveXObject("SQExtras.FileDlg");

             var chosen = Dlg.DisplayImageFileDlg(true, "Choose an image","Image Files (*.gif,*.jpg,*.png)|*.gif;*.jpg;*.jpeg;*.png;");

             if (chosen && Dlg.FullPathName != null) {

                var chosenFile = Dlg.FullPathName;

                  if ( !Selection.CanInsert("hsdb-graphic")) 

                       Selection.InsertElement("figure");

                  Selection.InsertElement("hsdb-graphic");

                  if ( Selection.ContainerName == "hsdb-graphic") {

                     Selection.ContainerAttribute("temp-uri") = Dlg.FullPathName 

                   

                  }

             }

	     }

	     

	     return; 

	} 

	

	try {

	   var Dlg = new ActiveXObject("HSDBTabSQ.ImageForm");

	   

	} catch ( exception ) {

	    // 

	    Application.Alert("HSDB Console not found\nInsertImage operation cancelled.");  

	}

	// Check for the Course ID

	//

	if ( ActiveDocument.getElementsByTagName("course-ref").length == 0) {

	    var strErr = "A course must be selected in the Header\n";

	    strErr += "before Images can be uploaded to the database\n";

	    strErr += "Please select a Course and try again.";

	    Application.Alert(strErr);

	    return;

	}

	

	// Launch Image Form 

	Dlg.doShowImageForm();

	

	// Free variable

	Dlg = null;

}

nulInsertImage(); 



]]></MACRO> 











<MACRO name="On_Document_Open_View" key="" lang="JScript" hide="true"><![CDATA[





function nulAddDocumentTitle () {



 

  try {

     var objDoc = ActiveDocument; 

     var rng = ActiveDocument.Range; 

     var strDocumentName;

     var strContentID; 

     if ( Documents.count == 0 ) return; 

     // Check if the Document has a name

     if ( objDoc.name == "" ) {

       // Check if the Document has a content ID and Title

       if ( objDoc.documentElement.hasAttribute("content-id")) {

           strContentID = objDoc.documentElement.getAttribute("content-id");

           strDocumentName = "Document_" + strContentID + ".xml"; 

           // Save the document with this name 

           // Turn off alerts

	   Application.DisplayAlerts = sqAlertsNone;

	   // Next two lines should display nothing

	   ActiveDocument.SaveAs( Application.Path + "\\document\\" + strDocumentName);   

	   // Turn alerts back on

	   Application.DisplayAlerts = sqAlertsAll;

       }

   } 

  

  } catch (e) {

     Application.Alert(e.description, "Add Document Title"); 

   

  }



}





// MAIN 

// Documents opened from the HSDB Tab are untitled

// Give them a title and save them in the XMetaL 2/documents area



nulAddDocumentTitle();   



// Download any images which needs to be downloaded from the HSDB 

   if ( Application.CustomProperties.item("blnLoggedOn") && 

           Application.CustomProperties.item("blnLoggedOn").value == true ) { 

       // ensure user is logged into the database

       Application.Run("Download Images");

   }



]]></MACRO> 

<MACRO name="ToggleSectionStyle" key="" lang="JScript" id="1519" tooltip="Toggle Section Style"><![CDATA[

function doToggleBodyLevelStyle() {

	var nodes = Application.ActiveDocument.getElementsByTagName("body");

	var body = nodes.item(0);

	if (body.getAttribute("levelstyle") == "numbered")

		body.setAttribute("levelstyle", "outline");
		
	else if (body.getAttribute("levelstyle") == "outline")

		body.setAttribute("levelstyle", "naked");

	else

		body.setAttribute("levelstyle", "numbered")

}



if (CanRunMacros()) {

	doToggleBodyLevelStyle();

}]]></MACRO>



<MACRO name="Left" key="" lang="VBScript"><![CDATA[



Selection.MoveLeft 

]]></MACRO>

<MACRO name="Add Status" key="" lang="JScript" id="1901" tooltip="Add Document Status"><![CDATA[
var Form = FormFuncs.CreateFormDlg("Forms\\HSDB\\dialogs\\Status.hhf");
Form.DoModal();
Form = null;
]]></MACRO>

</MACROS> 

