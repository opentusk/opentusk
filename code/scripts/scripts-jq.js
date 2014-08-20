/* utilty functions with jquery */

function toggleLinks(link, obj) {
        if ($('#' + link).css("display") == "none") {
                $('#' + link).css("display", "block");
                $(obj).children('img').attr( "src", "/graphics/icon-nav-open.png" );
        } else {
                $('#' + link).css("display", "none");
                $(obj).children('img').attr( "src", "/graphics/icon-nav-closed.png");
        }
}

