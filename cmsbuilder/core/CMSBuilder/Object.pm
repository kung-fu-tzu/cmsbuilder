# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Object;
use strict;
use utf8;

use Carp ();

sub _props {}

#———————————————————————————————————————————————————————————————————————————————

sub _perl_new				{return bless {}, ref($_[0]) || $_[0]}

sub db_name {'default'}
sub dbh
{
	exists $CMSBuilder::dbh_pull{$_[0]->db_name} ? $CMSBuilder::dbh_pull{$_[0]->db_name} : CMSBuilder::make_cached_connection($_[0]->db_name);
}

sub create {goto &_perl_new} #!!!#

sub load
{
	my $c = shift;
	my $id = shift;
	
	my $flds = $c->dbh->load($id,@_) || do { Carp::carp "Can`t load (class: $c, id: $id): '$!'"; return undef };
	
	my $o = $c->_perl_new();
	
	$o->{'ID'} = $id;
	
	$o->{'PAPA'} = $flds->{'PAPA'};
	$o->{'OWNER'} = $flds->{'OWNER'};
	$o->{'CTS'} = $flds->{'CTS'};
	$o->{'ATS'} = $flds->{'ATS'};
	#$o->{'SHCUT'} = $flds->{'SHCUT'};
	
	my $p = $o->props;
	
	#if($o->{'SHCUT'})
	#{
	#	$flds = $o->dbh->load($o->{'SHCUT'},@_);
	#}
	
	#$o->access('r') || do {Carp::carp "No enough permissions: $!"; return undef};
	
	{
		no strict 'refs';
		
		my $vt;
		for my $key (keys %$p)
		{
			$vt = 'CMSBuilder::vtypes::' . $p->{$key}{'type'};
			
			if(${$vt.'::filter'})
			{
				$flds->{$key} = $vt->filter_load($key, $flds->{$key}, $o);
			}
			
			if(${$vt.'::property'})
			{
				$o->{$key . '_real'} = $flds->{$key};
				tie $o->{$key}, 'CMSBuilder::Property', $o, $key;
			}
			else
			{
				$o->{$key} = $flds->{$key};
			}
		}
	}
	
	$o->save if delete $o->{'_save_after_load'};
	
	return $o;
}

sub first				{1} #!!!#
sub last				{1} #!!!#
sub save				{1} #!!!#
sub delete				{1} #!!!#
#sub destroy			{1} #!!!#

sub class				{return ref($_[0]) || $_[0]}

sub class_count			{my $o = shift; return $o->dbh->count($o,@_)}
sub class_all_nums		{my $o = shift; return $o->dbh->nums($o,@_)}
sub class_all_ids		{my $c = shift; return map {"$c$_"} $c->class_all_nums(@_)}
sub class_all			{my $c = shift; return map {$c->load($_)} $c->class_all_nums(@_)}

sub class_name			{$_[0]->class}
#sub name				{$_[0]->class_name . ' без имени'}

sub num					{ref($_[0]) eq 'HASH' ? $_[0]->{'NUM'} : ''}
sub id					{$_[0]->class . $_[0]->num} # этот же код скопирован здесь в class_all_urls()
sub url					{} #!!!#
sub script_id
{
	my $id = $_[0]->id;
	$id =~ s/\W/_/g;
	$id = 'c' . $id unless $id =~ /^[a-zA-Z]/;
	return $id;
}

sub copy				{} #!!!#
#sub copy_to				{} #!!!#

sub props
{
	my $o = shift;
	return {$o->_props(@_)}
}

sub parent				{undef} #!!!#
sub parent_set			{} #!!!#
sub parent_n			{} #!!!#
sub parent_path			{} #!!!#
sub parent_is			{} #!!!#

sub owner				{} #!!!#
sub owner_set			{} #!!!#
sub access				{} #!!!#

sub child_len			{} #!!!#
sub child_get			{} #!!!#
sub child_all			{} #!!!#
sub child_all_flat		{} #!!!#
sub child_interval		{} #!!!#



sub child_can			{} #!!!#
sub child_add			{} #!!!#
sub child_cut			{} #!!!#

# это для папы, все получают объект в первом параметре
sub child_index			{} #!!!#
sub child_type			{} #!!!#
sub child_is			{} #!!!#

# это для дочки, все без параметров
sub son_index			{} #!!!#
sub son_type			{} #!!!#
sub son_is				{} #!!!#

sub event_call 			{ goto &CMSBuilder::cmsb_event_call; }
sub event_reg			{ my $o = shift; $_[2] ||= $o->class; goto &CMSBuilder::cmsb_event_reg; }
sub event_unreg			{ my $o = shift; $_[2] ||= $o->class; goto &CMSBuilder::cmsb_event_unreg; }

sub rpc_can
{
	return $_[0]->can('_cmsb_rpc_' . $_[1]);
}

sub rpc_call
{
	my $o = shift;
	my $func = shift;
	
	$o->rpc_can($func) || Carp::croak("Can`t call RPC func '$func' for " . (ref($o) || $o));
	
	return $o->$func(@_);
}


1;