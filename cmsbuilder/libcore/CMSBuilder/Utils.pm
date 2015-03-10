# (�) ������ �.�., 2005

package CMSBuilder::Utils;
use strict qw(subs vars);
use Digest::MD5;
use POSIX ('strftime');
import POSIX ('locale_h');
use locale;
use Exporter;
our @ISA = 'Exporter';
our @EXPORT =
qw/
&listpms &indexA &NOW &epoch2ts &ts2epoch &toDateTimeStr &toDateStr &toRusDate
&toEngDate &estrftime &rstrftime &varr &HTMLfilter &escape &MD5 &translit
&len2size &round2 &var2f &f2var &array2csv &str2csv &path_it &path_abs &parsetpl
&catch_out
&sendmail
/;


sub catch_out(&)
{
	my $code = shift;
	my($fh,$buff,$io,@ret);
	
	open($fh,'>',\$buff);
	
	my $io = select($fh);
	@ret = &$code;
	select($io);
	
	close($fh);
	
	return wantarray()?($buff,@ret):$buff;
}

sub parsetpl
{
	my $text = shift;
	my $vars = shift;
	
	$text =~ s/\${(\w+)}/$vars->{$1}/ge;
	
	return $text;
}

# ���������� ������ ���� ������ ������� �� ���������
# ���������� (��� ���������� ".pm")
sub listpms
{
	my $dir = shift;
	
	my ($dh,@res);
	
	opendir($dh,$dir);
	while(my $file = readdir($dh))
	{
		unless(-f $dir.'/'.$file){ next; }
		unless($file =~ m/^\w+\.pm$/){ next; }
		
		$file =~ s/\.pm//g;
		push @res, $file;
	}
	closedir($dh);
	
	return @res;
}

# ���� �������� (������ ��������) � ������� (��������� ���������)
# � ���������� ������ ������� ����������
sub indexA($@)
{
	my $val = shift;
	
	for(my $i=$[;$i<=$#_;$i++){ if($_[$i] eq "$val"){ return $i; } }
	
	return $[-1;
}

# ���������� ���� � ������� MySQL TIMESTAMP
sub NOW(){ return strftime('%Y%m%d%H%M%S',localtime()); }

# ����������� ���� � ������� Unix � MySQL TIMESTAMP
sub epoch2ts($){ return strftime('%Y%m%d%H%M%S',localtime($_[0])); }

# ����������� ���� � ������� MySQL TIMESTAMP � Unix
sub ts2epoch($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/;
	return timelocal($6,$5,$4,$3,$2-1,$1-1900);
}

# ����������� ���� � ������� MySQL TIMESTAMP � ������������� ���
# ��������, ��� "20050816174452" ����� "16 ������� 2005 �., 17:44:52"
sub toDateTimeStr($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	my @mnt = qw/������ ������� ����� ������ ��� ���� ���� ������� �������� ������� ������ �������/;
	
	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/;
			#  YYYY1     MM2   DD3   HH4   MM5   SS6	
	
	my $date = "$3 ".$mnt[$2-1]." $1�., $4:$5:$6";
	$date =~ s/^0+//;
	
	return $date;
}

sub toDateStr($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	my @mnt = qw/������ ������� ����� ������ ��� ���� ���� ������� �������� ������� ������ �������/;
	
	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/;
			#  YYYY1     MM2   DD3   HH4   MM5   SS6	
	
	my $date = "$3 ".$mnt[$2-1]." $1�.";
	$date =~ s/^0+//;
	
	return $date;
}

sub toRusDate($)
{
	my $date = shift;
	
	$date =~ s/January/������/i;
	$date =~ s/February/�������/i;
	$date =~ s/March/�����/i;
	$date =~ s/April/������/i;
	$date =~ s/May/���/i;
	$date =~ s/June/����/i;
	$date =~ s/July/����/i;
	$date =~ s/August/�������/i;
	$date =~ s/September/��������/i;
	$date =~ s/October/�������/i;
	$date =~ s/November/������/i;
	$date =~ s/December/�������/i;
	
	$date =~ s/Jan/���/i;
	$date =~ s/Feb/���/i;
	$date =~ s/Mar/���/i;
	$date =~ s/Apr/���/i;
	$date =~ s/May/���/i;
	$date =~ s/Jun/���/i;
	$date =~ s/Jul/���/i;
	$date =~ s/Aug/���/i;
	$date =~ s/Sep/���/i;
	$date =~ s/Oct/���/i;
	$date =~ s/Nov/���/i;
	$date =~ s/Dec/���/i;
	
	$date =~ s/Mon/��/i;
	$date =~ s/Tue/��/i;
	$date =~ s/Wed/��/i;
	$date =~ s/Thu/��/i;
	$date =~ s/Fri/��/i;
	$date =~ s/Sat/��/i;
	$date =~ s/Sun/��/i;
	
	return $date;
}

sub toEngDate($)
{
	my $date = shift;
	
	my $oldlcl;
	eval
	{
		$oldlcl = setlocale(&LC_CTYPE);
		setlocale(&LC_CTYPE,"ru_RU.CP1251");
	};
	
	$date =~ s/������/January/i;
	$date =~ s/�������/February/i;
	$date =~ s/�����/March/i;
	$date =~ s/������/April/i;
	$date =~ s/���/May/i;
	$date =~ s/����/June/i;
	$date =~ s/����/July/i;
	$date =~ s/�������/August/i;
	$date =~ s/��������/September/i;
	$date =~ s/�������/October/i;
	$date =~ s/������/November/i;
	$date =~ s/�������/December/i;
	
	$date =~ s/���/Jan/i;
	$date =~ s/���/Feb/i;
	$date =~ s/���/Mar/i;
	$date =~ s/���/Apr/i;
	$date =~ s/���/May/i;
	$date =~ s/���/Jun/i;
	$date =~ s/���/Jul/i;
	$date =~ s/���/Aug/i;
	$date =~ s/���/Sep/i;
	$date =~ s/���/Oct/i;
	$date =~ s/���/Nov/i;
	$date =~ s/���/Dec/i;
	
	$date =~ s/��/Mon/i;
	$date =~ s/��/Tue/i;
	$date =~ s/��/Wed/i;
	$date =~ s/��/Thu/i;
	$date =~ s/��/Fri/i;
	$date =~ s/��/Sat/i;
	$date =~ s/��/Sun/i;
	
	eval
	{
		setlocale(&LC_CTYPE,$oldlcl);
	};
	
	return $date;
}

sub estrftime
{
	my $val = strftime(@_);
	
	$val = toEngDate($val);
	$val =~ s/\s+/ /g;
	
	return $val;
}

sub rstrftime
{
	my $val = strftime(@_);
	
	$val = toRusDate($val);
	$val =~ s/\s+/ /g;
	
	return $val;
}

sub varr($$@)
{
	my $c = shift;
	my $var = shift;
	my $d = shift;
	my @sv;
	
	for my $pc (reverse @{$c.'::ISA'})
	{
		push(@sv,varr($pc,$var,$d));
	}
	
	if(*{$c.'::'.$var}{'CODE'}){ $d?(unshift(@sv,&{$c.'::'.$var})):(push(@sv,&{$c.'::'.$var})); }
	
	return @sv;
}

sub HTMLfilter($)
{
	my $val = shift;
	
	$val =~ s/\'/\&#039;/g;
	$val =~ s/\"/\&quot;/g;
	$val =~ s/\&/\&amp;/g;
	$val =~ s/</\&lt;/g;
	$val =~ s/>/\&gt;/g;
	
	return $val;
}

sub escape
{
	my $val = shift;
	
	#$val = uri_escape_utf8($val);
	#$val =~ s/(.)/ord($1).' '/ges;
	#$val =~ s/([^\w ])/'\\x'.sprintf('%02x',ord($1))/ges;
	#$val =~ s/([\n\r"'\\])/'\\x'.sprintf('%02x',ord($1))/ges;
	$val =~ s/(["'\\])/\\$1/gs;
	$val =~ s/\s+/ /gs;
	#$val =~ s/\n/\\n/gs;
	#$val =~ s/\r/\\r/gs;
	
	return $val;
}

sub MD5($)
{
	return Digest::MD5::md5_hex($_[0]); #md5_hex md5_base64
}

sub translit($)
{
	my $val = shift;
	$val =~ tr/�����Ũ��������������������������������������������������������/ABVGDEEJZIKLMNOPRSTUFHC4SSQIQEUYabvgdeejziklmnoprstufhc4ssqiqeuy/;
	return $val;
}

sub len2size($)
{
	my $len = shift;
	
	my $kb = 1024;
	my $mb = $kb*1024;
	my $gb = $mb*1024;
	my $tb = $gb*1024;
	
	if($len >= $tb){ return round2($len/$tb).' ��'; }
	if($len >= $gb){ return round2($len/$gb).' ��'; }
	if($len >= $mb){ return round2($len/$mb).' ��'; }
	if($len >= $kb){ return round2($len/$kb).' ��'; }
	return $len.' ����';
}

sub round2($) { return (int($_[0]*10)/10); }


sub var2f
{
	my $val = shift;
	my $fname = shift;
	
	my $fh;
	open($fh,'>',$fname);
	binmode($fh);
	print $fh $val;
	close($fh);
}

sub f2var
{
	my $fname = shift;
	my $pv = $/;
	$/ = undef;
	
	my $fh;
	open($fh,'<',$fname);
	binmode($fh);
	my $val = <$fh>;
	close($fh);
	
	$/ = $pv;
	
	return $val;
}

sub array2csv($$$)
{
	my ($arr,$padw,$padh) = @_;
	my @es = @$arr;
	
	my %ps;
	for my $to (@es)
	{
		map {$ps{$_} = $to->props()->{$_}->{'name'};} $to->aview();
	}
	
	my @psa = keys %ps;
	
	my $csv = "\n" x $padh;
	
	$csv .= ';' x $padw;
	$csv .= '"��������";';
	for my $key (@psa)
	{
		if($key eq 'name'){ next; }
		$csv .= '"'.str2csv($ps{$key}).'";';
	}
	$csv .= "\n";
	
	for my $to (@es)
	{
		$csv .= ';' x $padw;
		$csv .= '"'.str2csv($to->name()).'";';
		for my $key (@psa)
		{
			if($key eq 'name'){ next; }
			$csv .= '"'.str2csv($to->{$key}).'";';
		}
		$csv .= "\n";
	}
	
	return $csv;
}

sub str2csv($)
{
	my $val = shift;
	$val =~ s/\"/\"\"/g;
	return $val;
}

sub path_it
{
	$_[0] =~ s#\\#\/#g;
	$_[0] =~ s#\.\.\/##g;
	$_[0] =~ s#\.\/##g;
	$_[0] =~ s#[^\w\_\/\.\- \(\)]##g;
	$_[0] =~ s#\/+#\/#g;
}

sub path_abs
{
	if($_[0] ne '/')
	{
		$_[0] =~ s#^\/##;
		$_[0] =~ s#\/$##;
		$_[0] = '/'.$_[0];
	}
}

sub sendmail
{
	my %opts = ('ct' => 'text/plain; charset=windows-1251', @_);
	
	my $mess =
"To: $opts{'to'}
From: $opts{'from'}
Subject: $opts{'subj'}
Content-type: $opts{'ct'}

$opts{'text'}";

	my $mail;
	open($mail,'|-','/usr/sbin/sendmail -t') || return 0;
	print $mail $mess;
	close($mail);
	
	return 1;
}

1;