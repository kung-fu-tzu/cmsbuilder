
package OML::Test;

$rets = '';

$attr = 'FUCK';

sub out {  $rets .= join('',@_);  }
sub omlh {return main::omlh(@_);}

sub method
{

	out ' ждый охотник желает знать.';
	out '<br>';
	out "<a href='#'>Href</a>";
        out $_[0];
}





return 1;

