package Test::MasterData::Declare;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Test2::API qw/context/;
use Test2::V0;
use Test2::Compare ();
use Test2::Tools::Compare qw/number/;
use Test2::Compare::Custom;
use Scalar::Util qw/blessed/;

use Carp qw/croak/;

use parent "Exporter";
our @EXPORT = qw/
    master_data
    load_csv
    table
    expect_row
    relation

    like_number
    if_column
    json
/;

our $DEFAULT_IDENTIFIER_KEY = "id";

use Test::MasterData::Declare::Runner;
use Test::MasterData::Declare::Reader;
use Test::MasterData::Declare::Validator;
use Test::MasterData::Declare::Filter;

my $runner;

sub master_data :prototype(&) {
    my $code = shift;

    $runner = Test::MasterData::Declare::Runner->new(
        code => $code,
    );

    $runner->run;

    $runner = undef;
}

sub load_csv {
    my %paths = @_;
    my $identifier_key = delete $paths{_identifier_key} || $DEFAULT_IDENTIFIER_KEY;

    for my $table_name (keys %paths) {
        my $filepath = $paths{$table_name};
        my $reader = Test::MasterData::Declare::Reader->read_csv_from(
            table_name     => $table_name,
            filepath       => $filepath,
            identifier_key => $identifier_key,
        );

        $runner->add_reader_to_bucket($reader);
    }
}

sub table {
    my ($table_name, $column, @filters_or_expects) = @_;
    my $ctx = context();

    my $rows = $runner->rows($table_name);
    like $rows, array {
        for my $fe (@filters_or_expects) {
            if (blessed $fe && $fe->isa("Test2::Compare::Base")) {
                all_items
                    object {
                        call row => hash {
                            field $column => $fe;
                        };
                    };
            }
            elsif (ref $fe eq "CODE") {
                $fe->($column);
            }
        }
    };

    $ctx->release;
}

sub like_number {
    my ($begin, @funcs) = @_;

    my $end = $funcs[0] && number($funcs[0]) ? shift @funcs : $begin;


    my $operator = "$begin <= ... <= $end";
    if ($begin == $end) {
        $operator = "$begin == ...";
    }

    my $cus = Test2::Compare::Custom->new(
        name => "Equal",
        operator => $operator,
        code => sub {
            my %args = @_;
            return 0 unless number($args{got});

            return $begin <= $args{got} && $args{got} <= $end ? 1 : 0;
        },
    );

    return $cus, @funcs;
}

sub if_column {
    my ($column, $cond, @funcs) = @_;

    my $filter;
    if (ref $column eq "CODE") {
        $filter = sub {
            my @rows = @_;
            my @filtered;
            for my $row (@rows) {
                push @filtered, $row if $column->($row->row);
            }
            return @filtered;
        };
    }
    else {
        $filter = sub {
            my @rows = @_;
            my @filtered;
            for my $row (@rows) {
                my $delta = Test2::Compare::compare(
                    $row->row->{$column},
                    $cond,
                    \&Test2::Compare::relaxed_convert,
                );
                push @filtered, $row unless $delta;
            }
            return @filtered;
        };
    }

    return sub {
        my $array = Test2::Compare::get_build();
        $array->add_filter($filter);
    }, @funcs;
}

sub json {
    my ($key, @funcs) = @_;

    my @keys = ($key);
    while (scalar(@funcs) > 0 && !blessed $funcs[0] && ref $funcs[0] ne "CODE") {
        push @keys, shift @funcs;
    }

    return sub {
        my $column = shift;
        my $ctx = context();
        all_items
            object {
                for my $f (@funcs) {
                    if (blessed $f && $f->isa("Test2::Compare::Base")) {
                        call ["json", $column, @keys] => $f;
                    }
                    elsif (ref $f eq "CODE") {
                        call ["json", $column, @keys] => validator(sub {
                            my %args = @_;
                            my $got = $args{got};
                            $f->($got);
                        });
                    }
                }
            };
        $ctx->release;
    };
}

sub expect_row {
    my ($table_name, $func) = @_;

    my $ctx = context();

    my $rows = $runner->rows($table_name);
    like $rows, array {
        all_items
            object {
                call row =>
                    validator(sub {
                        my %args = @_;
                        my $got = $args{got};
                        $func->($got);
                    });
        };
    };

    $ctx->release;
}

sub relation {
    my ($from_table, $to_table, @opts) = @_;

    my %conds;
    while (!ref $opts[0] && scalar(@opts) >= 2) {
        my $from_table_column = shift @opts;
        my $to_table_column = shift @opts;
        $conds{$from_table_column} = $to_table_column;
    }

    my $from_rows = $runner->rows($from_table);
    my $to_rows = $runner->rows($to_table);
    my $to_rows_selector = sub {
        my %from_row_values = @_;

        my @matched_rows = grep {
            my $row = $_->row;
            grep { $from_row_values{$_} == $row->{$conds{$_}} } keys %conds;
        } @$to_rows;

        return @matched_rows;
    };

    my $ctx = context();
    like $from_rows, array {
        all_items
            object {
                call row => validator(sub {
                    my %args = @_;
                    my $from_row = $args{got};
                    my @relations = $to_rows_selector->(%$from_row);

                    my $ok = is scalar(@relations), scalar(keys %conds);
                });
            };
    };
    $ctx->release;
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::MasterData::Declare - It's new $module

=head1 SYNOPSIS

    use Test::MasterData::Declare;

=head1 DESCRIPTION

Test::MasterData::Declare is ...

=head1 LICENSE

Copyright (C) mackee.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mackee E<lt>macopy123@gmail.comE<gt>

=cut

