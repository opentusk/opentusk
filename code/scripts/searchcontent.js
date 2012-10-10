function update_parent(layer,id){
       		var pk ;
	        if (layer == 'searchdiv'){
        	        pk = layers[layer].structure.data[id].content_id;
%			 if (defined ($ARGS{'parent'})){
%				print OUT $ARGS{parent}; 
%				} else {
%				print OUT "var foo";
%				}
			   = pk;
%			 if ($ARGS{'parentlayer'}) {
				add('searchdiv',id,'<% $ARGS{'parentlayer'} %>')
%			}			
			opener.window.focus();
		}
}
	
function view(layer, id){
		location.href = '/view/content/' + layers[layer].structure.data[id].content_id;
}
