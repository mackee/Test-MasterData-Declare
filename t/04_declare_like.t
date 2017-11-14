use strict;
use warnings;
use Test::More;
use Test::MasterData::Declare;

master_data {
    load_csv
        item => "t/fixture/item.csv",
        item_effect => "t/fixture/item_effect.csv";

    table item => "id",
        like_number 1 => 10;


    table item_effect => "effect_parameters",
        if_column effect_type => 1,
        json night_resistance =>
            like_number 1 => 100,
            sub { $_[0] % 10 == 0 };
};

done_testing;
