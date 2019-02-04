package tap;
# ABSTRACT: add a tap method everywhere

use warnings;
use strict;

use vars qw($AUTOLOAD);
use constant PREFIX_LENGTH => length('tap::');

=head1 SYNOPSIS

  use tap;

  return Some::Class->new
    ->tap::color('red')
    ->tap::smell('roses');

  # rather than:

  my $o = Some::Class->new;
  $o->color('red')
  $o->smell('roses');
  return $o;

=head1 DESCRIPTION

C<tap> is a method that wraps any other method, ignoring its result and
returning the invocant instead.  This allows you to make chaining method out of
anything, such a setters that return what you just set, or to peek into
a method chain.

This module gets you access to tap anywhere, without requiring it to exist in
a parent class or an imported lexical.

=head1 METHODS

=head2 tap::*

  $o->tap::color('red')
    ->tap::smell('roses')
    ->...;

For use when you know what existing method you want to call.  This is
implemented using AUTOLOAD, which follows the common behavior of installing
a method so you only fall to AUTOLOAD once.

It's not as fast as writing things out the long way, but it's the fastest of
all tap-like features I've seen.  And I think it's convenient while looking
nice.  I was using it in L<Reply> for quite a while before making it a module.

=cut

sub AUTOLOAD {
  my ($self, @args) = @_;
  my $method = substr($AUTOLOAD, PREFIX_LENGTH())
    or return;

  eval sprintf(<<'END_PERL', $method) unless $method eq 'tap';
    sub %1$s {
      my $self = shift;
      $self->%1$s(@_);
      $self;
    }
END_PERL

  $self->$method(@args);
  $self;
}

=head2 tap::tap

  $o->tap::tap($method => 42)->...;

  # slip debugging into a chain
  use DDP;
  $o->tap::tap(\&p)->run;
 
For when the method name is dynamic, or you want to pass a coderef to be called
as a method.  For convenience the invocant is topicalized (C<$_>) as well:

  $o->tap::tap(sub { $_->foo->bar(42) })->run;

=cut

sub tap {
  my ($self, $method) = (shift, shift);
  $self->$method(@_) for $self;
  $self;
}

=head1 SEE ALSO

L<Object::Tap>, L<Object::Util>, L<Mojo::Base> - other taps

L<curry> - interface inspiration

=head1 PERFORMANCE

The following example benchmark (C<ex/bench.pl>) was run with perl 5.26.0 on
a 2015 MacBook Pro.

                    Rate tap-tap Object::Tap tap-reftap own-tap tap-autoload no-tap
  tap-tap       650759/s      --         -1%        -5%    -14%         -30%   -49%
  Object::Tap   656455/s      1%          --        -5%    -13%         -29%   -48%
  tap-reftap    688073/s      6%          5%         --     -9%         -26%   -46%
  own-tap       755668/s     16%         15%        10%      --         -18%   -40%
  tap-autoload  925926/s     42%         41%        35%     23%           --   -27%
  no-tap       1265823/s     95%         93%        84%     68%          37%     --
  perl -l ex/bench.pl  26.30s user 0.04s system 99% cpu 26.362 total

As mentioned earlier, the fastest case C<no-tap> is just not using tap - but
where's the fun in that?

The three slowest cases are L</tap::tap>, L<Object::Tap>, and saving
a reference to L</tap::tap>, similar to what you get with Object::Tap.  The
next case, C<own-tap>, is just the object having its own tap method, which
should also be similar to having it in a parent class.  C<tap-autoload> is
L</tap::*>, which edges the others out by making the C<tap> package its own
sort of method lookup cache.  The trade-off is a package that grows at runtime.

I'm open to any other ideas to do even better, I've considered some myself, but
it's also not bad to just avoid using tap in very hot code.

=cut

1;
