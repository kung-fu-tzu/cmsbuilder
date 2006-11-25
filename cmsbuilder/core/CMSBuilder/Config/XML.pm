# CMSBuilder © Леонов П. А., 2005-2006

package CMSBuilder::Config::XML;
use strict;
use utf8;

our @ISA = qw(XML::DOM::Parser);

use XML::DOM;
use XML::DOM::XPath;
use XML::XPathEngine;

our @old_doms;
our $parse_file_name;
our @parse_path;


my $xp = XML::XPathEngine->new;

my $ext_handler = sub
{
	my $filename = shift;
	
	my $dom;
	my $cfg_xml_obj;
	
	eval
	{
		$cfg_xml_obj = CMSBuilder::Config::XML->new;
		$dom = $cfg_xml_obj->parsefile($filename);
	};
	
	if ($@) { warn $@; return; }
	
	$parse_file_name = $filename;
	
	die '$CMSBuilder::Config::cfg is not a HASHref' unless ref $CMSBuilder::Config::cfg eq 'HASH';
	
	cmsb_make($dom->getDocumentElement, $CMSBuilder::Config::cfg);
	unshift @old_doms, $dom;
	return 1;
};


CMSBuilder::Config::config_ext_hook({rex => qr/\.xml$/, sub => $ext_handler});


sub myPath
{
	my $o = shift;
	
	my @path;
	my $node = $o;
	my $iter;
	
	do
	{
		unshift @path, $node->getNodeName;
		die if $iter++ > 50;
	}
	while ($node = $node->getParentNode) && ($node->getNodeName ne '#document');
	
	return join '/', undef, @path;
}

sub cmsb_parceVal
{
	my $node = shift;
	my $val = shift;
	
	$val =~ s/{(.+?)}/cmsb_getPath($node, $1)/ge;
	
	return $val;
}


sub cmsb_getPath
{
	my $node = shift;
	my $path = shift;
	
	local $Carp::CarpLevel = 1;
	
	my $res = $node->findnodes($path);
	Carp::croak "Multiple nodes for $path" if $res->size > 1;
	if ($res)
	{
		return cmsb_parceVal($node, "$res")
	}
	
	my $abs_path = myPath($node);
	
	for (@old_doms)
	{
		next unless my ($old_node) = $xp->findnodes($abs_path, $_->getDocumentElement);
		
		$res = $xp->findnodes($path, $old_node);
		Carp::croak "Multiple nodes for $path" if $res->size > 1;
		
		if ($res)
		{
			return cmsb_parceVal($node, "$res");
		}
	}
	
	Carp::carp "Can`t find path $path in \$val for $abs_path/\$name; file: $parse_file_name";
	return undef;
}


sub cmsb_make
{
	my $node = shift;
	my $hr = shift;
	
	die "node is not a ref" unless ref $node;
	die "hr is not a ref" unless ref $hr;
	
	push @parse_path, $node->getNodeName;
	
	if (my $attrs = $node->getAttributes)
	{
		for (0 .. $attrs->getLength - 1)
		{
			my $attr = $attrs->item($_);
			my $val = $attr->getValue;
			my $name = $attr->getName;
			
			$val = cmsb_parceVal($node, $val);
			
			$hr->{$name} = $val;
		}
	}
	
	my %is_dup_child;
	$hr->{content} = '';
	
	for my $child ($node->getChildNodes)
	{
		my $name = $child->getNodeName;
		
		Carp::croak "Duplicate name '$name'" if exists $is_dup_child{$name};
		
		if ($child->getNodeTypeName eq 'ELEMENT_NODE')
		{
			$hr->{$name} ||= {};
			$is_dup_child{$name} = 1;
			cmsb_make($child, $hr->{$name});
		}
		
		$hr->{content} .= $child->getNodeValue if $child->getNodeTypeName eq 'TEXT_NODE';
	}
	
	pop @parse_path;
}



1;