use Test::Most;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;

test_no_stacktrace();
test_stacktrace_no_param();
test_stacktrace_with_param();

done_testing;

sub _get_app {
    my $app = sub {
        my $env = shift;
        if ( $env->{ PATH_INFO } eq '/nocrash' ) {
            return [
                200, [ 'Content-Type' => 'text/html', 'Set-Cookie', 'sessionid=2345678' ],
                ['<body>Hello World</body>']
            ];
        }
        else {
            die 'oopsie';
        }
    };
}

sub test_no_stacktrace {
    my $app = builder {
        enable 'StackTrace';
        _get_app;
    };

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/nocrash', 'Cookie' => 'sessionid=1234567' );
        is $res->code, 200, 'response status 200';
        is $res->header( 'Set-Cookie' ), 'sessionid=2345678', 'app sets a cookie';
    };
}

sub test_stacktrace_no_param {
    my $app = builder {
        enable 'CookieMonster';
        enable 'StackTrace', force => 1, no_print_errors => 1;
        _get_app;
    };

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/', 'Cookie' => 'sessionid=1234567' );
        is $res->code, 500, 'response status 500';
        is $res->header( 'Set-Cookie' ),
                'sessionid=deleted; Expires=Thu, 01-May-1971 04:30:01 GMT',
                'cookie deleted';
    };
}

sub test_stacktrace_with_param {
    my $app = builder {
        enable 'CookieMonster', cookie_names => [ 'sid' ];
        enable 'StackTrace', force => 1, no_print_errors => 1;
        _get_app;
    };

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/', 'Cookie' => 'sessionid=1234567' );
        is $res->code, 500, 'response status 500';
        is $res->header( 'Set-Cookie' ), undef, 'no cookie';
    };
}

