use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
 
my $filename = 'Records.txt';
my %detail=();
my $Shift_Start_Time;
my $Shift_end_time;
my $slept_start_time;
my $wake_up_time;
my $slept_time;
my %full_report;
my $guard_id;
my $day;
my %tmp;
my $length;
my @words;
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";
 
while (my $row = <$fh>) {
chomp $row;
if($row ne "") {
	@words = split / /, $row;
	$length = @words;
	if (index($row, "Guard") != -1) {
		$guard_id = $words[3];
		$guard_id =~ s/#//g;
	   print "$guard_id\n";
	}
	$day = keys %full_report;
	my $time = substr $row,index($row,"[")+1,index($row,"]")-1;
	my $t = Time::Piece->strptime($time, "%Y-%m-%d %H:%M");
	my $work = $words[$length-2].$words[$length-1];
	if($work eq "beginsshift") {
		$tmp{'Slept_time'} -> $slept_time;
		$tmp{'work_time'} -> (($t-$Shift_Start_Time)-$slept_time)/60;
		$full_report{$guard_id}{$day} = %tmp;
		$Shift_Start_Time = $t;
	}
	elsif($work eq "fallsasleep"){
		$slept_start_time = $t;
	}
	elsif($work eq "wakesup"){
		$wake_up_time = $t;
		$slept_time = $slept_time - ($wake_up_time - $slept_start_time)/60;
	}
	
	}
}