#!/usr/bin/perl

if($ENV{REDIRECT_STATUS} eq ""){
	print "Content-type: text/html\n\n";
	print "Redirect status.";
	exit();
}
$phtml::root = $ENV{DOCUMENT_ROOT};



$phtml::file = $ENV{PATH_TRANSLATED};
$phtml::file =~ s/\\/\//g;

if($phtml::file eq ""){
	print "Content-type: text/html\n\n";
	print "Empty.";
	exit();
}

if($phtml::file =~ /[^A-Za-z0-9\._\/\:]/){
	print "Content-type: text/html\n\n";
	print "Wrong char.";
	exit();
}

if($phtml::file !~ /.phtml$/){
	print "Content-type: text/html\n\n";
	print "Wrong extension.";
	exit();
}

if($phtml::file !~ /^$phtml::root/){
	print "Content-type: text/html\n\n";
	print "Wrong path.";
	exit();
}

if(not open(F, "< $phtml::file")){
	print "Content-type: text/html\n\n";
	print "ERROR open $phtml::file.";
	exit();
}


##############################################

	use DBI;
	use CGI;
	use CGI qw/param/;
	require "../lib/jlogin.txt";

	if( not $dbh = DBI->connect("DBI:mysql:webwork", "root", "pas") ){
		print "Content-type: text/html\n";
		print "Pragma: no-cache\n";
		print "Expires: 0\n";
		print "\n";
		print DBI::errstr;
		exit();
	}

	$jlogin = JLogin::new($dbh);


##############################################

$phtml::document = join("", <F>);
close F;

$phtml::dir = $phtml::file;
$phtml::dir =~ s/\/[^\/]*$//;
chdir $phtml::dir;

@phtml::inits = ();
@phtml::codes = ();
@phtml::htmls = ();
@phtml::incnames = ();


while($phtml::document =~ m/<\?perlinclude((?:.|\n)*?)\?>/){

	$phtml::document =~ s/<\?perlinclude((?:.|\n)*?)\?>/&phtml::read($1)/ige;

}



$phtml::document1 = $phtml::document;
$phtml::document1 =~ s/<\?perlinit((?:.|\n)*?)\?>/push(@phtml::inits,$1);/ige;
undef $phtml::document1;
$phtml::document =~ s/<\?perlinit((?:.|\n)*?)\?>//gi;



@phtml::htmls = split(/<\?perl(?:.|\n)*?\?>/i, $phtml::document);

$phtml::document1 = $phtml::document;
$phtml::document1 =~ s/<\?perl((?:.|\n)*?)\?>/push(@phtml::codes,$1);/ige;
undef $phtml::document1;



$phtml::initcode = join(";",@phtml::inits);

print "Pragma: no-cache\n";
print "Expires: 0\n";

$phtml::is = 1;

if( $phtml::initcode eq "" ){

		print "Content-type: text/html\n";
		print "Pragma: no-cache\n";
		print "Expires: 0\n";
		print "\n";
}

if($phtml::initcode){eval $phtml::initcode;}




$phtml::blocks = ($#phtml::htmls > $#phtml::codes) ? $#phtml::htmls : $#phtml::codes;

$phtml::perldoc = "";

srand;
$phtml::rand = rand();
$phtml::rand =~ s/\D//;
$phtml::rand = "RAND_" . $phtml::rand;

for($phtml::i=0; $phtml::i<=$phtml::blocks; $phtml::i++){

	$phtml::html = $phtml::htmls[$phtml::i];

	while( 	$phtml::html =~ /$phtml::rand/ ){

		$phtml::rand = rand();
		$phtml::rand =~ s/\D//;
		$phtml::rand = "RAND_" . $phtml::rand;
	}

	$phtml::html = 	"\n\$phtml::temp = <<\'$phtml::rand\';\n".
			$phtml::html . "\n$phtml::rand\n\n".
			"chomp(\$phtml::temp); print \$phtml::temp;\$phtml::temp = '';\n";


	$phtml::perldoc .= $phtml::html . $phtml::codes[$phtml::i];

}


#print ( eval $phtml::perldoc);
eval $phtml::perldoc;
print $@ if $@;



sub phtml::read
{
	my $inc = shift;
	my $file = "";
	my $i;

	$inc =~ s/(^\s+)|(\s+$)//;
	$inc =~ s/[\\\/]$//;

	if( $inc =~ m/[\<\>\|\;\:]/ ){ return "ERROR INCLUDING: name \"$inc\""; }


	for($i=0;$i<=$#phtml::incnames;$i++){
		if($phtml::incnames[$i] eq $inc){ return "ERROR INCLUDING: loop \"$inc\""; }
	}
	push(@phtml::incnames,$inc);


	if( not open(F, "< $inc") ){ return "ERROR INCLUDING: open \"$inc\""; }
	$file = join("",<F>);
	close F;

	return $file;
}






