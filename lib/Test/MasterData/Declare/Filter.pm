package Test::MasterData::Declare::Filter;
use 5.008001;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/runner code/],
);

sub run {
    my ($self, $rows) = @_;

    return $self->code->($rows);
}

1;
