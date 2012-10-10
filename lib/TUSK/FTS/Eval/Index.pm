package TUSK::FTS::Eval::Index;

###############################################################
#
# We manupulate the fts_eval tables as some features are not provided
# with the DBIX::FullTextSearch
#
###############################################################
use HSDB4::Constants;
use TUSK::Constants;


sub deleteDocument {
    my ($docid) = @_;
    HSDB4::Constants::set_user_pw($TUSK::Constants::DatabaseUsers->{ContentManager}->{readusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{readpassword});
    my $dbh = HSDB4::Constants::def_db_handle();
    my $arr_ref = $dbh->selectall_arrayref("select id from fts.fts_eval_docid where name = '$docid'");

    if (defined $arr_ref && scalar @$arr_ref > 0) {
	my $list = join(", ", map {$_->[0]} @$arr_ref);
	$dbh->do("delete from fts.fts_eval_data where doc_id in ($list)");
	$dbh->do("delete from fts.fts_eval_docid where id in ($list)");
    }

    HSDB4::Constants::set_db('hsdb4');
}

1;
