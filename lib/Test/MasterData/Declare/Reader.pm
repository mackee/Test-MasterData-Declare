package Test::MasterData::Declare::Reader;
use 5.008001;
use strict;
use warnings;

use Text::CSV qw/csv/;
use Carp qw/croak/;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/_rows table_name/],
);

use Test::MasterData::Declare::Row;

sub read_csv_from {
    my ($class, %args) = @_;
    my $filepath      = $args{filepath};
    my $table_name    = $args{table_name};
    my $identifier_key = $args{identifier_key};

    my $csv_rows = csv(
        in                 => $filepath,
        headers            => "auto",
        allow_loose_quotes => 0,
    ) or croak(Text::CSV->error_diag());

    my @rows;
    for my $row (@$csv_rows) {
        push @rows, Test::MasterData::Declare::Row->new(
            table_name     => $table_name,
            row            => $row,
            identifier_key => $identifier_key,
        );
    }

    return $class->new(
        _rows      => \@rows,
        table_name => $table_name,
    );
}

sub rows {
    my $self = shift;

    return $self->_rows;
}

1;
