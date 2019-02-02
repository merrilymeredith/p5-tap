package Foo;

sub new { bless {}, shift }

sub color {
  my ($self, $color) = @_;
  $self->{color} = $color;
}

sub finish {
  my ($self, $finish) = @_;
  $self->{finish} = $finish;
}

sub describe {
  my ($self) = @_;
  sprintf "Why, it's a %s, %s Foo!",
    @{$self}{'finish', 'color'};
}

1;
