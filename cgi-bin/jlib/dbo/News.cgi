package News;
$name = 'Новость';
@ISA = 'DBObject';
use strict qw(subs vars);


sub des_pre_view
{
	my $o = shift;
	
	print '<center><a href="/news.ehtml?id='.$o->{ID}.'">';
	print '<b>',$o->{'zagl'}.'</b>';
	print '</a></center><br>';
	if($o->{'hidden'}){ print '<font color="#ff0000">Новость ещё не проверена!</font><br>'; }
	if($o->{'img'}){ print '<img align=left src="',$o->file_href('img'),'" border=0>'; }
	print '<i>',$o->{'pred'},'</i>';
	
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


sub des_self_view
{
	my $o = shift;
	
	print '<center><b>',$o->{'zagl'}.'</b></center><br>';
	if($o->{'hidden'}){ print '<font color="#ff0000">Новость ещё не проверена!</font><br>'; }
	if($o->{'img'}){ print '<img align=left src="',$o->file_href('img'),'" border=0>'; }
	print '<i>',$o->{'pred'},'</i>';
	print '<br><br>',$o->{'ntext'},'<br>';
	
}

sub props
{
	my %props = (

		'img'	  => { 'type' => 'file', 'mime' => 'image/jpeg', 'msize' => 1024*500, 'ext' => '.jpg', 'name' => 'Картинка' },
		'zagl'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Заголовок' },
		'pred'	  => { 'type' => 'text', 'name' => 'Предисловие' },
		'ntext'	  => { 'type' => 'text', 'name' => 'Новость' },
		'inst'	  => { 'type' => 'string', 'length' => 50, 'name' => 'Источник' },
		'ndate'	  => { 'type' => 'date', 'name' => 'Дата' },
		'hidden'  => { 'type' => 'checkbox', 'name' => 'Скрыть' },
		'creby'   => { 'type' => 'int', 'name' => 'UID пользователя' }
	);

	return %props;
}

sub name
{
	my $o = shift;
	
	return $o->{'zagl'}?$o->{'zagl'}:$o->SUPER::name();
}

sub new
{
	my $o = {};
	bless($o);

	$o->_construct(@_);

	return $o;
}

sub DESTROY
{
	my $o = shift;
	$o->SUPER::DESTROY();
}

return 1;