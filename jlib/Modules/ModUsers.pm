package ModUsers;
use strict qw(subs vars);
our @ISA = 'StdModule';

our $name = 'Пользователи';
our @classes = qw/UserGroup User/;

our $page = '/page';
our $pages_direction = 1;
our $add  = ' UserGroup ';
our @aview = qw/name dolist/;
our $icon = 1;
our $one_instance = 1;

our %props = (
    'name'    => { 'type' => 'string', 'length' => 50, 'name' => 'Название' },
    'dolist'  => { 'type' => 'checkbox', 'name' => 'Отображать' }
);

sub install_code
{
    my $mod = shift;
    my($mr,$tm,$tg,$tu);
    $mr = ModRoot->new(1);
    
    $tm = $mod->cre();
    $tm->{'name'} = 'Пользователи';
    $mr->elem_paste($tm);
    
    $tg = UserGroup->cre();
    $tg->{'name'} = 'Администраторы';
    $tg->{'html'}    = 1;
    $tg->{'files'}   = 1;
    $tg->{'cms'}     = 1;
    $tg->{'root'}    = 1;
    $tg->{'cpanel'}  = 1;
    
    $tm->elem_paste($tg);
    
    $tu = User->cre();
    $tu->{'name'} = 'Администратор';
    $tu->{'login'} = 'admin';
    $tu->{'pas'} = 'admin';
    $tg->elem_paste($tu);
    
    
    $tg = UserGroup->cre();
    $tg->{'name'} = 'Гости';
    
    $tm->elem_paste($tg);
    
    $tu = User->cre();
    $tu->{'name'} = 'Гость';
    $tu->{'login'} = '';
    $tu->{'pas'} = '';
    $tg->elem_paste($tu);
    
}

return 1;