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

class tabs_save(Command):
    """
    :tabs_save <filename>

    Saves all current tab paths to a file.
    """
    def execute(self):
        filename = self.arg(1)
        if not filename:
            self.fm.notify("Usage: :tabs_save <filename>", bad=True)
            return
        mode = self.arg(2) or 'create'

        filepath = os.path.expanduser(filename)
        try:
            if os.path.exists(filepath):
                self.fm.notify(f"File exists! Repeat as :tabs_save <filename> <overwrite|append>", bad=True)
                return
            with open(filepath, 'w' if mode != 'append' else 'a') as f:
                if mode == 'append':
                    print(file=f)  # append an empty line first
                print('\n'.join(map(lambda t: t.path, self.fm.tabs.values())), file=f)
            self.fm.notify(f"Tabs saved to {filepath}")
        except Exception as e:
            self.fm.notify(f"Error saving tabs: {e}", bad=True)


class tabs_load(Command):
    """
    :tabs_load <filename>

    Loads tabs from a file. Loads first path in current tab,
    and all others in new tabs.
    """
    def execute(self):
        filename = self.rest(1)
        if not filename:
            self.fm.notify("Usage: :tabs_load <filename>", bad=True)
            return

        filepath = os.path.expanduser(filename)
        if not os.path.exists(filepath):
            self.fm.notify(f"File not found: {filepath}", bad=True)
            return

        try:
            with open(filepath, 'r') as f:
                paths = [line.strip() for line in f if line.strip()]
        except Exception as e:
            self.fm.notify(f"Error reading file: {e}", bad=True)
            return

        if not paths:
            self.fm.notify("No tab paths found in file.", bad=True)
            return

        self.fm.cd(paths[0])

        for path in paths[1:]:
            self.fm.tab_new(path)

        self.fm.notify(f"Loaded {len(paths)} tabs.")
