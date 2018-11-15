# ============================================================================
# FILE: npm.py
# AUTHOR: Qiming Zhao <chemzqm@gmail.com>
# CREATED: Nov 15, 2018
# ============================================================================
# pylint: disable=E0401,C0411
import sys
from os.path import dirname
sys.path.append(dirname(dirname(__file__)))
from .npm.base import Kind as Base

class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)

        self.persist_actions += ['delete', 'update'] #pylint: disable=E1101
        self.redraw_actions += ['delete', 'update'] #pylint: disable=E1101
        self.default_action = 'open'
        self.name = 'npm'

    def action_update(self, context):
        arg = ' '.join(map(lambda x: x['word'], context['targets']))
        cmd = 'npm update %s' % (arg, )
        self.vim.call('npm#run_command', cmd)

    def action_find(self, context):
        target = context['targets'][0]
        name = target['source__name']
        self.vim.command('Denite func:m:%s' % name)

    def action_delete(self, context):
        arg = ' '.join(map(lambda x: x['word'], context['targets']))
        cmd = 'npm uninstall %s' % (arg, )
        self.vim.call('npm#run_command', cmd)
