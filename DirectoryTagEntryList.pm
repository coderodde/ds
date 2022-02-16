package DirectoryTagEntryList;
use warnings;
use strict;
BEGIN { unshift @INC, '.'; }
use DirectoryTagEntry;
use Util;

sub get_previous_directory;

sub minimum {
    my @sorted = sort { $a <=> $b } @_;
    return $sorted[0];
}

sub maximum {
    my @sorted = sort { $a <=> $b } @_;
    return $sorted[$#sorted];
}

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
            my $tag_entry = DirectoryTagEntry->new( tag => $tag,
                                                    dir => $dir );
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
    
    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq Util::PREVIOUS_DIRECTORY_TAG) {
            $tag_entry->dir($prevous_directory_name);
            return;
        }
    }
    
    my $prev_tag = DirectoryTagEntry->new(tag => Util::PREVIOUS_DIRECTORY_TAG,
                                          dir => $prevous_directory_name );
    
    push @$self, $prev_tag;
}

sub get_previous_directory {
    my $self = shift;
    
    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq Util::PREVIOUS_DIRECTORY_TAG) {
            return $tag_entry->dir();
        }
    }
    
    return undef;
}

sub sort {
    my $self = shift;
    my $flag = shift;
    
    if ($flag eq "tags") {
        @$self = sort { $a->tag() cmp $b->tag() } @$self;
    } elsif ($flag eq "dirs") {
        @$self = sort { $a->dir() cmp $b->dir() } @$self;
    } else {
        die "Unkown sort flag: $flag\n";
    }
}

sub print_tags {
    my $self = shift;
    
    for my $tag_entry (@$self) {
        print $tag_entry->tag(), "\n";
    }
}

sub print_tags_and_dirs {
    my $self = shift;
    my $max_tag_width = -1;
    
    for my $tag_entry (@$self) {
        $max_tag_width = maximum($max_tag_width,
                                 Core::length($tag_entry->tag()));
    }
    
    my $tag_column_width = "" . $max_tag_width;
    
    for my $tag_entry (@$self) {
        printf("%" . $tag_column_width . "s %s\n", $tag_entry->tag(), $tag_entry->dir()); 
    }
}

sub print_dirs_tags {
    my $self = shift;
    my $max_dir_width = -1;
    
    for my $tag_entry (@$self) {
        $max_dir_width = maximum($max_dir_width,
                                 Core::length($tag_entry->dir()));
    }
    
    my $dir_column_width = "" . $max_dir_width;
    
    for my $tag_entry (@$self) {
        printf("%" . $dir_column_width . "s %s\n", $tag_entry->dir(), $tag_entry->tag()); 
    }
}

sub match {
    my $self = shift;
    my $dir = shift;
    my $current_edit_distance = undef;
    my $best_match = undef;
    
    for my $tag_entry (@$self) {
        my $tmp_edit_distance = $tag_entry->get_edit_distance_to($dir);
        
        if (not defined $current_edit_distance) {
            $current_edit_distance = $tmp_edit_distance;
            $best_match = $tag_entry;
        } elsif ($current_edit_distance > $tmp_edit_distance) {
            $current_edit_distance = $tmp_edit_distance;
            $best_match = $tag_entry;
        }
    }
    
    return $best_match;
}

1;