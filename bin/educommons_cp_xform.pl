#! /usr/bin/perl

use strict;

use FindBin qw($Bin);
use Archive::Zip; 
use XML::Twig;
use File::Path;
use Data::Dumper;


#####
# Get options
use Getopt::Long;
my ($cp_file, $save_tmp_dir, $get_help);
$save_tmp_dir = 0;

my $GetOptResult = GetOptions("archive=s" => \$cp_file,
                              "keep_tmp"  => \$save_tmp_dir,
                              "help"      => \$get_help);

printHelp($cp_file, $save_tmp_dir, $get_help);


#####
# extract archive passed in by user
my $zip = Archive::Zip->new();
unless($zip->read( $cp_file ) == 'AZ_OK'){
	# write to error log? die?
	die "read error: could not read contents of archive: $cp_file";
}


#####
# make tmp file with random number. put this in global var and use that as dir for adds
my $home = $ENV{'HOME'} || $ENV{'LOGDIR'} || (getpwuid($<))[7] || die "You're homeless!\n";

my $tmp_dir;
do{
	my $randNum = int(rand(10000));
	$tmp_dir = "$home/tmp_$randNum";
} while(-e $tmp_dir);

print "creating tmp directory for content package: ";
eval { mkpath($tmp_dir, 1, 0775) };
if($@){
	die "couldn't create directory $tmp_dir: $@\n";
}


#####
# place contents of content package into $tmp_dir
# check for success
unless($zip->extractTree('', "$tmp_dir/") == 'AZ_OK'){
	die "could not extract contents of $cp_file";
}


#####
# generate new files and place in tmp dir
my $twig = XML::Twig->new( );
$twig->parsefile( "$tmp_dir/imsmanifest.xml" );

my @item_elts = $twig->get_xpath('/manifest/organizations/organization/item[@identifier="content"]/item[@isvisible="true"]');

genCourseHome(\@item_elts, $twig);

my %generated_content;

# get all resources and loop through them - generating appropriate
# html files for all content types except URL's and the hscml.css
# file that gets included as a resource if we have TUSKdocs or
# XMetal docs in package.
my @resources = $twig->get_xpath('/manifest/resources/resource');
foreach my $resource (@resources){
	my $file = $resource->first_child('file');
	my $fn = '';
	$fn = $file->{att}->{href} if $file;	

	my $tuskType = getTuskType($resource);

	if($tuskType =~ /Collection|Multidocument/){
		# generate a resource that is an html page with contents of coll as links
		my $id = $resource->{'att'}->{'identifier'};
		my ($item) = $twig->get_xpath('/manifest/organizations/organization//item[@identifierref="' . $id . '"]');
		genCollectionHTML($item, $twig, \%generated_content);
	}
	elsif($tuskType eq 'Document') {
		# take the XML from TUSK content table and transform it into html page
		xFormDocXML($resource, $fn, \%generated_content, $twig);
	}
	elsif($tuskType ne 'URL' && $tuskType ne 'CSS'){ 
		genMediaHTML($resource, $fn, \%generated_content);
	}
}

# we need to generate a few html pages based upon metadata
my @classification_elts = $twig->get_xpath('/manifest/metadata/lom/classification');
genObjectivePage(@classification_elts) if scalar(@classification_elts);

my @roles = $twig->get_xpath('/manifest/metadata/lom/lifecycle/contribute');
genFacultyPage(@roles)	if scalar(@roles);

my ($tusk_root) = $twig->get_xpath('/manifest/metadata/tusk');
genMetaPages($tusk_root);

$twig->purge();


#####
# retrieve imsmanifest, transform, and place into tmp dir
use XML::LibXSLT;
use XML::LibXML;

my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();

my $source = $parser->parse_file("$tmp_dir/imsmanifest.xml");
my $style_doc = $parser->parse_file("$Bin/../code/XSL/Course/educommons_cp_xform.xsl");

my $stylesheet = $xslt->parse_stylesheet($style_doc);

my $results = $stylesheet->transform($source);

#fh for new manifest
open my $fh, '>', "$tmp_dir/imsmanifest.xml";
print $fh $stylesheet->output_string($results);
close $fh;


#####
# add files from tmp dir to content package archive
my $eduComm_cp = Archive::Zip->new();
unless($eduComm_cp->addTree($tmp_dir, '') == 'AZ_OK'){
	die "Could not add contents of $tmp_dir to new eduCommons content package.";
}


#####
# create content package zip and alert as to its creation and location
my $transformed_cp;
# remove any leading directory path (if exist), capture just the file name - without extension
(my $fn = $cp_file) =~ s/(?:.*\/)?(.+)\.g?zip/$1/;

do{
	my $randNum = int(rand(10000));
	$transformed_cp = $home . '/' . $fn . '_transformed_' . "$randNum.zip";
} while(-e $transformed_cp);


if ($eduComm_cp->writeToFileNamed($transformed_cp) == 'AZ_OK') {
    print "TUSK content package transform successful!\n";
	print "transformed content package is located at: $transformed_cp\n"; 
} else {
    print "Error: could not create transformed content package!\n";
} 


#####
# then confirm either deletion of tmp, or existence and location of it 
unless($save_tmp_dir){
	print "Deleting temp directory and its contents: $tmp_dir.\n";
	rmtree($tmp_dir, 0, 1);
}
else {
	print "OK. tmp directory saved: $tmp_dir\n";
}




#########################
##### BUNCH O'SUBS
#########################


sub genMetadataTable {
	my $datum = shift;

	my @rows = $datum->children('tuskMetaData');
	my $html = '<table border="1" cellpadding="5" cellspacing="0">';

	my @hdrs = $rows[0]->children('tuskMetaData');
	$html .= '<tr valign="top">';
	foreach my $hdr (@hdrs){
		$html .= '<td style="background:#ffcc33;"><strong>' . $hdr->{'att'}->{'title'} . '</strong></td>';
	}
	$html .= '</tr>';

	foreach my $row (@rows){
		my @cols = $row->children('tuskMetaData');

		$html .= '<tr valign="top">';
		foreach my $col (@cols){
			$html .= '<td>' . $col->child_text() . '</td>';
		}
		$html .= '</tr>';
	}
	$html .= '</table>';

	return $html;
}

sub genMetadataList {
	my $datum = shift;

	my $edit_type = '';
	my $title_count;
	foreach my $item ($datum->children('tuskMetaData')){
		$title_count++ if $edit_type ne $item->{'att'}->{'title'};
		$edit_type = $item->{'att'}->{'title'};
	}
	my @items = $datum->children('tuskMetaData');
	my $html = '<ul>';
	foreach my $item (@items){
		$html .= '<li>';
		if($title_count > 1){
			$html .= '<strong>' . $item->{'att'}->{'title'} . '</strong><br/>';
		}

		if($item->{'att'}->{'type'} =~ /text/){
			$html .= $item->child_text();
		}
		elsif($item->{'att'}->{'type'} eq 'table'){
			$html .= genMetadataTable($item);
		}
		$html .= '</li>';
	}
	$html .= '</ul>';

	return $html;
}

sub genMetaPages {
	my $meta_root = shift;
	my @metadata = $meta_root->children();

	foreach my $datum (@metadata){
		my $fn = my $title = $datum->{'att'}->{'title'};
		$fn =~ s/\s/_/g;
		$fn = lc($fn);
		$fn .= '.html';

		my $edit_type = $datum->{'att'}->{'type'};
		my $html;

		if($edit_type eq 'list'){
			$html = genMetadataList($datum);
		}
		elsif($edit_type eq 'table'){
			$html = genMetadataTable($datum);
		}
		elsif($edit_type =~ /text/){    # matches 'text' or 'textarea'
			$html = '<div>' . $datum->first_child('value')->child_text() . '</div>';
		}

		open(my $fh, '>', "$tmp_dir/$fn");
		print $fh $html;
		close $fh;
	}
	
}

sub genFacultyPage {
	my @roles = @_;
	my $html = '<table border="1" cellpadding="5" cellspacing="0"><tr><td style="background:#ffcc33;"><strong>Role</strong></td><td style="background:#ffcc33;"><strong>Name(s)</strong></td></tr>';

	foreach my $elt (@roles){
		my ($role) = $elt->get_xpath('role/value/langstring');
		my @vcards = $elt->get_xpath('centity/vcard');
		my @names;

		$html .= '<tr valign="top"><td>' . $role->child_text() . '</td><td>';
		foreach my $vc (@vcards){
			my @lines = split(/\n/, $vc->child_text());
			foreach my $line (@lines){
				if($line =~ /^fn:\s*(.*)/){
					push(@names, $1);
				}
			}
		}
		$html .= join('<br>', @names);
		$html .= "</td></tr>"; 

	}
	$html .= "</table>";

	open(my $fh, '>', "$tmp_dir/faculty_list.html");
	print $fh $html;
	close $fh;
}

sub genObjectivePage {
	my @classification_elts = @_;
	my $html = '<ul>';

	foreach my $elt (@classification_elts){
		my ($type) = $elt->get_xpath('purpose/value/langstring');

		if($type->child_text() eq 'Educational Objective'){
			my ($obj) = $elt->get_xpath('description/langstring');
			$html .= "<li>" . $obj->child_text() . "</li>"; 
		}
	}
	$html .= "</ul>";

	open(my $fh, '>', "$tmp_dir/objectives.html");
	print $fh $html;
	close $fh;
}


sub genCollectionHTML{

	my ($item, $t, $generated_cont) = @_;
	my $id_ref = $item->{'att'}->{'identifierref'};

	unless($generated_cont->{ $id_ref }){
		$generated_cont->{ $id_ref } = 1;

		my $query = '/manifest/resources/resource[@identifier="' . $id_ref . '"]';
		my ($resource) = $t->get_xpath($query);

		my $fn =  getItemFileName($item);
		my $html = '';

		my ($description) = $resource->get_xpath('metadata/lom/general/description/langstring');
		$description = ($description)? $description->child_text() : undef;

		$html .= "<div>Folder Notes: $description</div>\n" if $description;
		$html .= "<ul>\n";
		my @sub_items;

		# our educommons manifest contains resources that we don't want
		# to present directly to user (such as an image that is referenced by an html file... we 
		# want the html file to be visible, but the image should have vis=false.
		# therefore, when generating html to represent a collection, we only want to grab 
		# subitems that are set to true, unless... (see else block)
		if($item->{'att'}->{'isvisible'} eq 'true'){
			@sub_items = $item->get_xpath('item[@isvisible="true"]');
		}
		else{
		# if the collection is not visible, that means it is linked to from a document content type
		# therefore, none of its subitems are going to be visible either.
		# so, grab all subitems with visibility == false
			@sub_items = $item->get_xpath('item[@isvisible="false"]');
		}
		foreach my $sub_item (@sub_items){
			$html .= genContentLnk($sub_item, $t);
		}
		$html .= '</ul>';
		
		$html .= getFooter($resource);

		open(my $fh, '>', "$tmp_dir/$fn");
		print $fh $html;
		close $fh;
	}
}

sub genMediaHTML{

	my ($resource, $res_fn, $generated_cont) = @_;
	my $id_ref = $resource->{'att'}->{'identifier'};

	unless($generated_cont->{ $id_ref }){
		$generated_cont->{ $id_ref } = 1;

		my ($description) = $resource->get_xpath('metadata/lom/general/description/langstring');
		$description = ($description)? $description->child_text() : undef;

		my $html = '';

		if(getTuskType($resource) =~ /Slide/){
			$html .= "<img src=\"$res_fn\"/>\n";
			$html .= "<div>$description</div>\n" if $description;
		}
		elsif(getTuskType($resource) =~ /Shockwave/){
			my ($width) = $resource->get_xpath('metadata/tom/dimensions/width');
			$width = $width->child_text();

			my ($height) = $resource->get_xpath('metadata/tom/dimensions/height');
			$height = $height->child_text();

			$html =<<EOM;
<object width="$width" height="$height"> 
	<param name="src" value="$res_fn">
	<embed src="$res_fn" class="image" wmode="transparent" width="$width" height="$height">
	</embed>
</object>
EOM
		}
		else {
			$html .= "<div>$description</div>\n" if $description;
			$html .= "<a href=\"$res_fn\">Download Content</a>\n";
		}

		$html .= getFooter($resource);

		(my $fn = $id_ref) =~ s/res(\d+)/$1.html/;
		open(my $fh, '>', "$tmp_dir/$fn");
		print $fh $html;
		close $fh;
	}

}

sub xFormDocXML{
	my ($resource, $file, $generated_cont, $twig) = @_;
	my $id_ref = $resource->{'att'}->{'identifier'};

	unless($generated_cont->{ $id_ref }){
		$generated_cont->{ $id_ref } = 1;

		my $doc_xml = XML::Twig->new( );
		$doc_xml->parsefile( "$tmp_dir/$file" );

		my ($html) = $doc_xml->get_xpath('/originalXML');
		$html = ($html)? $html->child_text() : '';		

		$html .= printHSCMLScript();

		#sub out TUSK type calls to img src's and hrefs
		$html =~ s/\/view\/content\/(\d+)/xFormTuskLnk($1, $generated_cont, $twig)/eg;
		$html =~ s/src="\/.*?\/(\d+)"/xFormTuskImg($1)/eg;
 
		$html .= getFooter($resource);

		(my $fn = $file) =~ s/(\d+)\.xml/$1.html/;

		#fh for new manifest
		open my $fh, '>', "$tmp_dir/$fn";
		print $fh $html;
		close $fh;
	}

}

sub getTuskType{
	my $r = shift;
	my ($type) = $r->get_xpath('metadata/tom/tuskType');
	if($type){
		return $type->child_text();
	}
	else {
		return '';
	}
}

sub genCourseHome{
	my ($items, $twig) = @_;
	
	my $html = "<ul>\n";
	foreach my $it (@$items){
		$html .= genContentLnk($it, $twig);
	}
	$html .= "</ul>";

	open(my $fh, '>', "$tmp_dir/course_home.html");
	print $fh $html;
	close $fh;
}




sub getItemTitle {
	my $item = shift;

	my $id = $item->{'att'}->{'identifierref'};
	my $content_id = substr($id, 3);
	
	my $title = $item->first_child('title');
	$title = ($title)? $title->child_text() : $content_id;
	return $title;
}

sub getItemFileName {
	my $item = shift;

	my $id = $item->{'att'}->{'identifierref'};
	my $content_id = substr($id, 3);

	my $file = "$content_id.html";

	return $file;
}

sub genExtContLnk {
	my ($resource, $title) = @_; 

	my $url = $resource->{att}->{href};

	return "<a href=\"$url\" target=\"_blank\">$title</a>";
}

sub genContentLnk {
	my ($item, $twig) = @_; 

	my $title = getItemTitle($item);

	my $id = $item->{att}->{identifierref};
	my ($resource) = $twig->get_xpath('resources/resource[@identifier="' . $id . '"]');
	my $file = $resource->first_child('file');
	
	if(getTuskType($resource) eq 'URL'){
		return '<li>' . genExtContLnk($resource, $title) . "</li>\n";
	}
	else {		
		my $filename = getItemFileName($item);
		return "<li><a href=\"$filename\">$title</a></li>\n";
	}

}

sub printHSCMLScript{
	return qq(
<script type="text/javascript">
	window.onload = function(){
		var head = document.getElementsByTagName('head')[0];
		var styleTag = document.createElement('link');
		styleTag.setAttribute('rel', 'stylesheet');
		styleTag.setAttribute('type', 'text/css');
		styleTag.setAttribute('href', 'hscml.css');

		head.appendChild(styleTag);
	}
</script>
);
}

sub getFooter{
	my $resource = shift;

	my ($created) = $resource->get_xpath('metadata/tom/createdTxt');
	$created = ($created)? $created->child_text() : undef;

	my ($modified) = $resource->get_xpath('metadata/tom/modifiedTxt');
	$modified = ($modified)? $modified->child_text() : undef;

	my $html .= <<EOM;

<div>
	<dl style="margin:20px 0 0 0; padding:0;">
	<dt style="float:left; display:block; width:75px; margin:0; padding:0;">Created:</dt>
	<dd style="float:left; display:block; margin-left:0;">$created</dd>
	<dt style="clear:both; float:left; display:block; width:75px; margin:0; padding:0;">Modified:</dt>
	<dd style="float:left; display:block; margin-left:0;">$modified</dd>
	</dl>
</div>
<br style="clear:both;"/>
EOM

	return $html;

}

sub xFormTuskLnk{
	my ($c_id, $generated_content, $twig) = @_;

	my ($res_elt) = $twig->get_xpath('resources/resource[@identifier="res' . $c_id . '"]');
	my ($item_elt) = $twig->get_xpath('/manifest/organizations/organization//item[@identifierref="res' . $c_id . '"]');

    genCollectionHTML($item_elt, $twig, $generated_content) if (getTuskType($res_elt) =~ /Collection|Multidocument/);

	my $file = $res_elt->first_child('file');

	if(getTuskType($res_elt) eq 'URL'){
		return $res_elt->{att}->{href};
	}
	else{
		return "$c_id.html";
	}
}

sub xFormTuskImg{
	my ($c_id) = @_;

	my ($file_elt) = $twig->get_xpath('/manifest/resources/resource[@identifier="res' . $c_id . '"]/file');
	my $href = $file_elt->{'att'}->{'href'};

	return 'src="' . $href . '"';

}

#####
# help sub definition
sub printHelp{
	my ($cp_file, $save_tmp_dir, $get_help) = @_;

	my $archive_str = qq(
    -a[rchive]  : Please specify the full path to a zip file that 
                  represents the TUSK archive you are attempting 
                  to transform with the '-a' flag.
);

	my $xtra_param_str = qq(
    -k[eep_tmp] : In order to create your content package's zip file, a
                  temporary directory is created in your home directory.
                  The script will delete it after creating the zip, 
                  although you can prevent this deletion by passing 
                  the -k argument.

    -h[elp]     : Display help information.
);

	if($get_help)    { print "$archive_str$xtra_param_str\n"; exit; }
	unless($cp_file) { print "$archive_str\n"; exit; }
}
