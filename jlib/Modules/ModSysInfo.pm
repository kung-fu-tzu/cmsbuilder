package ModSysInfo;
use strict qw(subs vars);
use CGI 'param';
our @ISA = 'StdModule';

our $name = '��������� ����������';
our @classes = ();

our $page = '/page';
our $add  = ' ';
our @aview = qw/name dolist/;
our $one_instance = 1;
our $simple = 1;

our %props = (
    'name'    => { 'type' => 'string', 'length' => 50, 'name' => '��������' },
    'dolist'  => { 'type' => 'checkbox', 'name' => '����������' }
);

sub admin_modr
{
    my $o = shift;
    my $act = param('act');
    
    unless($act){ print '������, ������ :) ...'; }
    
    if($act eq 'list_dbocache'){
        
        my $t;
        for $t (keys(%JDBI::dbo_cache)){
            
            print $JDBI::dbo_cache{$t},' -> ',$JDBI::dbo_cache{$t}->name(),'<br>';
            
        }
    }
    
}

sub admin_modl
{
    my $o = shift;
    
    print '����� �������� � ������������� ������ ',$o->name(),'.<br>';
    
    print '<a href="modr.ehtml?url=',$o->myurl(),'&act=list_dbocache" target="admin_right">List DBO Cache</a><br>';
}

sub install_code
{
    my $mod = shift;
    
    my $mr = ModRoot->new(1);
    
    my $to = $mod->cre();
    $to->{'name'} = '����������';
    
    $mr->elem_paste($to);
}

return 1;