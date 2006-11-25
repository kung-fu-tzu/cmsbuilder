# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::VTypes;
use strict;
use warnings;
use utf8;

use base qw(Exporter);

our @types;

our @EXPORT = (@types,
qw(
	&attributes &system_attributes
));

BEGIN
{
	@types = qw(string bool datetime mysql_num);
	
	for my $type (@types)
	{
		no strict 'refs';
		my $c = 'CMSBuilder::VTypes::' . $type;
		*{$type} = sub (;@) { ( bless {}, $c )->init(@_) };
	}
}


sub attributes($;$)
{
	my ($attrs, $class) = reverse @_;
	
	my $cn = $class || caller;
	
	no strict 'refs';
	no warnings 'redefine';
	*{$cn . '::attrs'} = sub () { $attrs };
}

sub system_attributes($;$)
{
	my ($attrs, $class) = reverse @_;
	
	my $cn = $class || caller;
	
	no strict 'refs';
	no warnings 'redefine';
	*{$cn . '::sys_attrs'} = sub () { $attrs };
}



package CMSBuilder::VTypes::BaseClass;
use strict;
use warnings;

#use CMSBuilder::SysUtils;

sub _virtual {0}
sub _inits {}
sub _default {undef}

sub init
{
	my $o = shift;
	%$o = ($o->_inits, @_);
	return $o;
}

sub default
{
	my $o = shift;
	if (ref $o->{default} eq 'CODE')
	{
		my $func = $o->{default};
		$o->$func(@_);
	}
	
	return $o->{default} || $o->_default;
}

sub mysql_load {$_[1]} # просто вернем значение

sub mysql_field_check { $_[0]->mysql_field_add; }







package CMSBuilder::VTypes::string;
use strict;
use warnings;

use base qw(CMSBuilder::VTypes::BaseClass);

sub _inits {length => 255};

sub mysql_field_add {'varchar(' . $_[0]->{length} . ')'}





package CMSBuilder::VTypes::bool;
use strict;
use warnings;

use base qw(CMSBuilder::VTypes::BaseClass);

sub mysql_field_add {'tinyint(1)'}





package CMSBuilder::VTypes::datetime;
use strict;
use warnings;

use POSIX 'strftime';

use base qw(CMSBuilder::VTypes::BaseClass);

sub _default {strftime('%Y%m%d%H%M%S', localtime)}
sub mysql_field_add {'datetime'}





package CMSBuilder::VTypes::mysql_num;
use strict;
use warnings;

our @ISA = qw(CMSBuilder::VTypes::BaseClass);

sub mysql_field_add {'int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY'}
sub mysql_field_check {'int(11)'}


1;