package DirectoryTagEntryList;
use warnings;
use strict;
use Cwd;
use File::HomeDir;

use lib glob("~/.ds");

use DSConstants;
use DirectoryTagEntry;

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

sub get_size {
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

    close TAG_FILE;
}

sub write_file {
    my $self = shift;
    my $file_name = shift;
    open(TAG_FILE, ">", $file_name) or die "Cannot open $file_name: $!\n";

    for my $tag_entry (@$self) {
        print TAG_FILE $tag_entry->tag() . " " . $tag_entry->dir() . "\n";
    }

    close TAG_FILE;
}

sub add_tag_entry {
    my $self = shift;
    my $tag = shift;
    my $dir = shift;

    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq $tag) {
            # Tag already present. Update:
            $tag_entry->dir($dir);
            return $tag_entry;
        }
    }

    my $tag_entry = DirectoryTagEntry->new(tag => $tag,
                                           dir => $dir);
    push @$self, $tag_entry;
    return $tag_entry;
}

sub remove_tag_entry {
    my $self = shift;
    my $tag = shift;
    my $i = 0;

    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq $tag) {
            splice @$self, $i, 1;
            return $tag_entry;
        }

        $i++;
    }

    return undef;
}

sub update_previous_directory {
    my $self = shift;
    my $prevous_directory_name = shift;

    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq DSConstants::PREVIOUS_DIRECTORY_TAG) {
            $tag_entry->dir($prevous_directory_name);
            return;
        }
    }

    my $prev_tag = DirectoryTagEntry->new(
                    tag => DSConstants::PREVIOUS_DIRECTORY_TAG,
                    dir => $prevous_directory_name );

    push @$self, $prev_tag;
}

sub get_previous_directory {
    my $self = shift;

    for my $tag_entry (@$self) {
        if ($tag_entry->tag() eq DSConstants::PREVIOUS_DIRECTORY_TAG) {
            return $tag_entry->dir();
        }
    }

    return undef;
}

sub sort {
    my $self = shift;
    my $flag = shift;

    if ($flag eq DSConstants::SORT_BY_TAGS) {
        @$self = sort { $a->tag() cmp $b->tag() } @$self;
    } elsif ($flag eq DSConstants::SORT_BY_DIRS) {
        @$self = sort { $a->dir() cmp $b->dir() } @$self;
    } else {
        die "Unknown sort flag: $flag\n";
    }
}

sub print_tags {
    my $self = shift;
    print DSConstants::OPERATION_LIST, "\n";

    for my $tag_entry (@$self) {
        print $tag_entry->tag(), "\n";
    }
}

sub print_tags_and_dirs {
    my $self = shift;
    my $max_tag_width = -1;

    for my $tag_entry (@$self) {
        $max_tag_width = maximum($max_tag_width,
                                 length($tag_entry->tag()));
    }

    my $tag_column_width = "" . $max_tag_width;
    print DSConstants::OPERATION_LIST, "\n";

    for my $tag_entry (@$self) {
        printf("%-" . $tag_column_width . "s  %s\n",
               $tag_entry->tag(),
               $tag_entry->dir());
    }
}

sub print_dirs_and_tags {
    my $self = shift;
    my $max_dir_width = -1;

    for my $tag_entry (@$self) {
        $max_dir_width = maximum($max_dir_width,
                                 length($tag_entry->dir()));
    }

    my $dir_column_width = "" . $max_dir_width;
    print DSConstants::OPERATION_LIST, "\n";

    for my $tag_entry (@$self) {
        printf("%-" . $dir_column_width . "s  %s\n",
               $tag_entry->dir(),
               $tag_entry->tag());
    }
}

sub change_tilde_prefix_to_path {
    my $dir = shift;

    if ($dir =~ /^\s*\~/) {
        return File::HomeDir->my_home . substr($dir, 1);
    }

    return $dir;
}

sub match {
    my $self = shift;
    my $tag = shift;
    my $current_best_edit_distance = 1000_000_000;
    my $best_match = undef;

    for my $tag_entry (@$self) {
        my $tmp_edit_distance = $tag_entry->get_edit_distance_to($tag);

        if ($current_best_edit_distance > $tmp_edit_distance) {
            $best_match = $tag_entry;

            if ($tmp_edit_distance == 0) {
                last;
            }


            $current_best_edit_distance = $tmp_edit_distance;
        }
    }

    if (!$best_match) {
        return undef;
    }

    my $best_match_copy =
        DirectoryTagEntry->new(tag => $best_match->tag(),
                               dir => $best_match->dir());

    $best_match_copy->dir(
        change_tilde_prefix_to_path(
            $best_match_copy->dir()));

    return $best_match_copy;
}

sub get_tag_entry {
    my $self = shift;
    my $tag = shift;

    for my $tag_entry (@$self) {
        if ($tag eq $tag_entry->tag()) {
            return $tag_entry;
        }
    }

    return undef;
}

1;