#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;

use FindBin;
use lib "$FindBin::Bin/../lib";

use tap;
use Object::Tap qw($_tap);

use Benchmark qw(cmpthese);

package Foo {
  sub new { bless {}, shift }
  sub color {
    $_[0]->{color} = $_[1];
  }
  sub finish {
    $_[0]->{finish} = $_[1];
  }
};

# use DDP;
# Foo->new
#   ->tap::color('pink')
#   ->tap::finish('matte')
#   ->tap::tap(\&p);

cmpthese 3_000_000, {
  'tap-autoload' => sub {
    Foo->new
      ->tap::color('pink')
      ->tap::finish('matte')
  },
  'tap-tap' => sub {
    Foo->new
      ->tap::tap(color => 'pink')
      ->tap::tap(finish => 'matte')
  },
  'tap-reftap' => sub {
    state $tap = \&tap::tap;
    Foo->new
      ->$tap(color => 'pink')
      ->$tap(finish => 'matte')
  },
  'Object::Tap' => sub {
    Foo->new
      ->$_tap(color => 'pink')
      ->$_tap(finish => 'matte')
  },
  'no-tap' => sub {
    my $foo = Foo->new;
    $foo->color('pink');
    $foo->finish('matte');
    $foo
  },
};
