package Test::MasterData::Declare::Reader::CSV;
use 5.008001;
use strict;
use warnings;

use Text::CSV qw/csv/;
use Carp qw/croak/;

use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/_rows/],
    ro  => [qw/table_name/],
);

sub read_from {
    my ($self, $filepath) = @_;

    my $rows = csv(in => $filepath, headers => "auto") or croak(Text::CSV->error_diag());
    $self->_rows($rows);
}
