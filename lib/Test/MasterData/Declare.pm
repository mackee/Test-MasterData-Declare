package Test::MasterData::Declare;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Test2::API qw/context/;
use Test2::Suite::Compare qw/number/;
use Test::More;

use Carp qw/croak/;

use Exporter;
our @EXPORT = qw/
    master_data
    load_csv

    like_number
    if_column
/;

use Test::MasterData::Declare::Runner;
use Test::MasterData::Declare::Reader::CSV;
use Test::MasterData::Declare::Validator;
use Test::MasterData::Declare::Filter;

{
    my $runner;

    sub master_data :prototype(&) {
        my $code = shift;
        my $ctx = context();

        $runner = Test::MasterData::Declare::Runner->new(
            context => $ctx,
            code    => $code,
        );

        $runner->run;
        $ctx->release;

        $runner = undef;
    }

    sub load_csv {
        my %paths = @_;

        for my $table_name (keys %paths) {
            my $filepath = $paths{$table_name};
            my $reader = Test::MasterData::Declare::Reader::CSV->read_from(
                table_name => $table_name,
            );
            $reader->read_from($filepath);

            $runner->add_reader_to_bucket($reader);
        }
    }

    sub table {
        my ($table_name, $column, @funcs) = @_;
    }

    sub like_number {
        my ($begin, $end, @funcs) = @_;

        return Test::MasterData::Declare::Validator->new(
            runner => $runner,
            code   => sub {
                my $value = shift;
                ok(number($value));
                cmp_ok $value, ">=", $begin;
                cmp_ok $value, "<=", $end;
            },
        );
    }

    sub if_column {
        my ($column, $cond) = @_;

        my $filter = $cond;
        if (ref $cond eq "SCALAR")
            $filter = number($cond) ?
                sub { $_[0] == $cond } :
                sub { $_[0] eq $cond };
        }

        my $code = sub {
            my $rows = shift;

            my @filtered = grep {
                $filter->($_->{$column})
            } @$rows;

            return \@filtered;
        };

        return Test::MasterData::Declare::Filter->new(
            runenr => $runner,
            code   => $code,
        );
    }
};

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

