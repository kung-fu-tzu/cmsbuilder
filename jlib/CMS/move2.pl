sub move2
{
	my $act = shift;
	my $url = param('url');
	my $uto = param('to');
	my $enum = param('enum');
	my $e_shcut;
	
	my $from = url($url);
	my $elem = $from->elem($enum);
	
	unless($from->access('w')){ $from->err_add('У Вас нет разрешения изменять этот элемент.'); return; }
	unless($elem->access('w')){ $from->err_add('У Вас нет разрешения изменять перемещаемый элемент.'); return; }
	
	if($uto){
		
		my $to = url($uto);
		unless($to->access('a')){ $from->err_add('У Вас нет разрешения добавлять в элемент назначения.'); return; }
		
		if($act eq 'move2'){
			
			unless($to->elem_can_paste($elem)){ return; }
			
			$elem = $from->elem_cut($enum);
			$to->elem_paste($elem);
		}
		elsif($act eq 'mkshcut'){
			
			$e_shcut = $elem->shcut_cre();
			unless($to->elem_can_paste($e_shcut)){
				$e_shcut->del();
				return;
			}
			$to->elem_paste($e_shcut);
			$e_shcut->shcut_save();
		}
		
		return;
	}
	
	sess()->{'admin_refresh_left'} = 0;
	$do_list = 0;
	
	my $eclass = ref($elem);
	
	if($act eq 'move2'){
		print 'Выберите раздел, в который переместить элемент: <b>',$elem->admin_pname(),'</b>.<br><br>';
	}
	elsif($act eq 'mkshcut'){
		print 'Выберите раздел, в котором создать ярлык для: <b>',$elem->admin_pname(),'</b>.<br><br>';
		$e_shcut = $elem->shcut_cre(1);
	}
	
	my $count = 0;
	
	my $c;
	for $c (@JDBI::classes,@JDBI::modules){
		
		unless( $c->elem_can_add($eclass) ){ next; }
		
		my $d;
		for $d ($c->sel_where(' 1 ')){
			
			if($act eq 'move2'){
				unless($d->elem_can_paste($elem)){ next; }
			}elsif($act eq 'mkshcut'){
				unless($d->elem_can_paste($e_shcut)){ next; }
			}
			
			unless($d->access('a')){ next; }
			
			print $d->admin_name('?act='.$act.'&url='.$from->myurl().'&to='.$d->myurl().'&enum='.$enum),'<br>';
			$count++;
		}
	}
	
	unless($count){ print '<center><b>Нет разделов для отображения.</b></center>'; }
}

1;