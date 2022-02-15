package DirectoryTagList;
use warnings;
use strict;
BEGIN { unshift @INC, '.'; }
use DirectoryTag;

sub read_file($);

sub new {
    my $class = shift;
    my $self = [];
    bless ($self, $class);
    return $self;
}

sub length {
    my $self = shift;
    return scalar(@{$self});
}

sub read_file($) {
    my $self = shift;
    my $file_name = shift;
    open(TAG_FILE, "<", $file_name) or die "Cannot open $file_name: $!\n";
    
    while (<TAG_FILE>) {
        my $line = $_;
        chomp $line;
        
        if ($line =~ /^\s*(\w+)\s+(.*)$/g) {
            my $tag = $1;
            my $dir = $2;
            $dir =~ s/^\s+|\s+$//g;
            my $tag_entry = DirectoryTag->new( tag => $tag,
                                               dir => $dir);
            push @$self, $tag_entry;
        }   
    }
}

sub update_previous_directory {
    my $self = shift;
    my $prevous_directory_name = shift;    
    my $previous_directory_entry_name = "__ds_previous";

    for my $tag_entry (@$self) {
        print $tag_entry->tag(), "\n";
#        if ($tag_entry->tag() eq "__ds_previous_directory") {
 #           $tag_entry->dir() = prevous_directory_name;
  #      }
    }
}

1;