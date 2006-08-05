# (с) Леонов П.А., 2005

package CMSBuilder::Admin;
use strict qw(subs vars);
use utf8;

use CMSBuilder::Admin::CMSObject;
use CMSBuilder::Admin::Fileman;
use CMSBuilder::Admin::RootElement;
use CMSBuilder::Admin::Simple;
use CMSBuilder::Admin::Tree;
use CMSBuilder::Admin::modRoot;
use CMSBuilder::Admin::CMSFront;


#———————————————————————————————————————————————————————————————————————————————


use CMSBuilder;

sub personal_modules() { return grep { $_->isa('CMSBuilder::Admin::RootElement') } cmsb_classes(); }

1;