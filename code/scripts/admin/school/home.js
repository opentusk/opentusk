// Copyright 2012 Tufts University 
//
// Licensed under the Educational Community License, Version 1.0 (the "License"); 
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
//
// http://www.opensource.org/licenses/ecl1.php 
//
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and 
// limitations under the License.


function toggleSchool(link, obj) {
    if ($('#' + link).css("display") == "none") {
        $('#' + link).show();
    } else {
        $('#' + link).hide();
    }
}

function toggleAllSchools(num, obj, prefix) {
    var currImgSrc = $(obj).children('img').attr('src');
    var expandImg = '/graphics/down.gif';
    var collapseImg = '/graphics/up.gif';
    var toggle = 'block';

    if (currImgSrc.contains(expandImg)) {
        $(obj).children('img').attr( 'src', collapseImg );
    } else if (currImgSrc.contains(collapseImg)) {
        toggle = 'none';
        $(obj).children('img').attr( 'src', expandImg );
    }

    for (i = 0; i < num; i++) {
        $('#' + prefix + '_' + i).css('display', toggle);
    }
}

