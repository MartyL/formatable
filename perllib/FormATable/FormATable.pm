package FormATable;

use strict;

use Data();
use Flat();			# or
use DB();
use Page();
use Utl();

#	create a new FormATable object instance

sub new
{
	my $FormATable = shift;
	my $page	= new Page;
	my $data	= new Data;
	my $db	= new Flat;		# or
	my $db	= new DB;
	if(not valid $data)			{ restore $page		 $data }
	elsif($data->{Function})	{ display $FormATable $data,$page,$db }
	else								{ addToDB $FormATable $data,$page,$db }
}

#	display the contents of the database to the client

sub display
{
	my($FormATable,$data,$page,$db) = @_;
	my $addSearch = $data->{value} ? "&amp;search=$data->{search}&amp;value=$data->{value}" : '';
	($page->{template} = rdTempl $page $data->{Function}) =~
		s/(display)(&amp;sort=)/$1$addSearch$2/g;
	parse $page 'entry';
	my $ans = getDat $db
	( {sort=>$data->{sort},search=>$data->{search},value=>$data->{value}} );
	subDat $page $ans,'entry'
}

#	add a new form entry to the DB

sub addToDB
{
	my($FormATable,$data,$page,$db) = @_;
	$data->{id} = time;
	addDat $db $data;
	msg $FormATable $data,"The following has been added to FormATable\n\n";
	$page->{template} = rdTempl $page 'formAdd'
}

#	send webmaster an email

sub msg
{
	my($self,$data,$msg) = @_;
	for(sort keys %{$data}) 
	{ $msg .= "$_ : $data->{$_}\n" unless $data->{$_} !~ /\S/ }
	&Utl::sendMail
	({	
		to		=>	'webmaster@mysite.com',
		from	=> 'Face 2 Interface', 
		subj	=> "$ENV{HTTP_HOST} FormATable Entry Added",
		body	=> $msg 													
	})
}

#	FormATable object destructor

sub DESTROY { }

1;
