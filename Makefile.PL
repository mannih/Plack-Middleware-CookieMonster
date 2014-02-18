#!/usr/bin/env perl
use inc::Module::Install 1.01;

name 'Plack-Middleware-CookieMonster';

all_from 'lib/Plack/Middleware/CookieMonster.pm';

repository 'http://github.com/mannih/Plack-Middleware-CookieMonster.git';

requires 'Plack';
test_requires 'Test::Most';
test_requires 'HTTP::Request::Common';

auto_install;
WriteAll;

