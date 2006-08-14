#!/usr/bin/perl
use strict qw(subs vars);
use utf8;

require CMSBuilder::Object;
my $to = {};
bless $to, 'CMSBuilder::Object';

#———————————————————————————————————————————————————————————————————————————————

die if undef eq 0 || '' eq 0;
die unless 0 eq 0;

#———————————————————————————————————————————————————————————————————————————————

die if scalar @{[$to->create]} != 1 || defined $to->create;
die if scalar @{[$to->load]} != 1 || defined $to->load;
die unless $to->save;
die unless $to->delete;
die unless $to->destroy;

die if scalar @{[$to->copy]} != 1 || defined $to->copy;
die if $to->copy_to;

die unless ref $to->props eq 'HASH';

#———————————————————————————————————————————————————————————————————————————————

die if defined $to->class_all;
die if !defined $to->class_count || $to->class_count;

die unless $to->class_name eq 'CMSBuilder::Object';
die $to->name unless $to->name eq 'CMSBuilder::Object без имени';

#———————————————————————————————————————————————————————————————————————————————

die if $to->url;
die if $to->abs_url;
die if $to->id;
die if $to->script_id;

#———————————————————————————————————————————————————————————————————————————————

die if scalar @{[$to->papa]} != 1 || defined $to->papa;
die unless $to->papa_set;
die if defined $to->papa_n;
die unless $to->papa_path eq $to;
die if $to->papa_is;

#———————————————————————————————————————————————————————————————————————————————

die if scalar @{[$to->owner]} != 1 || defined $to->owner;
die unless $to->owner_set;
die unless $to->access;

#———————————————————————————————————————————————————————————————————————————————

die unless $to->child_len eq 0;
die if scalar @{[$to->child_get]} != 1 || defined $to->child_get;
die if defined $to->child_all;
die if defined $to->child_all_flat;
die if defined $to->child_interval;

die if defined $to->child_index;
die if defined $to->child_type;
die if defined $to->child_is;

die if defined $to->child_can;
die if scalar @{[$to->child_paste]} != 1 || defined $to->child_paste;
die if scalar @{[$to->child_cut]} != 1 || defined $to->child_cut;

#———————————————————————————————————————————————————————————————————————————————

die if eval { $to->event_call; 1; }; undef $@;
die if defined $to->event_call('not_existed_event_type');

die if eval { $to->event_reg; 1; }; undef $@;
die if eval { $to->event_reg('type'); 1; }; undef $@;
die if eval { $to->event_reg('type',123); 1; }; undef $@;
die unless defined $to->event_reg('type',sub {});
die unless defined $to->event_reg('type','Tests::CMSBuilder::Object::some_func');

die if eval { $to->event_unreg; 1; }; undef $@;
die if eval { $to->event_unreg('type'); 1; }; undef $@;
die if eval { $to->event_unreg('type',123); 1; }; undef $@;
die if $to->event_unreg('type',sub {});
die if $to->event_unreg('type','Tests::CMSBuilder::Object::other_func');

die unless $to->event_unreg('type','Tests::CMSBuilder::Object::some_func');
die if $to->event_unreg('type','Tests::CMSBuilder::Object::some_func');


#———————————————————————————————————————————————————————————————————————————————

die if defined $to->rpc_can;
die if defined $to->rpc_call;


package Tests::CMSBuilder::Object;
sub some_func {}
sub other_func {}


1;