<?xml version="1.0"?>
<!DOCTYPE MACROS SYSTEM "macros.dtd">

<MACROS> 

<!--HSDB Macros-->

<MACRO name="On_Application_Open" lang="VBScript" hide="true"><![CDATA[

Sub ConfigureResourceManager()

	ResourceManager.AddTab "HSDB", "HSDBTabSQ.HSDBTab"

	ResourceManager.RemoveTab "Assets"
	ResourceManager.SelectTab "HSDB"

End Sub

Call ConfigureResourceManager
Call Application.Run("LoadLoginFunctions")
 
' Set Application Level variables
Application.CustomProperties.Add "SecureHSDB", "https://www.hsdb.tufts.edu:9115/api/"  
Application.CustomProperties.Add "HSDB", "http://www.hsdb.tufts.edu:9015/api/"  
Application.CustomProperties.Add "ImageHSDB", "http://www.hsdb.tufts.edu:9015/"  

]]></MACRO> 

<MACRO name="On_Application_Close" lang="VBScript" hide="true"><![CDATA[
	ResourceManager.RemoveAllTabs
]]></MACRO>
<!--Default XmetaL Macros-->

<MACRO name="MakeReplaceText" key="Ctrl+Alt+Z" lang="VBScript" id="1127">
<![CDATA[
 ' SoftQuad Script Language VBSCRIPT:
 if Application.Documents.Count = 0 Then
   Application.Alert("No Open Document")
 
 Else 

   If Application.ActiveDocument.ViewType = 2 Then
     Application.Alert("This macro doesn't work in Plain Text mode")
   Else 
     txt = Selection.Text
     Selection.Delete
     Selection.InsertReplaceableText(txt)
   End If
 End If
 
]]>
</MACRO> 

<MACRO name="Refresh Macros" key="Ctrl+Alt+R" lang="JScript" id="1270" tooltip="" desc="">
<![CDATA[
 Application.RefreshMacros();
 Application.Alert("Macros have been refreshed");
]]>
</MACRO> 

<MACRO lang="JScript" name="Open Document Macros" id="1272">
<![CDATA[
 var count = Application.Documents.Count;
 if (count == 0) {
   Application.Alert("No Open Document");
 }
 else {
   var mpath = ActiveDocument.MacroFile;
   Documents.Open(mpath, 1);  // open in tags on view
 }
]]>
</MACRO> 

<MACRO name="Open Application Macros" lang="JScript" id="1274">
<![CDATA[
 var mpath = Application.MacroFile;
 Documents.Open(mpath, 1); // open in tags on view
]]>
</MACRO> 

<MACRO name="On_Update_UI" hide="true" lang="JScript">
<![CDATA[
// this will only work if no On_Update_UI macro is defined for the DTD
if (Selection.IsInsertionPoint && ActiveDocument.ViewType == 1) {
// this should only apply to the tags-on view, and allow selection of the top-level element
   if (Selection.ContainerNode == null) {
      Selection.MoveRight();
   }
   if (Selection.ContainerNode == null) {
      Selection.MoveLeft();
   }
}
]]>
</MACRO> 

<MACRO name="On_Mouse_Over" lang="JScript" hide="true"><![CDATA[
// Reset the Status Text and the Cursor in case a different document changed them and they are stuck.
function OnMouseOver()
{
   Application.SetStatusText("");
   Application.SetCursor(0);
}
OnMouseOver();
]]></MACRO> 

<MACRO name="On_DTD_Open_Complete" key="" hide="true" lang="VBScript"><![CDATA[
Function doaddElements()
  ' In the macro the new document is NOT the active document
  ' so to get at the document type information do
  Set docType = Application.NewDocumentType

  ' root element
  Dim rootElem
  rootElem = docType.name
' Application.Alert rootElem
  If rootElem = "Article" Then
    ' add Deletion element
    docType.addElement "Deletion", "Deletion", True , False
    ' add attribute UserName
    docType.addAttribute "Deletion", "UserName", "", 0, 0 
    ' add attribute Time
    docType.addAttribute "Deletion", "Time", "", 0, 0 
    
    ' add Insertion element
    docType.addElement "Insertion", "Insertion", True , False
    ' add attribute UserName
    docType.addAttribute "Insertion", "UserName", "", 0, 0 
    ' add attribute Time
    docType.addAttribute "Insertion", "Time", "", 0, 0 
    
    ' add Annotation element
    docType.addElement "Annotation", "Annotation" , True , False
    ' add attribute UserName
    docType.addAttribute "Annotation", "UserName", "", 0, 0 
    ' add attribute Time
    docType.addAttribute "Annotation", "Time", "", 0, 0 
    ' add attribute Initials
    docType.addAttribute "Annotation", "Initials", "", 0, 0 
    ' add attribute Comment
    docType.addAttribute "Annotation", "Comment", "", 0, 0 
    
    'add Deletion element  to the other elements inclusion list 
    If docType.hasElementType("Deletion") And docType.hasElementType("Article") Then
      docType.addElementToInclusions "Deletion", "Article"
    End If
    
    'add Insertion element  to the other elements inclusion list 
    If docType.hasElementType("Insertion") And docType.hasElementType("Article") Then
      docType.addElementToInclusions "Insertion", "Article"
    End If

    'add Annotation element  to the other elements inclusion list 
    If docType.hasElementType("Annotation") And docType.hasElementType("Article") Then
      docType.addElementToInclusions "Annotation", "Article"
    End If
  End If
End Function

doaddElements()
]]></MACRO> 

<!--Customization Macros-->

<MACRO name="Set Course List" lang="JScript" hide="true"><![CDATA[
// ############################################################
// DESCRIPTION
// Used to initialize the Custom Application Property that contains 
// the Course List for the current user
//
// If the user is logged into the database and a list of courses is
// retrieved, the list is stored as an XML string within the Course
// List Application Custom Property
//
// NOTE 
// If the user is not Logged On, this will not prompt for
// a Login
 
function nulSetCourseList() {
  var objAppProps, objToken, objCourseList; 
  objAppProps=Application.CustomProperties;
  if ( objAppProps.item("CourseList") ) objAppProps.item("CourseList").Delete(); 
  if (blnLoggedIn()) { 
      // Retrieve the token 
      if (Application.CustomProperties.item("logonToken") == null ){ 
          Application.Alert("Course Chooser: \n Please Login to the HSDB"); 
          return;
       }
       var xmlhttp = new ActiveXObject ("msxml2.XMLHTTP");
       var strToken = Application.CustomProperties.item("logonToken").value;
	var strURL = objAppProps.item("HSDB").value;
       xmlhttp.open("POST",strURL + "course_choose?token=" + strToken, false);
       xmlhttp.send("") //no data to send
       var xmlDoc = new ActiveXObject("Msxml2.DOMDocument");
       xmlDoc.async = false;
       if (!xmlDoc.loadXML(xmlhttp.responseText)){
	           Application.Alert("Courses were not successfully loaded in the Chooser");    
	           return; 
	      }   
	      var nodStatus = xmlDoc.documentElement.selectSingleNode("STATUS");
	      if (!(nodStatus && nodStatus.text == "00" )) {
	          TuftsErrHandle( nodStatus.text );
           Application.Alert("The Course List request to the Health Sciences Database failed.");
           return;          
       } else {
           // Retrieved the XML successfully
           UpdateToken(xmlDoc.documentElement.selectSingleNode("TOKEN").text); 
	   var ndlCourseList = xmlDoc.documentElement.selectNodes("COURSE"); 
           if ( ndlCourseList == null ) {
               var strError="You do not currently have permissions to write to any courses.\n";
               strError += "Please contact your administrator.";
               Application.Alert(strError); 
               return; 
          } else {
	       // Retrieve the XML CourseList
	       // Store the XML within the strXML variable
	       // as an Application Level Custom Property called "CourseList"
               var strXML = "<COURSES>"
               for ( var x = 0 ; x < ndlCourseList.length; x++ ) {
                   strXML += ndlCourseList.item(x).xml;
               }
	       strXML +="</COURSES>"; 
	       try {
	           if ( strXML !=null && strXML != "" ) objAppProps.Add("CourseList", strXML);
	       } catch (e) {
		   var strErr = "The Course List\n";
		   strErr += " was not successfully populated.\n";
		   strErr += "Please contact your administrator.";
		   Application.Alert(strErr); 
	       }     
	  }
	 
    }  
  }

  objToken = null; 
  objCourseList=null;
  objAppProps=null;
}

nulSetCourseList(); 

]]></MACRO> 


<!--From login.xmetal-->

<MACRO name="SetLoggedOn" key="" lang="JScript" hide="true"><![CDATA[
function SetLoggedOn () {
	// DESCRIPTION
	// Sets the Application Level Custom Property for 
	// blnLoggedOn
	
	// PSEUDO CODE
	//
	// 1.  Retrieve the LoggedOn custom property
	// 2.  Delete it if it Exists
	// 3.  Create the Custom Property and set the value to false 
	var objAppProps, objLoggedOn;
	var strLoggedOn="blnLoggedOn"; 
	var blnValue = true; 
	
	objAppProps=Application.CustomProperties;
	objLoggedOn = objAppProps.item(strLoggedOn);
	if ( objLoggedOn ) objAppProps.item(strLoggedOn).Delete();
	objAppProps.Add(strLoggedOn, blnValue); 

}

SetLoggedOn(); 
]]></MACRO> 

<MACRO name="SetLoggedOff" key="" lang="JScript" hide="true"><![CDATA[
function SetLoggedOff () {
	// DESCRIPTION
	// Sets the Application Level Custom Property for 
	// blnLoggedOn
	
	// PSEUDO CODE
	//
	// 1.  Retrieve the LoggedOn custom property
	// 2.  Delete it if it Exists
	// 3.  Create the Custom Property and set the value to false 
	var objAppProps, objLoggedOn;
	var strLoggedOn="blnLoggedOn"; 
	var blnValue = false; 
	
	objAppProps=Application.CustomProperties;
	objLoggedOn = objAppProps.item(strLoggedOn);
	if ( objLoggedOn ) objAppProps.item(strLoggedOn).Delete();
	objAppProps.Add(strLoggedOn, blnValue); 

}

SetLoggedOff(); ]]></MACRO> 

<MACRO name="LoadLoginFunctions" key="" lang="JScript" hide="true"><![CDATA[
// NAME
// LoadLoginFuncton
//
// DESCRIPTION
// Loads the Jscript library functions to return Login status and to update
// Login tokens


function blnLoggedIn () {
 // DESCRIPTION
	// Returns the Application Level Custom Property value for 
	// blnLoggedOn
    //
    // The main Login console embedded in Resource Manager will set the 
    // blnLoggedOn Property when the user successfully logs on.
    // This function is used within common HSDB API calls to check
    // whether the user has already logged on.
    
    // 
    // NOTES
    // This function only returns true if the user has logged on 
    // during the current XMetaL session.  It is possible that the 
    // user's session has expired (expired token) therefore, this
    // function does not guarantee that the user is currently connected
    // to the database, only that the user has previously connected to 
    // the database. 
    // 
	// PSEUDO CODE
	//
	// 1.  Retrieve the LoggedOn custom property
	// 2.  If it exists, retrieve its value
	// 3.  Else return false
	
	var strLoggedOn="blnLoggedOn"; 
	var blnValue = false; 
	
	objAppProps=Application.CustomProperties;
	objLoggedOn = objAppProps.item(strLoggedOn);
	if ( objLoggedOn ) blnValue = objAppProps.item(strLoggedOn).value;
    return blnValue; 

}


    

function TuftsErrHandle ( strString ) {
// DESCRIPTION
//
// Return Application Alert messages based on the HSDB Status Token
// 
  switch (strString) { 
     case "01" :
	     Application.Alert("HSDB Server: Missing token.\n Please re-login to the database.");
             Application.Run("SetLoggedOff");
     break; 
     case "02" :
	     Application.Alert("HSDB Server: Invalid token.\n Please re-login to the database.");
             Application.Run("SetLoggedOff");
     break; 
     case "03" :
	     Application.Alert("HSDB Server: Expired token.\n Please re-login to the database.");
             Application.Run("SetLoggedOff");
     break; 
     case "11" :
	     Application.Alert("HSDB Server: Invalid username or password.\n Please re-login to the database.");
             Application.Run("SetLoggedOff");
     break; 
     case "30" :
	     Application.Alert("HSDB Server: Missing username or password.\n Please re-login to the database.");
             Application.Run("SetLoggedOff");
     break; 
     case "31" :
	     Application.Alert("HSDB Server: Invalid username or password.\n Please re-login to the database.");
             Application.Run("SetLoggedOff");
     break; 
     case "32" :
	     Application.Alert("HSDB Server: User does not have permission for this request.");
     break; 
     case "40" :
	     Application.Alert("HSDB Server: Missing Course-Id.\n Please select a Course before performing this action.");
     break; 
     case "41" :
	     Application.Alert("HSDB Server: Invalid Course-Id.\n Please select a Course before performing this action.");
     break; 
     case "50" :
	     Application.Alert("HSDB Server: Missing Content Id.\nPlease select a Collection before performing this action.");
     break; 
     case "51" :
	     Application.Alert("HSDB Server: Invalid Content Id.\nPlease select a Collection before performing this action.");
     break; 
     case "55" :
	     Application.Alert("HSDB Server: The current document is not checked out.\nPlease check out this document before performing this action.");
     break; 
     case "56" :
	     Application.Alert("HSDB Server: No documents are available.\n"); 
     break; 
     case "57" :
	     Application.Alert("HSDB Server: Lack permission to save this document.\n"); 
     break; 
     case "60" :
	     Application.Alert("HSDB Server: Missing XML.\n");
     break; 
     case "61" :
	     Application.Alert("HSDB Server: Invalid XML structure.\n");
     break; 
     case "70" :
	     Application.Alert("HSDB Server: Missing header.\n");
     break; 
     case "80" :
	     Application.Alert("HSDB Server: Missing body.\n");
     break; 
     case "90" :
	     Application.Alert("HSDB Server: Missing a required field.\n");
     break; 
     case "99" :
	     Application.Alert("HSDB Server: Request failed.\n");
     break; 
     default:
	     Application.Alert("HSDB Server: Undefined Error thrown.\n");
     break;
}
}

function UpdateToken(newToken) {
  // DESCRIPTION
  // Updates the Application Level Custom Property for "logonToken"
  if (Application.CustomProperties.item("logonToken") != null)
		    Application.CustomProperties.item("logonToken").Delete();
	  Application.CustomProperties.Add("logonToken",newToken);
}

]]></MACRO> 

</MACROS> 
