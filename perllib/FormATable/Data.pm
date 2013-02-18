package Data;

use strict;
use CGI();

#	CGI input data constructor

sub new 
{
	my $form = new CGI();
	my %Data;
	$ENV{QUERY_STRING} and do
	{ 
		$ENV{QUERY_STRING} =~ s/^([^&]+)(.*)$/$2/;
		$Data{Function} = $1 
	};
	for($form->param) 
	{ unless(/^(x|y)$/i) { $Data{$_} = $form->param($_); $Data{$_} =~ s/\n|\r/ /g } }
	bless \%Data, shift
}

#	return a flag regarding the validation status of the input data

sub valid 
{
	my $Data = shift;
	for(split ',',$Data->{required}) 
	{ 
		unless($Data->{$_} =~ /\S/ )
		{ $Data->{'__validation'} .= "<br>$_ is a required field" }
	}
	$Data->{'__validation'} eq ''					#	valid if no msgs
}

#	CGI input data destructor

sub DESTROY { }

1;
