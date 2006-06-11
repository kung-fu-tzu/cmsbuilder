# (с) Леонов П.А., 2005

package CMSBuilder::DBI::vtypes::ClassList;
use strict qw(subs vars);
our @ISA = 'CMSBuilder::DBI::VType';
# Список ####################################################

our $filter = 1;

sub table_cre
{
	return " INT(11) ";
}

sub filter_load
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	my $to;
	my $p = $obj->props();
	
	if($val)
	{
		$to = $p->{$name}{'class'}->new($val);
	}
	
	return $to;
}

sub filter_save
{
	my $c = shift;
	my ($name,$val,$obj) = @_;
	
	my $p = $obj->props();
	
	if($val)
	{
		unless(ref($val) eq $p->{$name}{'class'}){ return 0; }
		return $val->{'ID'};
	}
	else
	{
		return 0;
	}
}

sub aview
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	my $cn = $p->{$name}{'class'};
	
	if($p->{$name}{'once'} && $val)
	{
		my $to = $cn->new($val);
		return
		'
		<select disabled>
			<option>'.$to->name().'</option>
		</select>
		';
	}
	
	my $ret = '<select name="'.$name.'">';
	
	unless($val){ $ret .= '<option value="" selected>'.$p->{$name}{'nulltext'}.'</option>'; }
	elsif($p->{$name}{'isnull'}){ $ret .= '<option value="">'.$p->{$name}{'nulltext'}.'</option>'; }
	
	for my $to ($cn->sel_where(' 1 '))
	{
		$ret .= '<option'.($to->{'ID'} == $val->{'ID'}?' selected':'').' value="'.$to->{'ID'}.'">'.$to->name().'</option>';
	}
	
	$ret .= '</select>';
	
	return $ret;
}

sub aedit
{
	my $c = shift;
	my ($name,$val,$obj,$r) = @_;
	
	my $p = $obj->props();
	
	return $obj->{$name} if $obj->props()->{$name}{'once'} && $obj->{$name};
	
	return $p->{$name}{'class'}->new($val);
}

1;