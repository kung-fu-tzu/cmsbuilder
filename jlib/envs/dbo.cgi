package EML::dbo;

my $w;

sub init
{
	my $dbok = 0;

	for $i (@eml::dbos){

		if($i eq $cook{'class'} ){ $dbok = 1; }
	}
	if( ! $dbok ){ $cook{'class'} = @eml::dbos[0]; }

	$w = &{ $cook{'class'}.'::new' };


}

sub cre
{
	if($_[0] ne 'yes'){ return; }

	my ($i,$j,$is);

	for $i (@eml::dbos){

		$is = 0;

		for $j ($main::dbh->tables()){

			if( lc('`dbo_'.$i.'`') eq lc($j) ){ $is = 1 }
		}

		if(! $is){

			my $oo = &{ $i.'::new' };
			$oo->creTABLE();
			undef $oo;

		}

	}

}

sub types
{

	print "<TABLE style='HEIGHT: 100%;' height='100%' cellSpacing=0 cellPadding=0><tr>";
	print "<td width=150></td><td width=1 bgcolor=#000000></td>";

	my $c;
	my $dbo;
	my $nm;

	for $dbo (@eml::dbos) { 

		$c = '';
		if($dbo eq $cook{'class'}){ $c = ' class=mtypes_s '; }
		else{ $c = ' class=mtypes '; }

		$nm = ${'main::'.$dbo.'::name'};

		print "<td $c>";
		print "<a href=?class=$dbo $emlh>$nm</a> "; 
		print "</td><td width=1 bgcolor=#000000></td>";
	}

	print "</tr></TABLE>";

}

sub action
{

	my $act = shift;
	my $id = shift;
	my $cn = shift;

	if($act eq 'edit'){
		$w->load( $id );
		$w->aedit();
	}

	if($act eq 'adde'){

		if($cn eq ''){ return; }

		$w->load( $id );
		$w->addelem($cn);
	}

}

sub tree
{
	my $id = shift;

	if(! $id){ return; }
	if($id eq 'cre'){ return; }

	print '<br>';
	$w->load($id);
	$w->tree();
	print '<br>';
}

sub list
{
	my $id = shift;

	if($id){

			$w->load($id);
			$w->aview();

	}else{

		print '<br>';
		$w->list();
		print '<br>';

		print '<hr>';
		print "<a href=?ID=cre>�������</a><br><br>";

	}

}

sub in
{
	my $val = shift;
	my @arr = @_;

	my $i;

	for $i (@arr){

		if($i eq $val){ return 1; }
	}

	return 0;
}

return 1;