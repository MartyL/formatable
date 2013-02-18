package Utl;

use strict;

sub root { '###root path###/' }				#	root server path

#	read a file and return its contents or an error code

sub rdFile
{
	my $file = &root() . shift;
	my $bfr;
	if(-e $file)
	{
		open (F,$file) or &errMsg('open',$file);
		{ local $/; $bfr = <F> }
		close F or &errMsg('close',$file)
	}
	else { die "File $file can't be found\n" }
	$bfr
}

#	write a new file 

sub crFile
{
	my $file = &root() . shift;
	open (F,">$file") or &errMsg('open',$file);
	print F shift;
	close F or &errMsg('close',$file)
}

#	append to a file

sub apFile
{
	my $file = &root() . shift;
	if(-e $file)
	{
		open (F,">>$file") or &errMsg('open',$file);
		print F shift,"\n";
		close F or &errMsg('close',$file)
	}
	else { &errMsg ("apFile $file failed") }
}

#	generic sendmail routine

sub sendMail
{
	my $inf = shift;
	my $mail = '/usr/sbin/sendmail';
	my $print = 
		qq|To: $inf->{to}\nFrom: $inf->{from}\nSubject: $inf->{subj}\n\nDear $inf->{to},\n\n$inf->{body}\n|;
	$print .= "\nRegards,\nFormATable Mailroom\n\n";
	open (MAIL, "|$mail $inf->{to}") or die "open $mail failed: $!\n";
	print MAIL $print;
	close MAIL or die "close $mail failed: $!\n"
}

sub errMsg { print STDOUT "$_[0] $_[1] $!\n"; die }		#	error handler

1;
