package Test::MasterData::Declare::Row;
use 5.008001;
use strict;
use warnings;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/table_name row identifier_key/],
);

use Test2::Compare::Number qw/number/;
use Carp qw/croak/;
use JSON;

my $json = JSON->new->utf8;

sub source {
    my ($self, $column) = @_;

    return sprintf(
        "%s.%s %s=%s",
        $self->table_name, $column,
        $self->identifier_key, $self->row->{$self->identifier_key},
    );
}

sub json {
    my ($self, $column, @keys) = @_;
    my $json_data = $self->row->{$column};
    my $data = $json->decode($json_data);

    my $out = $data;
    for my $key (@keys) {
        if (ref $out eq "HASH") {
            $out = $out->{$key};
        }
        elsif (ref $out eq "ARRAY" && number($key)) {
            $out = $out->[$key];
        }
        else {
            croak "cannot access json attributes: out=$out key=$key";
        }
    }

    return $out;
}

1;
