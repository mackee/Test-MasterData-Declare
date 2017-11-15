package Test::MasterData::Declare::Subset;
use 5.008001;
use strict;
use warnings;

use Carp qw/croak/;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/rows _index/],
);

sub next {
    my $self = shift;

    return unless defined $self->_inc_index;

    return $self->rows->[$self->_index];
}

sub _inc_index {
    my $self = shift;

    my $index = defined $self->_index ? $self->_index + 1 : 0;
    if ($index >= scalar(@{$self->rows})) {
        return;
    }
    $self->_index($index);
}

1;
