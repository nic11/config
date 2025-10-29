import os
import subprocess
from ranger.api.commands import Command
from ranger.container.file import File
from ranger.ext.get_executables import get_executables

# https://github.com/ranger/ranger/wiki/Custom-Commands
class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        from os.path import join, expanduser, lexists
        from os import makedirs
        import re

        dirname = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if not lexists(dirname):
            makedirs(dirname)

            match = re.search('^/|^~[^/]*/', dirname)
            if match:
                self.fm.cd(match.group(0))
                dirname = dirname[match.end(0):]

            for m in re.finditer('[^/]+', dirname):
                s = m.group(0)
                if s == '..' or (s.startswith('.') and not self.fm.settings['show_hidden']):
                    self.fm.cd(s)
                else:
                    ## We force ranger to load content before calling `scout`.
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console('scout -ae ^{}$'.format(s))
        else:
            self.fm.notify("file/directory exists!", bad=True)

# https://github.com/ranger/ranger/wiki/Custom-Commands
class YankContentWl(Command):
    def execute(self):
        if "wl-copy" not in get_executables():
            self.fm.notify("wl-clipboard is not found.", bad=True)
            return

        arg = self.rest(1)
        if arg:
            if not os.path.isfile(arg):
                self.fm.notify("{} is not a file".format(arg))
                return
            file = File(arg)
        else:
            file = self.fm.thisfile
            if not file.is_file:
                self.fm.notify("{} is not a file".format(file.relative_path))
                return
        if file.is_binary or file.image:
            with open(file.path, 'r') as f:
                subprocess.run(
                    ['wl-copy'],
                    stdin=f,
                    check=True,
                )
        else:
            self.fm.notify("{} is not an image file or a text file".format(file.relative_path))

class restart(Command):
    def execute(self):
        os.execl(f"{os.environ['N11_CONF']}/bin/ranger-mycfg", f"{os.environ['N11_CONF']}/bin/ranger-mycfg")

class kitty(Command):
    def execute(self):
        subprocess.run(
            ['kitty', '--detach', f"{os.environ['N11_CONF']}/bin/ranger-mycfg"],
            check=True
        )
