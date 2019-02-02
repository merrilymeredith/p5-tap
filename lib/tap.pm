package tap;
# ABSTRACT: add a tap method everywhere

use warnings;
use strict;

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
a method so you only fall to AUTOLOAD once.  It's not as fast as writing things
out the long way, but it's the fastest of all tap-like features I've seen.

=cut

sub AUTOLOAD {
  my ($self, @args) = @_;
  my $method = our $AUTOLOAD =~ s/^tap:://r
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

=cut

1;
