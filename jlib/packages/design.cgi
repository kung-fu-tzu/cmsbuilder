package design;
use strict qw(subs vars);


sub page
{


	my $obj = eml::param('obj');

	my ($class,$id) = ('','');

	if( $obj !~ m/^(\w+)(\d+)$/ ){ eml::err505('Invalid object requested: '.$obj); }

	$class = $1;
	$id = $2;

	if( ! eml::classOK($class) ){ eml::err505('Invalid class name requested: '.$class); }

	my $to = &{$class.'::new'}($id);

	$to->des_page();

}


return 1;






