use strict;
use warnings;

use Test::More;

use metaclass;

# meta classes
{
    package Foo::Meta::Instance;
    use parent 'Class::MOP::Instance';

    package Bar::Meta::Instance;
    use parent 'Class::MOP::Instance';

    package FooBar::Meta::Instance;
    use parent -norequire => 'Foo::Meta::Instance', 'Bar::Meta::Instance';
}

$@ = undef;
eval {
    package Foo;
    BEGIN { $INC{'Foo.pm'} = __FILE__ }
    metaclass->import('instance_metaclass' => 'Foo::Meta::Instance');
};
ok(!$@, '... Foo.meta => Foo::Meta is compatible') || diag $@;

$@ = undef;
eval {
    package Bar;
    BEGIN { $INC{'Bar.pm'} = __FILE__ }
    metaclass->import('instance_metaclass' => 'Bar::Meta::Instance');
};
ok(!$@, '... Bar.meta => Bar::Meta is compatible') || diag $@;

$@ = undef;
eval {
    package Foo::Foo;
    use parent -norequire => 'Foo';
    metaclass->import('instance_metaclass' => 'Bar::Meta::Instance');
};
ok($@, '... Foo::Foo.meta => Bar::Meta is not compatible') || diag $@;

$@ = undef;
eval {
    package Bar::Bar;
    use parent -norequire => 'Bar';
    metaclass->import('instance_metaclass' => 'Foo::Meta::Instance');
};
ok($@, '... Bar::Bar.meta => Foo::Meta is not compatible') || diag $@;

$@ = undef;
eval {
    package FooBar;
    use parent -norequire => 'Foo';
    metaclass->import('instance_metaclass' => 'FooBar::Meta::Instance');
};
ok(!$@, '... FooBar.meta => FooBar::Meta is compatible') || diag $@;

$@ = undef;
eval {
    package FooBar2;
    use parent -norequire => 'Bar';
    metaclass->import('instance_metaclass' => 'FooBar::Meta::Instance');
};
ok(!$@, '... FooBar2.meta => FooBar::Meta is compatible') || diag $@;

done_testing;
