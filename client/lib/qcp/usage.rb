$usage = <<END
Usage:

    qcp init <server>

        Create or update the password for an account.
        Example: tome set foo@gmail.com

    qcp cp <content>

        Generate and copy a random password for an account.
        Example: tome generate reddit.com

    qcp paste

        Show the passwords for all accounts matching the pattern.
        Example: tome get youtube

    qcp help

        Shows help for a specific command.
        Example: qcp help copy

    qcp version

        Shows the version of qcp.
        Example: qcp version
END

$help = <<END
qcp help

    Shows help for a specific command.

Usage:

    qcp help
    qcp help <command>

Examples:

    qcp help
    qcp help cp
    qcp help help (so meta)

Alias: help, --help, -h
END

$init_usage = <<END
qcp init

    Create or update the password for an account. The user is optional.
    If you do not specify a password, you will be prompted for one.

Usage:

    qcp init <server>

Examples:

    qcp init https://myqcp.herokuapp.com 

Alias: init, i
END

$copy_usage = <<END
qcp cp

    Show the passwords for all accounts matching the pattern.
    Matching is done with substring search. Wildcards are not supported.

Usage:

    qcp cp <content>

Examples:

    qcp cp hello!
    qcp cp multiple words
    qcp cp "words  with  more  spaces"
    qcp cp http://some.really/long/url.html

Alias: copy, cp, c
END

$paste_usage = <<END
qcp paste

    Delete the password for an account.

Usage:

    qcp paste

Examples:

    qcp paste

Alias: paste, p
END
