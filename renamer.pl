#!perl

use strict;
use warnings;
use LWP::Simple; # to grab web content
# use Text::Autoformat; # can use this to do formatting that is
# performed by $line = join " ", map {ucfirst} split " ", $line;
use File::Copy;

=foreach my $file (glob("*house*")) {

   ($name, $season, $episode, $info, $extension) 
             = ($file =~ /([\w|\.]*)\.(s\d\d)(e\d\d)\.(.*)\.([^\.]*)/i)
   or
   ($name, $season, $episode, $extension) 
             = ($file =~ /([\w ]*) (s\d\d) ?(e\d\d) \- ?\.([^\.]*)$/i);

   print "($name, $season, $episode, $extension)\n";
}
=cut

my @files;

# get a list of files that we are going to manipulate
foreach my $file (glob("*")) {
   push @files, $file if ! -d $file and $file !~ /Thumbs\.db/
   and $file !~ /\.(pl|txt)/ 
   and (
      ($file =~ /([\w|\.]*)\.(s\d\d)(e\d\d)\.(.*)\.([^\.]*)/i)
      or
      ($file =~ /([\w ]*) (s\d\d) ?(e\d\d) \- ?\.([^\.]*)$/i)
      ); #Dollhouse S01 E11 - .avi
}

# quick visual check
print STDERR join "\n", @files;


#print STDERR "\n\n", '~' x 72, "\n";

my ($name, $season, $episode, $info, $extension);

foreach my $file (@files) {
#   $file =~ s/\./ /;
#   $file =~ s/(\w|\.)\.(s\d\de\d\d)\.(.*)\.([^\.]*)/$1 $2 $3 $4/i;
   ($name, $season, $episode, $info, $extension) 
             = ($file =~ /([\w|\.]*)\.(s\d\d)(e\d\d)\.(.*)\.([^\.]*)/i)
             or
   ($name, $season, $episode, $extension) 
             = ($file =~ /([\w ]*) (s\d\d) ?(e\d\d) \- ?\.([^\.]*)$/i);

   # abc def ghi => Abc Def Ghi, might break in some boundary cases
   $name = join "+", map {ucfirst} split "[.]", $name;

   # should join on space and find some other way to get pluses
   # into name for the url

   # get episode list from tvrage
   my $url = 
      "http://services.tvrage.com/tools/quickinfo.php?show=$name&" . 
      "ep=" . ($season =~ /(\d\d)/)[0] . 
      "x" . ($episode =~ /(\d\d)/)[0] . "&exact=1"; 
      # exact=1 => $name must exactly match a tv show (possible new feature to remove this?)

#   print STDERR $url;


   #get the title of the episode from tvrage (turn this into a function)
   my $episodeInfo = get($url);
   my $episodeTitle = (split /\^/, (split /\n/, $episodeInfo)[6])[1];
   
   $name =~ s/\+/ /g;
   print "\n$name " . uc ("$season $episode") . " - $episodeTitle.$extension";
   my $newFile = "$name " . uc ("$season $episode") . " - $episodeTitle.$extension";
      #move ($file, $newFile);
}

exit 0;
