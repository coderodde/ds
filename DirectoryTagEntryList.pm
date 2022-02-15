package DirectoryTagEntryList;
use warnings;
use strict;
BEGIN { unshift @INC, '.'; }
use DirectoryTagEntry;

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

sub write_file($) {
    my $self = shift;
    my $file_name = shift;
    open(TAG_FILE, ">", $file_name) or die "Cannot open $file_name: $!\n";
    
    for my $tag_entry ($self) {
        print TAG_FILE $tag_entry->tag() . " " . $tag_entry->dir() . "\n";
    }
}

sub add_tag_entry($$) {
    my $self = shift;
    my $tag = shift;
    my $dir = shift;
    my $tag_entry = DirectoryTagEntry->new(tag => $tag,
                                           dir => $dir);
    push @$self, $tag_entry;
}

sub remove_tag_entry($) {
    my $self = shift;
    my $tag = shift;
    my $i = 0;
    
    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq $tag) {
            splice @$self, $i, 1;    
            return 1;
        }
        
        $i++;    
    }
    
    return 0;
}

sub update_previous_directory {
    my $self = shift;
    my $prevous_directory_name = shift;
    my $prev_dir_tag_name = "__PREV__";
    
    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq $prev_dir_tag_name) {
            $tag_entry->dir($prevous_directory_name);
            return;
        }
    }
    
    my $prev_tag = DirectoryTagEntry->new(tag => $prev_dir_tag_name,
                                          dir => $prevous_directory_name );
    
    push @$self, $prev_tag;
}

1;