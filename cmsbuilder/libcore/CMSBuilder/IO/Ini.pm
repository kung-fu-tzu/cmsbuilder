# (с) Леонов П.А., 2005

package CMSBuilder::IO::Ini;
use strict qw(subs vars);

our %fnames;

sub new
{
	my $class = shift;
	my $fname = shift;
	
	my $o = {};
	bless($o,$class);
	
	if($fname){ $o->cread($fname); }
	
	return $o;
}

sub cread
{
	my $o = shift;
	my $fname = shift;
	my($f,$str,$var,$val);
	
	open($f,$fname); # or print STDERR 'CMSBuilder::IO::Ini::cread open(<) != 1, $fname = '.$fname;
	while($str = <$f>)
	{
		($var,$val) = split(/=/,$str,2);
		chomp($val);
		$o->{$var} = $val;
	}
	close($f);
	
	$fnames{$o} = $fname;
	
	return 1;
}

sub cwrite
{
	my $o = shift;
	my($fname,$f,$key);
	
	$fname = $fnames{$o};
	
	unless(keys %$o){ unlink($fname); return; }
	
	open($f,'> '.$fname) or print STDERR 'CMSBuilder::IO::Ini::cwrite open(>) != 1, $fname = '.$fname;
	for $key (keys(%$o))
	{
		print $f $key,'=',$o->{$key},"\n";
	}
	close($f);
}

sub DESTROY
{
	my $o = shift;
	$o->cwrite();
}


return 1;







