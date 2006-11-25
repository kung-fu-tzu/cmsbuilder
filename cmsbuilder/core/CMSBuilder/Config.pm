# CMSBuilder © Леонов П. А., 2005-2006

# Конфигурационный файл со значениями по умолчанию

package CMSBuilder::Config;
use strict;
use utf8;

use warnings::register;
use Exporter;
use Carp ();



our @ext_subs; # ({rex = qr/some regexp/, sub => sub { ... }}, {...}, {...} ...)
our $cfg ||= {};


BEGIN
{
	my $inc_sub = sub
	{
		my (undef, $fn) = @_;  # $coderef is \&my_sub
		
		my $rfn;
		my @my_inc = grep { ! ref $_ } @INC;
		
		for my $hr (grep { $fn =~ $_->{rex} } @ext_subs)
		{
			# выясняем полное имя файла тут,
			# чтобы зря не гонять -f для всех *.pm и *.pl
			unless ($rfn)
			{
				for my $pfx (@my_inc)
				{
					if (-f "$pfx/$fn")
					{
						$rfn = "$pfx/$fn";
						last;
					}
				}
			}
			
			Carp::croak "Can't locate $fn in \@my_inc (\@my_inc contains: @my_inc)" unless $rfn;
			
			#warn $rfn;
			
			if ($hr->{sub}->($rfn))
			{
				my $var = '1';
				open my $fh, '<', \$var;
				return $fh;
			}
		}
	};
	
	@INC = grep { $_ ne $inc_sub } @INC;
	unshift @INC, $inc_sub;
}


sub config_ext_hook
{
	my $hr = shift;
	
	@ext_subs = grep { $_ != $hr } @ext_subs;
	unshift @ext_subs, $hr;
}


sub import
{
	my $c = shift;
	my $req_cfg = $_[0] eq '$cfg' ? shift : undef;
	
	my $pkg = caller;
	
	for my $path (@_)
	{
		my $ref = $cfg;
		my $name;
		
		for (split /\./, $path)
		{
			Carp::croak "Can`t find config path '$path'" unless $ref->{$_};
			$name = $_;
			$ref = $ref->{$name};
		}
		
		Carp::croak "Can`t import not a hash ($ref) '$path'" unless ref $ref eq 'HASH';
		
		no strict 'refs';
		
		for my $key (keys %$ref)
		{
			*{$pkg . '::' . $name . '_' . $key} = \( $ref->{$key} );
			#warn $pkg . '::' . $name . '_' . $key;
		}
	}
	
	no strict 'refs';
	*{$pkg . '::cfg'} = \$cfg if $req_cfg;
}


1;