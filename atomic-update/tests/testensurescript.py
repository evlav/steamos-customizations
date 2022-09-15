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

''' Make sure steamos_ensure_deck_user.py works as expected'''
import re

import os
import shutil
import subprocess
import sys
import tempfile
import unittest

from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, '../bin')

if sys.version_info < (3, 9, 0):
    raise unittest.SkipTest("We need at least Python 3.9 to test the ensure script")

if os.geteuid() != 0:
    print('This test requires root to run. Execute with sudo or run as root')
    raise unittest.SkipTest('This test requires root to run, skipping')

if not os.environ.get('ATOMIC_UPDATE_RUN_DESTRUCTIVE_TESTS'):
    print('To run this use:\n')
    print('ATOMIC_UPDATE_RUN_DESTRUCTIVE_TESTS=1 python testensurescript.py')
    raise unittest.SkipTest('This test requires ATOMIC_UPDATE_RUN_DESTRUCTIVE_TESTS to be set,'
        ' skipping')

data_path = Path(__file__).parent.resolve()
script_path = data_path / '../bin/steamos_ensure_deck_user.py'
print(f'Data path: {data_path}')

@dataclass
class TestScenario:
    ''' Test scenarios to check.
    description: Human readable description for scenario
    scenario_path: The path of the start and expected result password files for this scenario
    result_value: The expected exit code from running the ensure script
    '''
    description: str
    scenario_path: str
    result_value: int

test_scenarios = [
    TestScenario(
        description ='Missing deck user',
        scenario_path = './missinguser',
        result_value = 0
    ),
    TestScenario(
        description = 'Renamed deck user',
        scenario_path = './renameduser',
        result_value = 0
    ),
    TestScenario(
        description = 'Wrong groups',
        scenario_path = './wronggroups',
        result_value = 0
    ),
    TestScenario(
        description = 'Disabled deck user',
        scenario_path = './disabled',
        result_value = 0
    ),
    TestScenario(
        description = 'Wrong UID',
        scenario_path = './wronguid',
        result_value = 1
    ),
    TestScenario(
        description = 'Password set',
        scenario_path = 'passwordset',
        result_value = 0
    ),
    TestScenario(
        description = 'Another user',
        scenario_path = 'anotheruser',
        result_value = 0
    ),
]

DB_FILES = ['passwd', 'group', 'shadow', 'gshadow']

class TestEnsureScript(unittest.TestCase):
    '''Unit test for steamos_ensure_deck_user.py'''
    def __init__(self, methodName='runTest'):
        '''Initialize the unit test'''
        unittest.TestCase.__init__(self, methodName)
        self.tmp = None


    def run_ensure_script(self):
        ''' Run the steamos_ensure_deck_user.py script and return the exit code'''

        script_process = subprocess.run(['../bin/steamos_ensure_deck_user.py'],
                                        check=False)

        return script_process.returncode


    def backup_password_database(self):
        ''' Copy existing password database elsewhere for safe keeping while
            running test scenarios'''
        self.tmp = tempfile.TemporaryDirectory()
        print(f'Backing up login database to {self.tmp.name}')
        for file in DB_FILES:
            shutil.copy('/etc/' + file, self.tmp.name)


    def restore_password_database(self):
        ''' Put passwd, group, and shadow file back where they belong'''
        print(f'Restoring login database from {self.tmp.name}')
        for file in DB_FILES:
            shutil.copy(self.tmp.name + '/' + file, '/etc/' + file)

        self.tmp.cleanup()


    def copy_test_password_database(self, path):
        ''' Copy passwd, group, and shadow, gshadow files out of test scenario to initialize test'''
        for file in DB_FILES:
            shutil.copy(path + '/start/' + file, '/etc/' + file)


    def get_file_lines_sorted(self, path):
        ''' Get all the lines of given file sorted in a list'''
        with open(path, encoding='utf-8') as file:
            lines = file.readlines()
            lines = [line.rstrip() for line in lines]
            lines.sort()
            return lines

        return None


    def compare_sorted_to_result(self, scenario_path):
        ''' Compare current files in /etc to expected, but sort contents first'''
        # Don't compare these since group ids may be different... 'shadow', 'gshadow']
        for file in DB_FILES:
            expected_data = self.get_file_lines_sorted(scenario_path + '/result/' + file)
            current_data = self.get_file_lines_sorted('/etc/' + file)

            if expected_data != current_data:
                if file == 'shadow':
                    # Special case shadow since it holds a 'last date password was changed' field
                    expected_data = [re.sub(r':(\d+):', '::', s) for s in expected_data]
                    current_data = [re.sub(r':(\d+):', '::', s) for s in current_data]

                    if expected_data == current_data:
                        print('current and expected match after strpping out date changed stamps')
                        continue

                for line in expected_data:
                    if not line in current_data:
                        print(f'Expected data not found: {line}')

                for line in current_data:
                    if not line in expected_data:
                        print(f'Found data instead: {line}')

                return False

        return True


    def test_script(self):
        ''' The test script itself.
            Iterane through the scenarios testing each one'''
        self.backup_password_database()

        try:
            for data in test_scenarios:
                with self.subTest(msg=data.description):
                    print(f"\nRunning test: {data.description}")
                    # Copy initial files

                    self.copy_test_password_database(data.scenario_path)

                    result = self.run_ensure_script()

                    self.assertEqual(result, data.result_value)

                    # Run the script's checks
                    # but only if we expect the user database to be fixed
                    if data.result_value == 0:
                        self.assertEqual(self.compare_sorted_to_result(data.scenario_path), True)

        # Always restore original passwords, etc. before exit
        finally:
            print(f'Restoring file back from {self.tmp.name}')
            self.restore_password_database()

if __name__ == '__main__':
    unittest.main()
