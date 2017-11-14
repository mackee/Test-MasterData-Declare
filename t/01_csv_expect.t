use strict;
use warnings;
use Test::More;
use Test::MasterData::Declare;

master_data {
    load_csv item => "t/item.csv";

    expect_row item => sub {
        my $row = shift;
        like $row->{id}, qr/\A[0-9]+\z/;
    };
};

done_testing;
