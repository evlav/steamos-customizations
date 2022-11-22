#!/usr/bin/env python3
# -*- mode: sh; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# vim: et sts=4 sw=4

# SPDX-License-Identifier: LGPL-2.1+
#
# Copyright © 2022 Collabora Ltd
#
# This package is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this package.  If not, see
# <http://www.gnu.org/licenses/>.

''' Generate some mucked up user database files using a script in given path

Backs up original files
Copies in pristine files,
Runs a script to muckup (foo/muckup.sh)
Copies result out to foo/start for committing to git
Puts original files back
'''
import os
import shutil
import subprocess
import sys
import tempfile

class LetsMuckItUp:
    '''Some helper functions from testensurescript.py '''
    def __init__(self, path):
        '''Initialize the tmp'''
        self.tmp = None
        self.path = path


    def backup_password_database(self):
        ''' Copy existing password database elsewhere for safe keeping while
            running test scenarios'''
        self.tmp = tempfile.TemporaryDirectory()
        print(f'Backing up login database to {self.tmp.name}')
        shutil.copy('/etc/passwd', self.tmp.name)
        shutil.copy('/etc/group', self.tmp.name)
        shutil.copy('/etc/shadow', self.tmp.name)
        shutil.copy('/etc/gshadow', self.tmp.name)


    def restore_password_database(self):
        ''' Put passwd, group, and shadow file back where they belong'''
        print(f'Restoring login database from {self.tmp.name}')
        shutil.copy(self.tmp.name + '/passwd', '/etc/passwd')
        shutil.copy(self.tmp.name + '/group', '/etc/group')
        shutil.copy(self.tmp.name + '/shadow', '/etc/shadow')
        shutil.copy(self.tmp.name + '/gshadow', '/etc/gshadow')

        self.tmp.cleanup()


    def copy_initial_password_database(self):
        ''' Copy passwd, gorup, and shawod files out of test scenario to initialize test'''
        shutil.copy('pristine/passwd', '/etc/passwd')
        shutil.copy('pristine/group', '/etc/group')
        shutil.copy('pristine/shadow', '/etc/shadow')
        shutil.copy('pristine/gshadow', '/etc/gshadow')


    def run_muckup_script(self, path):
        ''' Run muckup.sh from given path to tweak pristine files'''
        subprocess.run(['/bin/bash', './' + path + '/muckup.sh'], check=False)


    def copy_mucked_files(self, path):
        ''' Copy the mucked up files into given path'''
        os.makedirs(path + '/start', exist_ok=True)
        shutil.copy('/etc/passwd', path + '/start/passwd')
        shutil.copy('/etc/group', path + '/start/group')
        shutil.copy('/etc/shadow', path + '/start/shadow')
        shutil.copy('/etc/gshadow', path + '/start/gshadow')


    def generate_files(self):
        ''' Script to generate the messed up files'''
        self.backup_password_database()
        self.copy_initial_password_database()

        self.run_muckup_script(self.path)

        self.copy_mucked_files(self.path)

        # Always restore original passwords, etc. before exit
        print(f'Restoring file back from {self.tmp.name}')
        self.restore_password_database()


if __name__ == '__main__':
    muckit = LetsMuckItUp(sys.argv[1])
    muckit.generate_files()
