package design;
use strict qw(subs vars);


sub page
{


	my $obj = eml::param('obj');

	my $to = DBObject::url($obj);

	$to->des_page();

}


return 1;






