# Copyright 2015 Jeffrey Kegler
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Prototype the LUIF parser

use 5.010;
use strict;
use warnings;
use Test::More tests => 1;
use English qw( -no_match_vars );
use Scalar::Util;
use Data::Dumper;

## no critic (ErrorHandling::RequireCarping);

use Marpa::R2 3.0;

my $grammar = Marpa::R2::Scanless::G->new(
    { source        => \(<<'END_OF_SOURCE'),
:default ::= action => [values]
lexeme default = latm => 1

<Lua token sequence> ::= <Lua token>+
<Lua token> ::= whitespace
<Lua token> ::= hex_number
<Lua token> ::= <numerical constant>
<Lua token> ::= '-'
<Lua token> ::= '*'
<Lua token> ::= '/'
<Lua token> ::= '%'
<Lua token> ::= '^'
<Lua token> ::= '#'
<Lua token> ::= '=='
<Lua token> ::= '~='
<Lua token> ::= '<='
<Lua token> ::= '>='
<Lua token> ::= '<'
<Lua token> ::= '>'
<Lua token> ::= '='
<Lua token> ::= '('
<Lua token> ::= ')'
<Lua token> ::= '{'
<Lua token> ::= '}'
<Lua token> ::= '['
<Lua token> ::= ']'
<Lua token> ::= ';'
<Lua token> ::= ':'
<Lua token> ::= ','
<Lua token> ::= '.'
<Lua token> ::= '..'
<Lua token> ::= '...'

<Lua token> ::= <multiline string>
:lexeme ~ <multiline string> pause => before event => 'multiline string'
<multiline string> ~ '[' opt_equal_signs '['

<Lua token> ::= <multiline comment>
:lexeme ~ <multiline comment> pause => before event => 'multiline comment'
<multiline comment> ~ '--[' opt_equal_signs '['

opt_equal_signs ~ [=]*

# Lua whitespace is locale dependant and so
# is Perl's, hopefully in the same way.
# Anyway, it will be close enough for the moment.
whitespace ~ [\s]+
hex_number ~ '0x' hex_digit hex_digit
hex_digit ~ [0-9a-fA-F]

# NuMeric representation in Lua is also not an
# exact science -- it is farmed out to the
# implementation's strtod() (for decimal)
# or strtoul() (for hex, if strtod failed).
# This is an attempt at the C90-conformant subset.
<numerical constant> ~ <C90 strtod decimal>
<numerical constant> ~ <C90 strtol hex>
<C90 strtod decimal> ~ opt_sign decimal_digits opt_exp
<C90 strtod decimal> ~ opt_sign decimal_digits '.' opt_exp
<C90 strtod decimal> ~ opt_sign '.' decimal_digits opt_exp
<C90 strtod decimal> ~ opt_sign decimal_digits '.' decimal_digits opt_exp
opt_exp ~
opt_exp ~ [eE] opt_sign decimal_digits
opt_sign ~
opt_sign ~ [-+]
<C90 strtol hex> ~ [0] [xX] hex_digits
decimal_digits ~ [0-9]+
hex_digits ~ [a-fA-F0-9]+

END_OF_SOURCE
    }
);

my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );

my $input = do { $RS = undef; <STDIN>; };
my $input_length = length $input;
my $pos = $recce->read(\$input);

READ: while (1) {

    EVENT:
    for my $event ( @{ $recce->events() } ) {
        my ($name) = @{$event};
        say STDERR "Got $name";
        if ( $name eq 'multiline string' ) {
            my ( $start, $length ) = $recce->pause_span();
            my $string = $recce->literal( $start, $length );
            $string =~ tr/\[/\]/;
            my $terminator_pos = index( $input, $string, $start );
            die "Died looking for $string"  if $terminator_pos < 0;

            # the string terminator has same length as the start of
            # string marker
            my $string_length = $terminator_pos + $length - $start;
            $recce->lexeme_read( 'multiline string', $start, $string_length );
            $pos = $terminator_pos + $length;
            next EVENT;
        } ## end if ( $name eq 'multiline string' )
        if ( $name eq 'multiline comment' ) {
            my ( $start, $length ) = $recce->pause_span();
            my $comment = $recce->literal( $start, $length );
            $comment =~ tr/\[/\]/;
            my $terminator_pos = index( $input, $comment, $start );
            die "Died looking for $comment"  if $terminator_pos < 0;

            # the comment terminator has same length as the start of
            # comment marker
            my $comment_length = $terminator_pos + $length - $start;
            $recce->lexeme_read( 'multiline comment',
                $start, $comment_length );
            $pos = $terminator_pos + $length;
            next EVENT;
        } ## end if ( $name eq 'multiline comment' )
        die("Unexpected event");
    } ## end EVENT: for my $event ( @{ $recce->events() } )
    last READ if $pos >= $input_length;
    $pos = $recce->resume($pos);
} ## end READ: while (1)

my $value_ref = $recce->value();
die "No parse was found\n" if not defined $value_ref;

# Result will be something like "86.33... 126 125 16"
# depending on the floating point precision
$Data::Dumper::Deepcopy = 1;
say Data::Dumper::Dumper($value_ref);

# vim: expandtab shiftwidth=4: