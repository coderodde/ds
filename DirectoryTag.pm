package DirectoryTag;
use warnings;
use strict;
use diagnostics;
use List::Util;

sub edit_distance_impl (\@\@);
sub edit_distance ($$);

sub edit_distance ($$) {      
    my ($ref_str1, $ref_str2) = @_;
    my @chars1 = split "", $ref_str1;
    my @chars2 = split "", $ref_str2;
    return edit_distance_impl(@chars1, @chars2);
}

sub edit_distance_impl (\@\@) {
    my ($ref_chars1, $ref_chars2) = @_;
    my $matrix_height = scalar $ref_chars1 + 1;
    my $matrix_width  = scalar $ref_chars2 + 1;
    my $matrix = [];
    
    # Initialize the matrix:
    for my $y ($matrix_height) {
        my $row = [];
        # Make $row $matrix_width elements long:
        $row->[$matrix_width - 1] = 0;
        $matrix->[$y] = $row;
    }

    # Initialize the leftmost column:
    for my $y (1, $matrix_height - 1) {
        $matrix->[$y][0] = $y;
    }
    
    # Initialize the topmost row:
    for my $x (1, $matrix_width - 1) {
        $matrix->[0][$x] = $x;
    }
    
    my $substitution_cost;
    
    # Compute the distance:
    for my $x (1, $matrix_width - 1) {
        for my $y (1, $matrix_height - 1) {
            if ($ref_chars1->[$x] eq $ref_chars2->[$y]) {
                $substitution_cost = 0;
            } else {
                $substitution_cost = 1;
            }
            
            $matrix->[$y][$x] = min($matrix->[$y - 1][$x] + 1,
                                    $matrix->[$y][$x - 1] + 1,
                                    $matrix->[$y - 1][$x - 1] + $substitution_cost);
        }
    }
    
    return $matrix->[$matrix_height - 1][$matrix_width - 1];
}

sub new {
    my $class = shift;
    my %self = {@_};
    bless %self, $class;
    return ref %self;
}

sub tag { $_[0]->{tag} = $_[1] if defined $_[1]; $_[0]->{tag}}
sub dir { $_[0]->{dir} = $_[1] if defined $_[1]; $_[0]->{dir}}

print "edit distance: ", edit_distance("aaa", "aac"), "\n";