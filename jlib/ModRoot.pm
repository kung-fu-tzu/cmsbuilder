package ModRoot;
use strict qw(subs vars);

our $name = 'Раздел модулей';
our $page = '/page';
our $pages_direction = 1;
our $add = '*';
our @ISA = 'JDBI::Array';
our $icon = 1;

our %props = (
    'name'    => { 'type' => 'string', 'length' => 50, 'name' => 'Название' }
);

sub DESTROY
{
    my $o = shift;
    $o->SUPER::DESTROY(@_);
}

sub elem_paste
{
    my $o = shift;
    
    my $ret = $o->SUPER::elem_paste(@_);
    
    my $to = $o->elem($o->len());
    $to->{'PAPA_CLASS'} = '';
    $to->{'PAPA_ID'} = '-1';
    
    return $ret;
}

sub admin_add
{
    my $o = shift;
    my $c;
    
    print '
    <br><br>
    <table><tr>
    <td valign="top">Добавить:</td><td>';
    
    if($o->access('a')){
	
	for $c (@JDBI::modules){
	    if(${$c.'::one_instance'}){ next }
	    print '<img align="absmiddle" src="',$c->admin_icon(),'">&nbsp;&nbsp;<a href="right.ehtml?url=',$o->myurl(),'&act=adde&cname=',$c,'">',${$c.'::name'},'</a><br>';
	}
    }
    print '</td></tr></table><br>';
}

sub access
{
    my $o = shift;
    my $type = shift;
    if($type eq 'r' or $type eq 'x'){ return 1; }
    return $o->SUPER::access($type,@_);
}

sub type { return 'ModRoot'; }

return 1;