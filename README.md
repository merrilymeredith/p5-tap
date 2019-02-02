# NAME

tap - add a tap method everywhere

# VERSION

version 0.001

# SYNOPSIS

    use tap;

    return Some::Class->new
      ->tap::color('red')
      ->tap::smell('roses');

    # rather than:

    my $o = Some::Class->new;
    $o->color('red')
    $o->smell('roses');
    return $o;

# DESCRIPTION

`tap` is a method that wraps any other method, ignoring its result and
returning the invocant instead.  This allows you to make chaining method out of
anything, such a setters that return what you just set, or to peek into
a method chain.

This module gets you access to tap anywhere, without requiring it to exist in
a parent class or an imported lexical.

# METHODS

## tap::\*

    $o->tap::color('red')
      ->tap::smell('roses')
      ->...;

For use when you know what existing method you want to call.  This is
implemented using AUTOLOAD, which follows the common behavior of installing
a method so you only fall to AUTOLOAD once.  It's not as fast as writing things
out the long way, but it's the fastest of all tap-like features I've seen.

## tap::tap

    $o->tap::tap($method => 42)->...;

    # slip debugging into a chain
    use DDP;
    $o->tap::tap(\&p)->run;

For when the method name is dynamic, or you want to pass a coderef to be called
as a method.  For convenience the invocant is topicalized (`$_`) as well:

    $o->tap::tap(sub { $_->foo->bar(42) })->run;

# SEE ALSO

[Object::Tap](https://metacpan.org/pod/Object::Tap), [Object::Util](https://metacpan.org/pod/Object::Util), [Mojo::Base](https://metacpan.org/pod/Mojo::Base) - other taps

[curry](https://metacpan.org/pod/curry) - interface inspiration

# AUTHOR

Meredith Howard <mhoward@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Meredith Howard.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
