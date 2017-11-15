package Test::MasterData::Declare::Rows;
use strict;
use warnings;
use utf8;

use parent "Test2::Compare::Base";

use Test2::Util::HashBase qw/ending rows/;

sub init {
    my $self = shift;

    $self->{+ROWS} ||= [];

    $self->SUPER::init();
}

sub name { "<ROWS>" }

sub verify {
}

1;
