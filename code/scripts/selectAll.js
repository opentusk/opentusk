var allSelected;
var columnSelected = [];
var rowSelected = [];

$(document).ready(function() {

    function untouchable(cell) {
        return $(cell).find('span#protectedCell').length;
    }

    $("a#selectAll").click(function() {
        var allSelection = allSelected ? allSelected : false;
        allSelected = !allSelection;
        $('#studentassessors > tbody tr').each(function(){
            var columns = $(this).find('td');
            columns.each(function(){
                if (!(untouchable(this))) {
                    var box = $(this).find('input:checkbox');
                    $(box).prop("checked", allSelected);
                } 
                else {
                    var box = $(this).find('input:checkbox');
                    $(box).prop("checked", $(box).prop("checked"));
                }
            });
        });
    });

    $("a#selectRow").click(function() {
        var rowIndex = $(this).closest("tr").index();

        var rowSelection = rowSelected[rowIndex] ? 
            rowSelected[rowIndex] : false;
        rowSelected[rowIndex] = !rowSelection;

        $('#studentassessors > tbody tr').each(function(){
            if ($(this).index() === rowIndex) {
                var columns = $(this).find('td');
                columns.each(function(){
                    if (!(untouchable(this))) {
                        var box = $(this).find('input:checkbox');
                        $(box).prop("checked", !rowSelection);
                    }
                });
            }
        });
    });

    $("a#selectColumn").click(function() {
        var columnIndex = $(this).closest("th").index();
        var columnSelection = columnSelected[columnIndex] ?
            columnSelected[columnIndex] : false;
        columnSelected[columnIndex] = !columnSelection;
        $('#studentassessors > tbody tr').each(function(){
            var columns = $(this).find('td');

            columns.each(function(){
                if ($(this).index() === columnIndex)
                {
                    if (!(untouchable(this))) {
                        var box = $(this).find('input:checkbox');
                        $(box).prop("checked", !columnSelection);
                    }
                }
            });
        });
    });
});