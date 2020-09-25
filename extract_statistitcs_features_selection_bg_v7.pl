#!/usr/bin/perl
use utf8;
use experimental 'smartmatch';
use Algorithm::FeatureSelection;
use Data::Dumper;

my $fs = Algorithm::FeatureSelection->new();

my $_path1 = "C:\\Users\\Boris Velichkov\\Desktop\\PERL\\algorithms";
my $_path = $_path1.'/Data';



my $count=0;


opendir(FTPDIR, $_path) || die("Unable to open directory");

@files = readdir(FTPDIR);
closedir(FTPDIR);
chdir($_path);

shift @files;
shift @files;  #removes . .. from DIR
my $_words_hash;


foreach $file (@files)
{ 
my $_text='';


# open test file
die ":test_2_2.pl: Unable to open for reading: [$file]!\n" unless open(TEXT, "<:utf8", $file);

while (<TEXT>) { 


 chomp($_);
   my @words = split /,/, $_;
   my  $key = shift @words;
    $_text = lc(join(' ', @words));


while ($_text =~ /([\p{Letter}]+)/igso) {
   my $_word   = $1;
   if (! exists  $_words_hash{$_word}) {  $_words_hash{$_word}= {} }
   if (! exists  $_words_hash->{$_word}->{$key} ) {$_words_hash->{$_word}->{$key}=1;}
	else {$_words_hash->{$_word}->{$key}++;} 

}


}


close(TEXT);
}

# dump results in target file

my $_trg_file_name   = $_path1.'/Results/res-fs.csv';

# open target file for writing
die ":test_2_2.pl: Unable to open for writing: [$_trg_file_name]!\n" unless open(F1, ">:utf8","$_trg_file_name");
   foreach my $_w (keys %$_words_hash) {
      print F1 "$_w";
	  foreach my $icd (keys %{$_words_hash->{$_w}})
	    {print F1 ",$icd-$_words_hash{$_w}{$icd}"; 	  
		}
		print F1 "\n";
   }

close(F1);

my @one_hot=();

my $_trg_file_name2   = $_path1.'/Results/one_hot.csv';
die ":_trg_file_name2: Unable to open for writing: [$_trg_file_name2]!\n" unless open(F2, ">:utf8","$_trg_file_name2");

# get information-gain 
my $ig = $fs->information_gain($_words_hash);
print("Information Gain:\n");
#print ref(%{$ig});
#print "$ig";

# foreach my $f (keys %{$ig})
# foreach my $f (keys %$ig)
#foreach my $f (keys %$ig) {
	#print "$f -";
	#foreach my $v (keys %{$ig{$f}}) {
		#print " $v"; 	  
	#}
	#print "\n";
#}
my @feature=();
my $tr=10.23;

print F2 "key";
for(keys %$ig){
    #$ig->{$_} = sprintf("%6.4f", $ig->{$_});
	print("  KEY: $_\n");
	print("VALUE: $ig->{$_}\n");
	if ($ig->{$_} > $tr) {push( @feature, $_); print F2 ",$_";}
}
print F2 "\n";






foreach $file (@files)
{ # open test file
die ":test_2_2.pl: Unable to open for reading: [$file]!\n" unless open(TEXT, "<:utf8", $file);

while (<TEXT>) { 

my @row=();
 chomp($_);
   my @words = split /,/, $_;
   my  $key = shift @words;
    $_text = lc(join(' ', @words));

my @words_in_text=();

while ($_text =~ /([\p{Letter}]+)/igso) {
    my $_word   = $1;
    push(@words_in_text, $_word);

}
push(@row,$key);
print F2 "$key";

foreach my $_f ( @feature) {

   if ($_f ~~ @words_in_text) {push(@row,1);   print F2 " 1";}
   else {push(@row,0);  print F2 " 0";}
   }
   print F2 "\n";

}

close(TEXT);
}
close(F2);
