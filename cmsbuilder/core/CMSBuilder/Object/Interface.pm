# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Object::Interface;
use strict qw(subs vars);
use utf8;

#———————————————————————————————————————————————————————————————————————————————

sub create				{warn if $^W; return}
sub load				{warn if $^W; return}
sub save				{warn if $^W; return}
sub delete				{warn if $^W; return}
sub destroy				{warn if $^W; return}

sub copy				{warn if $^W; return}
sub copy_to				{warn if $^W; return}

sub props				{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub class_all			{warn if $^W; return}
sub class_count			{warn if $^W; return}

sub class_name			{warn if $^W; return}
sub name				{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub url					{warn if $^W; return}
sub abs_url				{warn if $^W; return}
sub id					{warn if $^W; return}
sub script_id			{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub papa				{warn if $^W; return}
sub papa_set			{warn if $^W; return}
sub papa_n				{warn if $^W; return}
sub papa_path			{warn if $^W; return}
sub papa_is				{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub owner				{warn if $^W; return}
sub owner_set			{warn if $^W; return}
sub access				{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub child_len			{warn if $^W; return}
sub child_get			{warn if $^W; return}
sub child_all			{warn if $^W; return}
sub child_all_flat		{warn if $^W; return}
sub child_interval		{warn if $^W; return}

sub child_index			{warn if $^W; return}
sub child_type			{warn if $^W; return}
sub child_is			{warn if $^W; return}

sub child_can			{warn if $^W; return}
sub child_paste			{warn if $^W; return}
sub child_cut			{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub event_call			{warn if $^W; return}
sub event_reg			{warn if $^W; return}
sub event_unreg			{warn if $^W; return}

#———————————————————————————————————————————————————————————————————————————————

sub rpc_can				{warn if $^W; return}
sub rpc_call			{warn if $^W; return}


1;