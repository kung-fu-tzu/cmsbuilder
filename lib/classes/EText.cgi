package EText;

local %cols = {};
local $rets = '';

sub new
{
	my $self = {};
	bless($self);

	$self->{"id"} = shift || -1;

	return $self;
}

sub view
{
	my $o = shift;
	out $o->{COL1};
	
}


sub out { $rets .= join('',@_); return 1; }
sub flush { my $rets1 = $rets; $rets = ''; return $rets1; }

return 1;