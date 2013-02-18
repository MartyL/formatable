package DB;

use strict;
use DBI();

#	database accessor object reference

sub new 
{
	my $DB = shift;
	my $dbh = DBI->connect('DBI:mysql:formatable:localhost','root','')
		or die "Database connection not made: $DBI::errstr\n";
	$dbh->{RaiseError} = 1;
	bless { h => $dbh }, $DB
}

#	run a selection query and return all the rows

sub getDat
{
	my($DB,$st) = @_;
	cols $DB 'FormATable';											#	get the column names
	my $comp = ($st->{value} =~ /\*/) ? 'like' : '=';
	$st->{value} =~ s/\*/%/g;										#	use Mysql wild card
	my $cond = qq| where $st->{search} $comp '$st->{value}'| if $st->{search} and $st->{value};
	$cond .= qq| order by $st->{sort}| if $st->{sort};
	my $stm = qq|select $DB->{cols} from FormATable$cond;|;
	my $sth = $DB->{h}->prepare($stm);
	$sth->execute();
	my @nm = split ',',$DB->{cols};
	my(%vl,@vl,$N,$res);
	for(@nm) {push @vl,\$vl{$_}}
	$sth->bind_columns(undef,@vl);
	while($sth->fetch()) {$N++; for(keys %vl) {$res->{$N}{$_} = $vl{$_}}}
	$res->{N} = $N;
	$res
}

#	add a table row

sub addDat
{
	my($DB,$data) = @_;
	cols $DB 'FormATable';											#	get the column names
	for(split ',',$DB->{cols}) { push @{$DB->{set}},$data->{$_} }
	my $stm = qq|insert FormATable($DB->{cols}) values($DB->{hold});|;
	$DB->{h}->do($stm,undef,@{$DB->{set}}) or die "addDat failed - $DBI::errstr"
}

#	get the column list from the DB

sub cols
{
	my($DB,$table) = @_;
	my(@row,@fields);
	my $sth = $DB->{h}->prepare("describe $table");
	$sth->execute();
	push @fields, $row[0] while @row = $sth->fetchrow_array;
	$DB->{cols} = join(',',@fields);
	$DB->{hold} = '';													#	initialize
	for(@fields) { $DB->{hold} .= '?,' }
	chop $DB->{hold}
}

#	replace a table row

sub replDat {
	my($DB,$st) = @_;
	my $stm = qq|replace $st->{table}($st->{cols}) values($st->{hold});|;
	$DB->{h}->do($stm,undef,@{$st->{set}}) or die "replDat failed - $DBI::errstr"
}

#	print contents of a query result

sub diag
{
	my($DB,$set) = @_;
	print "<br>Answer size eq $set->{N}\n";
	my $r;
	for $r(1..$set->{N}) {
		for(keys %{$set->{$r}})
			{print "<br>set->{$r}{$_} eq $set->{$r}{$_}\n"}
	}
}

#	database object destructor

sub DESTROY 
{
	my $DB = shift;
	$DB->{h}->disconnect() 
		or die "DB disconnect failed: $DBI::errstr\n"
}

1;
