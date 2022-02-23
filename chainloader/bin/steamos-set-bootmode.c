#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>

// ============================================================================
// SPDX-License-Identifier: LGPL-2.1+

// Copyright © 2022 Collabora Ltd.
// Copyright © 2022 Valve Corporation.

// This file is part of steamos-customizations.

// steamos-customizations is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 2.1 of the License,
// or (at your option) any later version.

// ============================================================================
// This setuid wrapper exposes a limited subset of steamos-bootconf's
// functionality to unprivileged callers: specifically the set-mode
// actions used to configure the well-known boot requests such as:
// reboot reboot-other update (for example). This allows things like
// steam and the plasma UI to request those update modes safely.

static char *const allowed_mode[] = {
      "shutdown",
      "update",
      "update-other",
      "reboot",
      "reboot-other",
      NULL,
};

static int set_mode (const char *const self, char *const mode)
{
    char *const argv[] = {
        BINDIR "/steamos-bootconf",
        "set-mode",
        mode,
        NULL
    };
    int e = 0;

    if (geteuid() != 0)
    {
        fprintf( stderr, "%s should be setuid root\n", self );
        return EPERM;
    }

    execv(argv[0], argv);
    e = errno;
    perror( "could not execute 'steamos-bootconf'" );
    return e;
}

static int usage (void)
{
    fprintf( stderr, "%s <", program_invocation_short_name );

    for( int m = 0; allowed_mode[m] != NULL; m++ )
        fprintf( stderr, "%s%s", m == 0 ? "" : "|", allowed_mode[m] );

    fprintf( stderr, ">\n" );
    return EINVAL;
}

int main (int argc, char **argv)
{
    if( argc != 2 )
        return usage();

    for( int m = 0; allowed_mode[m] != NULL; m++ )
    {
        if( strcmp( allowed_mode[m], argv[1] ) == 0 )
            return set_mode( argv[0], allowed_mode[m] );
    }

    return usage();
}
