#!/usr/bin/env perl

use Test2::V0;
use FindBin;
use lib $FindBin::Bin;

use tap;

use Foo;

can_ok 'tap', qw(
  AUTOLOAD
  tap
);

is do {
  Foo->new
    ->tap::color('pink')
    ->tap::finish('matte')
    ->describe
},
  "Why, it's a matte, pink Foo!",
  'autoload interface ok';

# AUTOLOAD created these
can_ok 'tap', qw(
  color
  finish
);

is do {
  Foo->new
    ->tap::tap(color => 'pink')
    ->tap::tap(finish =>'matte')
    ->describe
},
  "Why, it's a matte, pink Foo!",
  'tap interface ok';

is do {
  Foo->new
    ->tap::tap(sub { $_->color('pink') })
    ->tap::tap(sub { $_->finish('matte') })
    ->describe
},
  "Why, it's a matte, pink Foo!",
  'tap with coderef interface ok';

done_testing;
