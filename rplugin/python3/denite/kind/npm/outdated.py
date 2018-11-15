# ============================================================================
# FILE: npm.py
# AUTHOR: Qiming Zhao <chemzqm@gmail.com>
# CREATED: Nov 15, 2018
# ============================================================================
# pylint: disable=E0401,C0411
import sys
from os.path import dirname
sys.path.append(dirname(dirname(__file__)))
from .base import Kind as Base

class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'npm/oudated'

    def action_update(self, context):
        args = ' '.join(map(lambda x: x['source__name'], context['targets']))
        cmd = 'npm update %s' % args
        self.vim.call('npm#run_command', cmd)

    def action_upgrade(self, context):
        args = ' '.join(map(lambda x: x['source__name'] + '@latest', context['targets']))
        cmd = 'npm install %s' % args
        self.vim.call('npm#run_command', cmd)
