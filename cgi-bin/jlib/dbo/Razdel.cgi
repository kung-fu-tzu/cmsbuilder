package Razdel;
$name = 'Раздел';
@ISA = 'DBArray';
use strict qw(subs vars);

sub props
{
	my %props = (

		'name'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
		'days'	  => { 'type' => 'int', 'name' => 'Дней на стр.' },
		'mdays'	  => { 'type' => 'int', 'name' => 'Дней на главной' },
		'inroot'  => { 'type' => 'checkbox', 'name' => 'Показывать в меню' }
	);

	return %props;
}

sub des_pre_view
{
	my $o = shift;
	print '<br><a href="/razdel.ehtml?id=',$o->{ID},'">',$o->name(),'</a>';
	
}

sub des_tree
{
	my $o = shift;

	my @all;
	my $count = 0;

	unshift(@all,$o->name());

	while($o = $o->papa() and $count < 50){
		$count++;
		unshift(@all, '<a href=/razdel.ehtml?id='.$o->{ID}.'>'.$o->name().'</a>');

	}

	print join(' :: ',@all);

}

sub new
{
	my $o = {};
	bless($o);

	$o->_construct(@_);

	return $o;
}

sub rlist
{
	my $o = shift;
	my $col = 'ID';
	my $i;
	
	$col =~ s/\W//g;

	my @rets;
	my $to;

	for $i ( $o->IDs($col) ){


		$to = new($i);
		#$o->loadr($i);
		
		push @rets, $to;
	}

	return @rets;
}


sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;