# (с) Леонов П.А., 2005

package CMSBuilder::DBI::EventsInterface;
use strict qw(subs vars);

sub event_call
{
	my $o = shift;
	my $type = shift;
	
	local $o->{'event_call_cancel'} = 0;
	
	my(@res,$sb);
	
	for my $code (@{$CMSBuilder::oevents{$type}})
	{
		next unless $o->isa($code->{'class'});
		$sb = $code->{'sub'};
		push @res, $o->$sb(@_);
		last if $o->{'event_call_cancel'};
	}
	
	return @res;
}


1;