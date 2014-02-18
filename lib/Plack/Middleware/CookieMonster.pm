package Plack::Middleware::CookieMonster;
use strict;
use warnings;

use parent qw/ Plack::Middleware /;

use Plack::Util::Accessor qw( cookie_names );
use Plack::Request;


sub call {
    my ( $self, $env ) = @_;

    my $res = $self->app->( $env );

    if ( $res->[ 0 ] == 500 && $env->{ 'plack.stacktrace.html' } ) {
        my @cookies = $self->_get_cookie_names( $env );
        foreach my $cookie ( @cookies ) {
            push @{ $res->[ 1 ] }, 'Set-Cookie', sprintf '%s=deleted; Expires=Thu, 01-May-1971 04:30:01 GMT', $cookie;
        }
    }

    return $res;
}

sub _get_cookie_names {
    my ( $self, $env ) = @_;

    my $sent = Plack::Request->new( $env )->cookies;

    if ( my $cookie_names = $self->cookie_names ) {
        return grep { $sent->{ $_ } } @$cookie_names;
    }
    else {
        return keys %$sent;
    }
}

1;

__END__

=head1 NAME

Plack::Middleware::CookieMonster - Eats all your (session) cookies in case Plack::Middleware::StrackTrace ate your HTTP headers.

=head1 SYNOPSIS

 # Only expire selected cookies
 enable 'CookieMonster', cookies_names => [ 'session_cookie', 'foobar_cookie' ];
 enable 'StackTrace';


 # Expire all cookies the browser sent
 enable 'CookieMonster';
 enable 'StackTrace';

=head1 DESCRIPTION

When developing a plack application with Plack::Middleware::StackTrace enabled,
you may sometimes find yourself in a situation where your current session for
your webapp is borked. Your app would usually clear any session cookies in that
case, but since Plack::Middleware::StackTrace will simply throw away any HTTP
headers you set, you'll be stuck to that session.

C<Plack::Middleware::CookieMonster> will detect that C<Plack::Middleware::StackTrace>
rendered a stack trace and will add C<Set-Cookie> headers to the response so that
the cookies you configured or all cookies that the browser sent will be expired.

This middleware was written because I was too lazy to search the "clear cookies"
control in my browser and because I think we should automate as much as possible.

=head1 CONFIGURATION

You can provide a C<cookie_names> parameter, pointing to an array-ref containing
the names of all the cookies you want to clear. Otherwise, all cookies the browser
sent will be expired.

=head1 AUTHOR

Manni Heumann

=head1 SEE ALSO

L<Plack::Middleware::StackTrace>

=cut

