#!/usr/bin/perl
use strict qw(subs vars);
use utf8;

require CMSBuilder::Object::Interface;
my $to = {};
bless $to, 'CMSBuilder::Object::Interface';

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->create;
die if defined $to->load;
die if defined $to->save;
die if defined $to->delete;
die if defined $to->destroy;

die if defined $to->copy;
die if defined $to->copy_to;

die if defined $to->props;

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->class_all;
die if defined $to->class_count;

die if defined $to->class_name;
die if defined $to->name;

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->url;
die if defined $to->abs_url;
die if defined $to->id;
die if defined $to->script_id;

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->papa;
die if defined $to->papa_set;
die if defined $to->papa_n;
die if defined $to->papa_path;
die if defined $to->papa_is;

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->owner;
die if defined $to->owner_set;
die if defined $to->access;

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->child_len;
die if defined $to->child_get;
die if defined $to->child_all;
die if defined $to->child_all_flat;
die if defined $to->child_interval;

die if defined $to->child_index;
die if defined $to->child_type;
die if defined $to->child_is;

die if defined $to->child_can;
die if defined $to->child_paste;
die if defined $to->child_cut;

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->event_call;
die if defined $to->event_reg;
die if defined $to->event_unreg;


#———————————————————————————————————————————————————————————————————————————————

die if defined $to->rpc_can;
die if defined $to->rpc_call;


1;