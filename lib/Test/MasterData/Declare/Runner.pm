package Test::MasterData::Declare::Runner;
use 5.008001;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/bucket/],
    ro  => [qw/context code/],
);

sub run {
    my $self = shift;

}

sub add_reader_to_bucket {
    my ($self, $reader) = @_;

    # TODO: merge reader
    $self->bucket->{$reader->table_name} = $reader;
}

sub pull_reader {
    my ($self, $table_name) = @_;

    return $self->bucket->{$table_name};
}

1;
