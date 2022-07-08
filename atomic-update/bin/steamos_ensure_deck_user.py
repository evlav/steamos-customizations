#!/usr/bin/env python3
# -*- mode: sh; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# vim: et sts=4 sw=4

#  SPDX-License-Identifier: LGPL-2.1+
#
#  Copyright © 2020-2021 Collabora Ltd.
#  Copyright © 2020-2021 Valve Corporation.
#
#  This file is part of steamos-customizations.
#
#  steamos-customizations is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation; either version 2.1 of the License,
#  or (at your option) any later version.

# Usage: steamos-ensure-deck-user
# Checks if deck user exists in other partition's /etc/passwd and is in the given groups
# in /etc/group and has the given uid
# If any of the above is not true, tries to fix.
# If unable to fix, logs an error to system log and exits 1
# Exits 0 on success

''' Make sure the deck user exists and is in the expected groups.'''

import grp
import os
import pwd
import subprocess
import sys

# Make sure we are running as root
if os.geteuid() != 0:
    print("Script must be executed as root")
    sys.exit(1)

# Some defines of exit codes, etc.
USER_ADD_UID_EXISTS = 4
USER_ADD_EXISTS = 9

# Unexpected error, happens when we try to unlock, but no password is set
PASSWD_ERROR = 3

USERNAME = "deck"
UID = 1000
# deck not needed here, it's implicit in /etc/passwd
GROUPS = {"wheel":998}


def rename_user(username, oldname):
    ''' Rename oldname user back to username.
    Also change their home dir back to original /home/{username}, moving as needed
    Returns True on success, False otherwise
    '''
    command = ['usermod', '-d', '/home/' + username]

    if not os.path.isdir('/home/' + username):
        # Home doesn't exist, so move existing name to old name
        command.append('-m')

    command.extend(['-l', username, oldname])

    rename_process = subprocess.run(command, check=False)

    if rename_process.returncode != 0:
        print("User rename failed. Bailing")
        return False

    return True


def create_user(username, uid, addgroup):
    ''' Create given user with default home dir (creating if needed)
    username is the name to use
    uid is an integer of the uid to use
    addgroup is whether to include -g username argument
    Returns the exit code of the useradd process for checking
    '''
    command = ['useradd',
               '-u', str(uid),
               '-c', 'Steam Deck User',
               '-s', '/bin/bash']

    if addgroup:
        command.extend(['-g', username])
    if not os.path.isdir('/home/' + username):
        command.extend(['-m', '-d', '/home/' + username])
    command.append(username)

    add_process = subprocess.run(command, check=False)

    return add_process.returncode


def ensure_user_exists(username, uid):
    ''' Make sure given user exists with the given uid'''
    try:
        details = pwd.getpwnam(username)
    except KeyError:
        # If not, add it
        print(f"User {username} does not exist, trying to add")

        # Add user back with uid 1000
        code = create_user(username, uid, False)
        if code == USER_ADD_UID_EXISTS:
            # uid already exists, so, rename user with uid 1000 back to deck...
            print("UID exists, checking name and fixing as needed")
            # Rename back to deck
            to_rename = pwd.getpwuid(uid)
            if not rename_user(username, to_rename.pw_name):
                return False

        elif code == USER_ADD_EXISTS:
            # User add failed because group already exists, so create user adding to existing group
            code = create_user(username, uid, True)

            if code == USER_ADD_UID_EXISTS:
                # UID exists, so rename back
                to_rename = pwd.getpwuid(uid)
                if not rename_user(username, to_rename.pw_name):
                    return False

        # Since we added it also set no password
        subprocess.run(['usermod', '-p', '', username], check=False)

        # check if the above worked
        try:
            details = pwd.getpwnam(username)

        except KeyError:
            print(f"error: Failed to add user with username {username} and uid {uid}")
            return False

        # Clear password (TODO: Don't do if already set...)
        # enable_process = subprocess.run(['usermod', '-p', 'x', username], check=False)

    # Now make sure their uid is the expected 1000
    if details.pw_uid != uid:
        print(f"User {username} exists, but uid is not expected {uid}, bailing")

        return False

    # Now also enable in case it got disabled
    enable_process = subprocess.run(['passwd', '-u', username], check=False)

    if enable_process.returncode == PASSWD_ERROR:
        # No password set, so set it to *, unlock, then clear it...
        subprocess.run(['usermod', '-p', '*', username], check=False)
        enable_again = subprocess.run(['passwd', '-u', username], check=False)

        if enable_again.returncode == PASSWD_ERROR:
            print(f"Enabling {username} failed after setting password to '*', bailng")
            return False

        subprocess.run(['usermod', '-p', '', username], check=False)

    return True


def ensure_user_in_groups(username, groups):
    ''' Make sure the given user is in the given groups adding as needed '''
    groups_to_add = []
    for group in groups.keys():
        try:
            data = grp.getgrnam(group)
        except KeyError:
            print(f"Error group {group} does not exist")

            return False

        # Check if our user is in the group
        if username not in data.gr_mem:
            print(f"User {username} not in group {group}, fixing")

            groups_to_add.append(group)

    if groups_to_add:
        group_string = ','.join(groups_to_add)
        # Add user to this group (with -a to not remove from others)
        subprocess.run(['usermod', '-a', '-G', group_string, username],
                check=False)

        # check if the above worked
        for group in groups:
            new_data = grp.getgrnam(group)

            if username not in new_data.gr_mem:
                print(f"error: Attempt to add user {username} to groups {group_string} failed,"
                           " aborting.")
                return False

    return True


if not ensure_user_exists(USERNAME, UID):
    sys.exit(1)

if not ensure_user_in_groups(USERNAME, GROUPS):
    sys.exit(1)

sys.exit(0)
