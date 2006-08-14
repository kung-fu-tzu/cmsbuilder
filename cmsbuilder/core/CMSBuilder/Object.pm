# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Object;
use strict qw(subs vars);
use utf8;

use CMSBuilder;
use CMSBuilder::Object::Interface;

our @ISA = qw(CMSBuilder::Object::Interface);

sub create				{undef}
sub load				{undef}
sub save				{1}
sub delete				{1}
sub destroy				{1}

sub class_all			{()}
sub class_count			{0}

sub class_name			{ref($_[0]) || $_[0]}
sub name				{$_[0]->class_name . ' без имени'}

#sub url					{}
#sub abs_url				{}
#sub id					{}
#sub script_id			{}

sub copy				{undef}
#sub copy_to				{}

sub props				{{}}

sub papa				{undef}
sub papa_set			{1}
#sub papa_n				{}
sub papa_path			{$_[0]}
sub papa_is				{0}

sub owner				{undef}
sub owner_set			{1}
sub access				{1}

sub child_len			{0}
sub child_get			{undef}
#sub child_all			{}
#sub child_all_flat		{}
#sub child_interval		{}

#sub child_num			{}
#sub child_pname			{}
#sub child_is			{}

#sub child_can			{}
sub child_paste			{undef}
sub child_cut			{undef}

#sub event_call			{}
sub event_call 			{ return cmsb_event_call(@_) }
sub event_reg			{ my $o = shift; $_[2] ||= ref $o; return cmsb_event_reg(@_) }
sub event_unreg			{ my $o = shift; $_[2] ||= ref $o; return cmsb_event_unreg(@_) }

#sub rpc_can				{}
#sub rpc_call			{}


1;