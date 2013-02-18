package Page;

use strict;

#	create a new Page object instance

sub new 
{
	my($Page,$Form) = @_;
   print STDOUT "Content-type: text/html\n\n"; 	#	print http header
   bless { }, $Page
}

#	restore the previously input values to the page

sub restore {
	my($Page,$data) = @_;
	for('__validation') { $Page->{$_} = $data->{$_} }
	$Page->{template} = &Utl::rdFile('www/FormATable/index.html');
	my($T,$t,$S,$O,$R,$C) = 
		('<textarea','</textarea>','<select','<option','type="radio"','type="checkbox"');
	my($n,$v);
	for $n(keys %{$data}) 
	{
		next if $n eq 'required';
		$v = $data->{$n};
		for($Page->{template}) 
		{
			s/($C [^>]*?name="$n"[^>]*?)>/$1 checked>/si						or
			s/($R [^>]*?name="$n".*? value="$v"[^>]*?)>/$1 checked>/si	or
			s/($T [^>]*?name="$n"[^>]*?>)$t/$1$v$t/si							or
			s/($S [^>]*?name="$n">)(.*?)($O value="$v">.+?)</$1$3$2</si	or
			s/name="$n"/name="$n" value="$v"/si
		}
	}
}

#	substitute template markers with acquired data

sub subDat 
{
	my($Page,$data,$key) = @_;
	parse $Page $key;
	my($r,$bfr);
	for $r(1..$data->{N}) 
	{
		$bfr = $Page->{dt};
		for(keys %{$data->{$r}}) 
			{ $bfr =~ s/###$_###/$data->{$r}{$_}/g }
		$Page->{hd} .= $bfr
	}
	$Page->{template} = $Page->{hd}.$Page->{tl}
}

#	special case of subDat for a single supplied sub-hash of values

sub subVal
{
	my($Page,$data) = @_;
	for(keys %{$data}) { $Page->{template} =~ s/###$_###/$data->{$_}/g }
	$Page->{output} = $Page->{template}
}

#	parse the key into the data loaded into hash

sub parse {
	my($Page,$K,$S) = @_;
	$S = 'template' unless $S;
	($Page->{hd},$Page->{dt},$Page->{tl}) =
		($Page->{$S} =~ /^(.+)<!-- start $K -->(.+)<!-- end $K -->(.+)$/s)
}

#	read a template file

sub rdTempl
{
	my($Page,$file) = @_;
	&Utl::rdFile("templates/FormATable/$file.htmlt")
}

#	Page object destructor

sub DESTROY 
{ 
	my $page = shift;
	for('__validation') { $page->{template} =~ s/<!--$_-->/$page->{$_}/ } 
	print STDOUT $page->{template}
}

1;
