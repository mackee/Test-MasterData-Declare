use strict;
use warnings;
use Test::More;
use Test::MasterData::Declare;

master_data {
    load_csv
        item_effect => "t/fixture/item_effect.csv",
        effect      => "t/fixture/effect.csv";

    expect_row "item_effect" => sub {
        my $item_effect = shift;
        my @effects =
            by_the_bucket "effect" =>
                type => $item_effect->{effect_type};

        expect_by @effects => sub {
            my $effect = shift;
            my $parameter = $item_effect->{effect_parameters}{$effect->{effect_name}};
            next unless $parameter;
            cmp_ok $parameter, ">=", $effect->{bottom};
            cmp_ok $parameter, "=<", $effect->{top};
        };
    };
};

done_testing;
