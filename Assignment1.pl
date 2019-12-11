
use strict;
use warnings;
use Time::Piece;
use Time::Seconds;
use Data::Dumper qw(Dumper);
 
my $filename = 'Records.txt';
my %detail=();
my $Shift_Start_Time = 0;
my $Shift_end_time = 0;
my $slept_start_time=0;
my $wake_up_time = 0;
my $most_worked_time = 0;
my $most_slept_time = 0;
my $most_worked_id = 0;
my $most_slept_id = 0;
my $work_time = 0;
my $slept_time = 0;
my %full_report;
my $guard_id = 0;
my $day = 0;
my $length;
my @words;
open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
 
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
	my $time = substr $row,index($row,"[")+1,index($row,"]")-1;
	my $t = Time::Piece->strptime($time, "%Y-%m-%d %H:%M");
	my $work = $words[$length-2].$words[$length-1];
	if($work eq "beginsshift"){
		$work_time = 0;
		$slept_time = 0;
		$day = keys %{$full_report{$guard_id}};
		$day = $day +1;
		$Shift_Start_Time = $t;
		$Shift_end_time = $Shift_Start_Time+ONE_DAY;
		$work_time = ($Shift_end_time - $Shift_Start_Time)/60;
		$full_report{$guard_id}{$day}{'Shift_Start_time'} = $Shift_Start_Time;
		$full_report{$guard_id}{$day}{'Shift_end_time'} = $Shift_end_time;
		$full_report{$guard_id}{$day}{'Total_work_time'} = $work_time;
	}
	elsif($work eq "fallsasleep"){
		$slept_start_time = $t;
	}
	elsif($work eq "wakesup"){
		$wake_up_time = $t;
		$work_time = $work_time - (($wake_up_time - $slept_start_time)/60);
		$slept_time = $slept_time + (($wake_up_time - $slept_start_time)/60);
		$full_report{$guard_id}{$day}{'Total_work_time'} = $work_time;
		$full_report{$guard_id}{$day}{'Total_Slept_time'}= $slept_time;
	}
	
	}
}

foreach my $ID (sort(keys %full_report))  
{ 
	my $total_work_time = 0;
	my $total_slept_time = 0;
	my $days = 0;
    print "Report for Guard ID $ID: \n";
for $day (sort(keys %{$full_report{$ID}})) 
    { 
		$days = $days +1;
        print "\tDay : $day : \n";
		if(exists($full_report{$ID}{$day}{'Shift_Start_time'})){
			print "\t\tShifted_Start_time :".$full_report{$ID}{$day}{'Shift_Start_time'} . "\n"; 
		}
		if(exists($full_report{$ID}{$day}{'Shift_end_time'})){
			print "\t\tShifted_End_time :".$full_report{$ID}{$day}{'Shift_end_time'} . "\n"; 
		}
		if(exists($full_report{$ID}{$day}{'Total_work_time'})){
			print "\t\tTotal work time :".$full_report{$ID}{$day}{'Total_work_time'} . "\n"; 
			$total_work_time = $total_work_time + $full_report{$ID}{$day}{'Total_work_time'};
		}
		if(exists($full_report{$ID}{$day}{'Total_Slept_time'})){
			print "\t\tTotal Slept time :".$full_report{$ID}{$day}{'Total_Slept_time'} . "\n";
			$total_slept_time = $total_slept_time+$full_report{$ID}{$day}{'Total_Slept_time'};
		} 
    }
	$total_work_time = $total_work_time/$days;
	$total_slept_time = $total_slept_time/$days;
	if($most_worked_time < $total_work_time) {
		$most_worked_time = $total_work_time;
		$most_worked_id = $ID;
	}
	if($most_slept_time < $total_slept_time) {
		$most_slept_time = $total_slept_time;
		$most_slept_id = $ID;
	}
} 

print "Most worked Guard id $most_worked_id \n";
print "Most Slept Guard id $most_slept_id \n";

