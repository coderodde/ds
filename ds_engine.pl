#!/usr/bin/perl
use warnings;
use strict;
BEGIN { unshift @INC, '.'; }
use DirectoryTagEntry;
use DirectoryTagEntryList;
use Cwd;

my $tag_file_name = "tags";
my $operation_switch_dir = "switch_directory";

sub show_tag_list {
    my $list = shift;
    my ($show_dirs, $sorted) = @_;
    print "dirs: $show_dirs, sorted: $sorted\n";
}

sub show_tag_list_sorted_by_dirs {
    
    print "by dirs\n";
}

sub process_jump_to_previous {
    my $tag_list = shift;
    my $previous_dir_tag = $tag_list->get_previous_directory();
    
    print "$operation_switch_dir\n";
    
    if (defined $previous_dir_tag) {
        print $previous_dir_tag->dir();
    } else {
        print getcwd;
    }
}

sub jump_to_tagged_directory {
    my $list = shift;
    my $tag = shift;
    my $dir = $list->match($tag);

    print "$operation_switch_dir\n";    
    
    if (not defined $dir) {
        print getcwd, "\n";
    } else {
        print $dir, "\n";  
    }
}

sub process_single_arg {
    my $flag = $_[0];
    my $list = $_[1];
    
    if ($flag =~ /^-[lLsSd]$/) {
        for ($flag) {
            $_ eq "-l" && show_tag_list($list, 0, 0);
            $_ eq "-L" && show_tag_list($list, 1, 0);
            $_ eq "-s" && show_tag_list($list, 0, 1);
            $_ eq "-S" && show_tag_list($list, 1, 1);
            $_ eq "-d" && show_tag_list_sorted_by_dirs($list);
        }
    } else {
        jump_to_tagged_directory($list, $flag);   
    }
}

sub add_tag {
    my ($tag, $dir) = @_;
    print "add tag $tag $dir\n";
}

sub remove_tag {
    my ($tag) = @_;
    print "remove tag $tag\n";
}

sub update_previous {
    my ($new_dir) = @_;
    print "update to $new_dir\n";
}

sub process_double_args {
    my ($cmd, $tag) = @_;
    
    if ($cmd !~ /^-a|--add-tag|add|-r|--remove-tag|remove|--update-previous$/) {
        die "$cmd: command not recognized.";
    }
    
    for ($cmd) {
        $_ eq "-a"        && add_tag($tag, getcwd());
        $_ eq "--add-tag" && add_tag($tag, getcwd());
        $_ eq "add"       && add_tag($tag, getcwd());
        
        $_ eq "-r"           && remove_tag($tag);
        $_ eq "--remove-tag" && remove_tag($tag);
        $_ eq "remove"       && remove_tag($tag);
        
        my $update_dir = $tag;
        
        $_ eq "--update-previous" && update_previous($update_dir);
    }
}

sub process_triple_args {
    my ($cmd, $tag, $dir) = @_;

    if ($cmd !~ /^-a|--add-tag|add$/) {
        die "$cmd: command not recognized.";
    }
    
    add_tag($tag, $dir);
}

if (scalar @ARGV > 3) {
    print STDERR "Too many arguments!";
    exit 1;
}

#my $tag = DirectoryTagEntry->new( tag => "home",
#                                  dir => "/home/rodde" );

my $directory_tag_list = DirectoryTagList->new();
$directory_tag_list->read_file($tag_file_name);
print "LIST ", $directory_tag_list->length(), "\n";

for (scalar @ARGV) {
    $_ == 0 && process_jump_to_previous;
    $_ == 1 && process_single_arg  @ARGV;
    $_ == 2 && process_double_args @ARGV;
    $_ == 3 && process_triple_args @ARGV;
}
