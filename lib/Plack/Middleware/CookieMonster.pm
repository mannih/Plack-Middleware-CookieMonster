package Plack::Middleware::CookieMonster;
use strict;
use warnings;

use parent qw/ Plack::Middleware /;

use Plack::Util::Accessor qw( cookie_names );


sub call {
    my ( $self, $env ) = @_;

    my $res = $self->app->( $env );

    if ( $res->[ 0 ] == 500 && $env->{ 'plack.stacktrace.html' } ) {
        my $cookie_names = $self->cookie_names;
        if ( ! defined $cookie_names ) {
            die "When enabling Plack::Middleware::CookieClearer you *have* to provide a 'cookie_names' argument!";
        }

        foreach my $cookie ( @{ $self->cookie_names } ) {
            push @{ $res->[ 1 ] }, 'Set-Cookie', sprintf '%s=deleted; Expires=Thu, 01-Jan-1970 00:00:01 GMT', $cookie;
        }
    }

    return $res;
}

1;

__END__

=head1 NAME

Plack::Middleware::CookieMonster - Eats all your (session) cookies in case Plack::Middleware::StrackTrace ate your HTTP headers.

=head1 SYNOPSIS

 enable CookieMonster => cookies_names => [ 'session_cookie', 'foobar_cookie' ];

=head1 DESCRIPTION

When developing a plack application with Plack::Middleware::StackTrace enabled,
you may sometimes find yourself in a situation where your current session for
your webapp is borked. Your app would usually clear any session cookies in that
case, but since Plack::Middleware::StackTrace will simply throw away any HTTP
headers you set, you'll be stuck to that session.

This middleware was written because I was too lazy to search the "clear cookies"
control in my browser and because I think we should automate as much as possible.

=head1 CONFIGURATION

You can provide a C<cookie_names> parameter, pointing to an array-ref containing
the names of all the cookies you want to clear. Otherwise, all cookies the browser
sent will be expired.

=head1 SEE ALSO

L<Plack::Middleware::StackTrace>

=cut

