# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Utils;
use strict;
use utf8;

use Time::Local;
use Encode;
use MIME::Base64 qw(encode_base64 decode_base64);
use Digest::MD5;
use POSIX qw(strftime locale_h);
use locale;

use Exporter;
our @ISA = 'Exporter';

our @EXPORT = qw
(
	&listfiles &listdirs &indexA &integrate_arrays
	&NOW &epoch2ts &ts2epoch &toDateTimeStr &toDateStr &toRusDate
	&toEngDate &estrftime &rstrftime &translit &rus_case
	&HTMLfilter &escape &MD5
	&len2size &round2 &var2f &var2f_utf8 &f2var &f2var_utf8 &array2csv &str2csv &path_it &path_abs &parsetpl
	&catch_out &decode_utf8_hashref &decode_utf8_hash &autoflush
	&sendmail
);

#———————————————————————————————————————————————————————————————————————————————


sub integrate_arrays($$)
{
	my @pat = @{shift()};
	my @arr = @{shift()};
	my @all = @arr;
	
	my @res = map { $_ =~ /^(\d+)$/ ? $all[$1] : $_ } @pat;
	
	@arr = grep { indexA(\@res,$_) < 0 } @arr;
	
	@res = map { /^(\-)?\.$/ ? ($1 ? reverse @arr : @arr) : $_ } @res;
	@res = map { /^(\-)?\*$/ ? ($1 ? reverse @all : @all) : $_ } @res;
	
	return @res;
}

sub rus_case # < 1000, rus_case(n,[0 нет яблок, 1 яблоко, 2-3-4 яблока, х0-5-6-7-8-9 яблок])
{
	my $n = shift;
	my $wds = shift;
	my $z = shift @$wds;
	my $str;
	
	if($n)
	{
		my @pad = qw(2 0 1 1 1 2 2 2 2 2);
		my($h,$d,$e) = split('',sprintf('%03d',$n));
	
		$str = 10 <= $n && $n <= 19 ? $wds->[2] : $wds->[$pad[$e]]
	}
	else
	{
		$str = $z;
	}
	
	return sprintf($str,$n);
}

sub decode_utf8_hashref($)
{
	my $hr = shift;
	return unless ref $hr eq 'HASH';
	
	map { $hr->{$_} = Encode::decode_utf8($hr->{$_}) unless ref $hr->{$_}; } keys %$hr;
	
	return $hr;
}

sub decode_utf8_hash(@)
{
	my $hr = {@_};
	my $nh;
	
	map { $nh->{Encode::decode_utf8 $_} = ref $hr->{$_} ? $hr->{$_} : Encode::decode_utf8 $hr->{$_} } keys %$hr;
	
	return $nh;
}

sub catch_out(&)
{
	my $code = shift;
	
	my $fh;
	my $buff = 'юникод вам';
	open $fh, '>:utf8', \$buff; #:utf8
	#binmode($fh);
	
	my $io = select $fh;
	my @ret = &$code;
	select $io;
	
	close $fh;
	
	return wantarray ? ($buff, @ret) : $buff;
}

sub parsetpl
{
	my $text = shift;
	my $vars = shift;
	
	$text =~ s/\${(.+?)}/$vars->{$1}/ge;
	
	return $text;
}

# Возвращает массив имен поддиректорий из указанной директории
sub listdirs
{
	my $dir = shift;
	
	my ($dh,@res);
	
	opendir($dh,$dir);
	while(my $file = readdir($dh))
	{
		next if $file =~ /^\./;
		push @res, $file if -d $dir . '/' . $file;
	}
	closedir($dh);
	
	return @res;
}

# Возвращает массив имен файлов пакетов из указанной директории
sub listfiles
{
	my $dir = shift;
	my @ext = grep {/^\w+$/} @_;
	
	$dir =~ s/\/+$//;
	
	my ($dh,@res);
	
	opendir($dh,$dir);
	while(my $file = readdir($dh))
	{
		next unless -f $dir . '/' . $file;
		next if $file =~ /^\./;
		next unless grep {$file =~ /\.$_$/} @ext;
		push @res, $file;
	}
	closedir($dh);
	
	return @res;
}

# Ищет значение в массиве и возвращает индекс первого совпадения
sub indexA($$)
{
	my $arr = shift;
	my $val = shift;
	
	for(my $i=$[;$i<=$#$arr;$i++){ if($arr->[$i] eq "$val"){ return $i; } }
	
	return $[-1;
}

# Возвращает дату в формате MySQL TIMESTAMP
sub NOW(){ return strftime('%Y%m%d%H%M%S',localtime()); }

# Преобразует дату в формате Unix в MySQL TIMESTAMP
sub epoch2ts($){ return strftime('%Y%m%d%H%M%S',localtime($_[0])); }

# Преобразует дату в формате MySQL TIMESTAMP в Unix
sub ts2epoch($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	$ts =~ m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/
		or Carp::carp('wrong timestamp for ts2epoch(): ' . $ts);
	return timelocal($6,$5,$4,$3,$2-1,$1);
}

# Преобразует дату в формате MySQL TIMESTAMP в удобочитаемый вид
# Например, для "20050816174452" вернёт "16 августа 2005г., 17:44:52"
sub toDateTimeStr($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	my @mnt = qw/января февраля марта апреля мая июня июля августа сентября октября ноября декабря/;
	
							#    YYYY1     MM2   DD3   HH4   MM5   SS6
	return unless	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/
		or Carp::carp('wrong timestamp for toDateTimeStr(): ' . $ts);
	
	my $date = "$3 " . $mnt[$2 - 1] . " $1г., $4:$5:$6";
	$date =~ s/^0+//;
	
	return $date;
}

sub toDateStr($)
{
	my $ts = shift;
	$ts =~ s/\D//g;
	
	my @mnt = qw/января февраля марта апреля мая июня июля августа сентября октября ноября декабря/;
	
							#    YYYY1     MM2   DD3   HH4    MM5    SS6
	return unless	$ts =~	m/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)?(\d\d)?(\d\d)?$/
		or Carp::carp('wrong timestamp for toDateStr(): ' . $ts);
	
	my $date = "$3 " . $mnt[$2 - 1] . " $1г.";
	$date =~ s/^0+//;
	
	return $date;
}

sub toRusDate($)
{
	my $date = shift;
	
	$date =~ s/January/января/i;
	$date =~ s/February/февраля/i;
	$date =~ s/March/марта/i;
	$date =~ s/April/апреля/i;
	$date =~ s/May/мая/i;
	$date =~ s/June/июня/i;
	$date =~ s/July/июля/i;
	$date =~ s/August/августа/i;
	$date =~ s/September/сентября/i;
	$date =~ s/October/октября/i;
	$date =~ s/November/ноября/i;
	$date =~ s/December/декабря/i;
	
	$date =~ s/Jan/янв/i;
	$date =~ s/Feb/фев/i;
	$date =~ s/Mar/мар/i;
	$date =~ s/Apr/апр/i;
	$date =~ s/May/май/i;
	$date =~ s/Jun/июн/i;
	$date =~ s/Jul/июл/i;
	$date =~ s/Aug/авг/i;
	$date =~ s/Sep/сен/i;
	$date =~ s/Oct/окт/i;
	$date =~ s/Nov/ноя/i;
	$date =~ s/Dec/дек/i;
	
	$date =~ s/Mon/пн/i;
	$date =~ s/Tue/вт/i;
	$date =~ s/Wed/ср/i;
	$date =~ s/Thu/чт/i;
	$date =~ s/Fri/пт/i;
	$date =~ s/Sat/сб/i;
	$date =~ s/Sun/вс/i;
	
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
	
	$date =~ s/января/January/i;
	$date =~ s/февраля/February/i;
	$date =~ s/марта/March/i;
	$date =~ s/апреля/April/i;
	$date =~ s/мая/May/i;
	$date =~ s/июня/June/i;
	$date =~ s/июля/July/i;
	$date =~ s/августа/August/i;
	$date =~ s/сентября/September/i;
	$date =~ s/октября/October/i;
	$date =~ s/ноября/November/i;
	$date =~ s/декабря/December/i;
	
	$date =~ s/янв/Jan/i;
	$date =~ s/фев/Feb/i;
	$date =~ s/мар/Mar/i;
	$date =~ s/апр/Apr/i;
	$date =~ s/май/May/i;
	$date =~ s/июн/Jun/i;
	$date =~ s/июл/Jul/i;
	$date =~ s/авг/Aug/i;
	$date =~ s/сен/Sep/i;
	$date =~ s/окт/Oct/i;
	$date =~ s/ноя/Nov/i;
	$date =~ s/дек/Dec/i;
	
	$date =~ s/пн/Mon/i;
	$date =~ s/вт/Tue/i;
	$date =~ s/ср/Wed/i;
	$date =~ s/чт/Thu/i;
	$date =~ s/пт/Fri/i;
	$date =~ s/сб/Sat/i;
	$date =~ s/вс/Sun/i;
	
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

sub HTMLfilter($)
{
	my $val = shift;
	
	$val =~ s/\&/&amp;/g;
	$val =~ s/\'/&#039;/g;
	$val =~ s/\"/&quot;/g;
	$val =~ s/</&lt;/g;
	$val =~ s/>/&gt;/g;
	
	return $val;
}

sub escape
{
	my $val = shift;
	
	$val =~ s/([\"\'\\])/\\$1/gs;
	$val =~ s/\n/\\n/gs;
	$val =~ s/\r/\\r/gs;
	
	return $val;
}

sub MD5($)
{
	return Digest::MD5::md5_hex($_[0]); #md5_hex md5_base64
}

sub translit($)
{
	my $val = shift;
	
	#my @pairs =
	#qw(
	#	а б в г д е ё ж з и к л м н о п р с т у ф х ц ч ш щ ь
	#);
	
	$val =~ tr/АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯабвгдеёжзийклмнопрстуфхцчшщьыъэюя/ABVGDEEJZIIKLMNOPRSTUFHC4WWQIQEUYabvgdeejziiklmnoprstufhc4wwqiqeuy/;
	
	return $val;
}

sub len2size($)
{
	my $len = shift;
	
    my $max_pow = 8; #т.е. 80
	my @sn = qw(Кб Мб Гб Тб Пб Эб Зб Йб); #qw(Йб Зб Эб Пб Тб Гб Мб Кб)
	
	my $size;
	
	for (reverse 1 .. $max_pow)
	{
        my $sz = 2 ** ($_ * 10);
        
		if ($len >= $sz)
        {
            $size = round2($len / $sz) . ' ' . $sn[$_ - 1];
            $size =~ s/\./,/;
            #warn $size;
            return $size;
        }
    }
	
	return $len . ' ' . rus_case($len, ['байт', 'байт', 'байта', 'байт']);
}

sub round2($) { return ( int( $_[0] * 10 ) / 10); }

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

sub var2f_utf8
{
	my $val = shift;
	my $fname = shift;
	
	my $fh;
	open($fh,'>:utf8',$fname);
	print $fh $val;
	close($fh);
}

sub f2var
{
	my $fname = shift;
	local $/ = undef;
	
	my $fh;
	open($fh,'<',$fname);
	binmode($fh);
	my $val = <$fh>;
	close($fh);
	
	return $val;
}

sub f2var_utf8
{
	my $fname = shift;
	local $/ = undef;
	
	my $fh;
	open($fh,'<:utf8',$fname);
	my $val = <$fh>;
	close($fh);
	
	return $val;
}

sub path_it
{
	my $val = shift;
	
	my $last_slash = $val =~ m/[\\\/]$/;
	
	my @path = grep { $_ !~ /^[.]{1,2}$/ } split /[\\\/]+/, $val;
	
	my $ret = join('/', @path) . ($last_slash ? '/' : '');
	
	#warn "[$val -> $ret]";
	
	return $ret;
}

sub sendmail
{
	my $mess = sendmail_make(@_);
	
	no warnings 'utf8';
	my $mail;
	return open($mail, '|-', '/usr/sbin/sendmail -t') && binmode($mail) && print($mail $mess) && close($mail);
}

sub sendmail_make
{
	my %opts = (ct => 'text/plain', @_);
	
	map { $opts{$_} =~ s/([^\x14-\x7F]+)/base64m($1)/ge; } qw(to from subject); #[^a-zA-Z\.\_\-\@ <>]+
	
	my $mess =
"To: $opts{to}
From: $opts{from}
Subject: $opts{subject}
Content-type: $opts{ct}; charset=utf-8

$opts{'message'}";
	
	return $mess;
}

sub base64m($)
{
	my $str = '=?UTF-8?B?' . encode_base64( encode('UTF-8', $_[0]) ) . '?=';
	$str =~ s/\s//g;
	
	return $str;
}

sub autoflush($)
{
	unless ($_[0])
	{
		Carp::carp 'Undefined param for autoflush()';
		return undef;
	}
	my $fh = select $_[0];
	$| = 1;
	select $fh;
}

1;