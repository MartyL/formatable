package Flat;

use strict;

#	flat file accessor object reference

sub new { my $Flat = shift; bless { Master => getMaster $Flat }, $Flat }

#	read the master file and table its contents

sub getMaster
{
	my($Flat,%Master) = shift;
	(my $cols) = (&Utl::rdFile(&path('dictauth')) =~ /^#\n(.+)\n#\n$/s);
	@{$Master{cols}} = split / \| /,$cols;
	\%Master
}

#	add a table row

sub addDat
{
	my($Flat,$data) = @_;
	my $rec;
	for(@{$Flat->{Master}{cols}}) { $rec .= $data->{$_} . ' | ' }
	$rec = substr($rec,0,-3);
	&Utl::apFile('packages/FormATable/flatDB/FormATable.flat',$rec)
}

#	run a selection query and return all the rows

sub getDat
{
	my($Flat,$st) = @_;
	my($res,$num,$N);
	my $table = &Utl::rdFile(&path('FormATable'));
	my($row,@vals,%row);
	for $row(split /\n/,$table)
	{
		++$N;
		@vals = reverse (split / \| /,$row);
		for(@{$Flat->{Master}{cols}}) { $res->{$N}{$_} = pop @vals }
	}
	$res->{N} = $N;
	Sort $Flat &Search($Flat,$res,$st->{search},$st->{value}),$st->{sort}
}

#	search the query as specified by request

sub Search
{
	my($Flat,$ans,$search,$value) = @_;
	($search and $value) or return $ans;
	(my $pattern = $value) =~ s/\*/\.\*/g;
	my($res,$N);
	for(1..$ans->{N})	
	{ if($ans->{$_}{$search} =~ /^$pattern$/oi) { $res->{++$N} = $ans->{$_} } }
	$res->{N} = $N;
	$res
}

#	sort the query result according to request

sub Sort
{
	my($Flat,$ans,$sort) = @_;
	$sort or return $ans;
	my(%sort,$res,$N,$i);
	$res->{N} = $ans->{N};
	for(1..$ans->{N})		{ $sort{$ans->{$_}{$sort}.'_'.++$i} = $_ }
	for(sort keys %sort)	{ $res->{++$N} = $ans->{$sort{$_}} }
	$res
}

sub path { 'packages/FormATable/flatDB/' . (shift) . '.flat' }

sub DESTROY { }

1;
