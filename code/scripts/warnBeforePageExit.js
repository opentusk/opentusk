function determineOriginalContent(textareaContent, textareaName)
{
    // Always get most up-to-date content of the note 
    window.content_original[textareaName] = textareaContent;
}
window.onbeforeunload = confirmExit;
function confirmExit(e)
{ 
    if (window.save_button_clicked == true) {
        return;
    }
    for (var textareaName in window.content_original)
    {
        var temporaryContent;
        if (document.myForm[textareaName] === undefined || document.myForm[textareaName] === null) {
          temporaryContent = document.getElementsByName(textareaName)[0].innerHTML;
        }
        else { 
          temporaryContent = document.myForm[textareaName].value;
        }

        if (window.content_original[textareaName] !== temporaryContent) {
          window.content_changed = true;
          break;
        }
    }
    if (window.content_changed != true) {
        return;
    }

    e = e || window.event;

    var message = 'Some of the notes weren\'t saved. Please click on \'Save Notes\' for any changes to take effect.';

    if (e) {
        e.returnValue = message;
    }
    window.content_changed = false;
    return message;
}

function initializeTextareaVariables()
{
    if (typeof window.content_changed == 'undefined') {
        window.content_changed = false;
    };
    if (typeof window.content_original == 'undefined') {
        window.content_original = new Object();
    };
}
