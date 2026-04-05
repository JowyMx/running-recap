use strict;
use warnings;
use IO::Socket::INET;
use File::Basename;

my $port = $ENV{PORT} || 8000;
my $root = dirname(__FILE__);
$root =~ s|\\|/|g;

my %mime = (
    html => 'text/html; charset=utf-8',
    css  => 'text/css',
    js   => 'application/javascript',
    json => 'application/json',
    png  => 'image/png',
    jpg  => 'image/jpeg',
    svg  => 'image/svg+xml',
    ico  => 'image/x-icon',
);

my $server = IO::Socket::INET->new(
    LocalPort => $port,
    Type      => SOCK_STREAM,
    Reuse     => 1,
    Listen    => 10,
) or die "Cannot bind to port $port: $!\n";

print "Serving $root on http://localhost:$port\n";
$| = 1;

while (my $client = $server->accept()) {
    my $request = '';
    while (my $line = <$client>) {
        $request .= $line;
        last if $line eq "\r\n";
    }

    my ($path) = ($request =~ m{^GET\s+(\S+)\s+HTTP}i);
    $path //= '/';
    $path = '/index.html' if $path eq '/';
    $path =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;
    $path =~ s|\.\.||g;

    my $file = $root . $path;
    $file =~ s|/+|/|g;

    if (-f $file) {
        open(my $fh, '<:raw', $file) or do {
            print $client "HTTP/1.1 500 Error\r\nContent-Length: 0\r\n\r\n";
            close $client; next;
        };
        my $content = do { local $/; <$fh> };
        close $fh;

        my ($ext) = ($file =~ /\.([^.]+)$/);
        my $ct = $mime{lc($ext // '')} // 'application/octet-stream';
        my $len = length($content);

        print $client "HTTP/1.1 200 OK\r\nContent-Type: $ct\r\nContent-Length: $len\r\nConnection: close\r\n\r\n";
        print $client $content;
    } else {
        print $client "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found";
    }

    close $client;
}
