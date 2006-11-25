# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Object;
use strict;
use utf8;

use CMSBuilder ();
use CMSBuilder::SysUtils;
use Carp ();

no warnings 'redefine';

sub _props {}

#———————————————————————————————————————————————————————————————————————————————

sub _perl_new				{return bless {}, ref($_[0]) || $_[0]}

sub db_name					{warnings::warnif ''; return}
sub dbh						{warnings::warnif ''; return}

sub create					{warnings::warnif ''; return}

sub load					{warnings::warnif ''; return}

sub first					{warnings::warnif ''; return}
sub last					{warnings::warnif ''; return}
sub save					{warnings::warnif ''; return}
sub delete					{warnings::warnif ''; return}
#sub destroy				{warnings::warnif ''; return}

sub class					{warnings::warnif ''; return}

sub class_count				{warnings::warnif ''; return}
sub class_all_nums			{warnings::warnif ''; return}
sub class_all_ids			{warnings::warnif ''; return}
sub class_all				{warnings::warnif ''; return}

sub class_name				{warnings::warnif ''; return}
#sub name					{warnings::warnif ''; return}

sub num						{warnings::warnif ''; return}
sub id						{warnings::warnif ''; return}
sub url						{warnings::warnif ''; return}
sub script_id				{warnings::warnif ''; return}

sub copy					{warnings::warnif ''; return}
#sub copy_to				{warnings::warnif ''; return}

sub props					{warnings::warnif ''; return}

sub parent					{warnings::warnif ''; return}
sub parent_set				{warnings::warnif ''; return}
sub parent_n				{warnings::warnif ''; return}
sub parent_path				{warnings::warnif ''; return}
sub parent_is				{warnings::warnif ''; return}

sub owner					{warnings::warnif ''; return}
sub owner_set				{warnings::warnif ''; return}
sub access					{warnings::warnif ''; return}

sub child_len				{warnings::warnif ''; return}
sub child_get				{warnings::warnif ''; return}
sub child_all				{warnings::warnif ''; return}
sub child_all_flat			{warnings::warnif ''; return}
sub child_interval			{warnings::warnif ''; return}



sub child_can				{warnings::warnif ''; return}
sub child_add				{warnings::warnif ''; return}
sub child_cut				{warnings::warnif ''; return}

# это для папы, все получают объект в первом параметре
sub child_index				{warnings::warnif ''; return}
sub child_type				{warnings::warnif ''; return}
sub child_is				{warnings::warnif ''; return}

# это для дочки, все без параметров
sub son_index				{warnings::warnif ''; return}
sub son_type				{warnings::warnif ''; return}
sub son_is					{warnings::warnif ''; return}

sub event_call 				{ goto &CMSBuilder::cmsb_event_call; }
sub event_reg				{ my $o = shift; $_[2] ||= $o->class; goto &CMSBuilder::cmsb_event_reg; }
sub event_unreg				{ my $o = shift; $_[2] ||= $o->class; goto &CMSBuilder::cmsb_event_unreg; }

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