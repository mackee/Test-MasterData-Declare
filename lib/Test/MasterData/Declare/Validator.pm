package Test::MasterData::Declare::Validator;
use 5.008001;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/runner code/],
);

sub run {
    my ($self, $value) = @_;

    return $self->code->($value);
}

1;
