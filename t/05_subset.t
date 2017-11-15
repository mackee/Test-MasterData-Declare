use strict;
use warnings;
use utf8;

use Test::More;
use Test::MasterData::Declare::Subset;

my $subset = Test::MasterData::Declare::Subset->new(
    rows => [1..10],
);

my $i = 1;
while (my $row = $subset->next) {
    is $row, $i;
    $i++;
}

is $i, 11;

done_testing;
