
function toggle_visibility(id) {

	var e = document.getElementById(id);


	if(e.style.visibility == "visible"){
		e.style.visibility = "hidden";
	}
	else {
		e.style.visibility = "visible";
	}
}


function toggle_visibility_multiple(id){

    var idlength = id.length;

	var elems = document.getElementsByTagName('tr'); 
	for (var i=0;i<elems.length;i++) {
        var elemsub = elems[i].id.substring(0,idlength); 
		if ( elemsub == id ) {

			if (elems[i].style.display == 'none' ) { // you probably don't want to hide *all* elements
				elems[i].style.display='';
			}
			else {
				elems[i].style.display='none';
			}

		}
	}	

}

function toggle_display(id) {

	var e = document.getElementById(id);
	if( e != null && e.style.display == 'none')
		e.style.display = 'block';
	else
		e.style.display = 'none';
}

function toggle_button(id) {


var e = document.getElementById(id);
  if (e.value == 'Show Answer'){
	e.value='Hide Answer ';

  }
  else {
	e.value = 'Show Answer';
  }

}

function toggle_img(i){

	var fldr = document.getElementById("fldr_"+i);

	if ( (fldr.src).match("minus") ) {
		fldr.src = "/icons/ico-folder-plus.gif";  

	}
	else  {
		fldr.src = "/icons/ico-folder-openminus.gif";

	}

}


function submitform(itemID,isDeck)
{
 
	var sure= confirm("Are you sure you wish to delete?");
	if ( sure == true) {

 		if ( isDeck  == 1) {
 			document.fcardform.deleteDeck.value=itemID;
 		}
 		else {
 			document.fcardform.deleteContent.value=itemID;
 		}

 		document.fcardform.submit();

	}
}

function submitformpc(itemID,cntntID){


	var sure= confirm("Are you sure you wish to delete?");
	if ( sure == true) {

 		if ( cntntID > 0) {
			document.pcform.deleteContent.value=itemID+"/"+cntntID;
 			
 		}
 		else {
			document.pcform.deleteFolder.value=itemID;
 			//document.pcform.deleteContent.value=itemID;
 		}

 		document.pcform.submit();

	}


}


function swapOverlay(imgID)
{
	
	var main_img = document.getElementById(imgID);
  
	if ( main_img.src.match(/overlay/) ) {
		var source=main_img.src.replace(/\/overlay/, "");
	}
    else
	{
		var source = main_img.src.replace(/medium/, "overlay/medium" );
		source=source.replace(/\/large/, "/overlay/large" );
		source=source.replace(/xlarge/, "overlay/xlarge" );
		source=source.replace(/orig/, "overlay/orig" );		
	}
	
	main_img.src = source;
}


function submitnewfolder(formName)
{
	var frm = document.getElementById(formName);
	frm.newfldr.value=1;
	frm.submit();
}

function submitrename(formName,id)
{
	var frm = document.getElementById(formName);
	frm.rnm.value=id;
	frm.submit();
}

function submitnote(formName,id)
{
	var frm = document.getElementById(formName);
	frm.addnote.value=id;
	frm.submit();
}


 function showOrHideHelp() {

       if(document.getElementById('showHideDiv').innerHTML == 'Show') {
         document.getElementById('showHideDiv').innerHTML = 'Hide';
         document.getElementById('helpDiv').style.display = '';
       } else {
         document.getElementById('showHideDiv').innerHTML = 'Show';
         document.getElementById('helpDiv').style.display = 'none';
       }
}
