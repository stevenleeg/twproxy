# TiddlyWiki Proxy
*An authenticated proxy for protecting your wiki.*

This gem provides an easy way to secure a TiddlyWiki installation so you can
expose it to the internet without having to worry about others gaining access.
The proxy provides you with a username, password and optionally a 2-factor auth
code (based on TOTP, which is compatible with [Google Authenticator](https://support.google.com/accounts/answer/1066447?hl=en)).

Although this proxy can be used as a server in itself, it's highly recommended
that you run it behind a proper webserver (such as nginx's reverse proxy) that
is secured with SSL.

## Usage
Installation:
```
$ gem install twproxy
```

Argument reference:
```
$ twproxy --help
Usage: twproxy [options]
    -p, --port PORT                  Specify port to run the proxy on. Defaults to 8888.
    -b, --bind HOSTNAME              Specify hostname to bind to. Defaults to 127.0.0.1.
    -s, --enable-ssl                 Ensures cookies are marked as secure.
    -u, --url URL                    Specify the url of the TiddlyWiki server. Defaults to http://localhost:8080.
    -g CLEARTEXT,                    Generates a SHA1 hashed password
        --generate-password
    -P, --password HASHED            Sets the user's password. Use a SHA1 hash or -g.
    -a, --auth KEY                   Sets a TOTP key for use with Google Authenticator.
    -h, --help                       Displays this help
```

## Known issues
* Currently the `Dockerfile` included with the repository is outdated. Avoid
  using it for the time being.

