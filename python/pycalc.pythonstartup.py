from math import *
from datetime import datetime as dt, timedelta as td
from typing import Union

# if you happen to read this, don't judge me...
# in my defence, it's convenient:
# >>> dd('20251011 +51d')
# datetime.datetime(2025, 12, 1, 0, 0)
# >>> dd('today +51d')
# datetime.datetime(2025, 12, 23, 0, 0)
# >>> dd('today +51d -52d')
# datetime.datetime(2025, 11, 1, 0, 0)
def dd(*args: Union[dt, td, str]):
    cur = dt.now()
    for arg_raw in args:
        if isinstance(arg_raw, dt):
            cur = arg_raw
            continue
        if isinstance(arg_raw, td):
            cur += arg_raw
            continue
        if not isinstance(arg_raw, str):
            print('invalid arg', arg_raw)
            continue
        for arg in arg_raw.split():
            if arg == '':
                continue
            if arg == 'now' or arg == 'n':
                cur = dt.now()
                continue
            if arg == 'today' or arg == 't':
                now = dt.now()
                cur = dt(year=now.year, month=now.month, day=now.day)
                continue
            if len(arg) == 8:
                cur = dt(year=int(arg[0:4]), month=int(arg[4:6]), day=int(arg[6:8]))
                continue
            sign = 0
            if arg[0] == '-':
                sign = -1
            if arg[0] == '+':
                sign = 1
            if sign == 0:
                print('invalid arg', arg)
                continue
            k = {
                'd': td(days=1),
                'm': td(days=30),
            }.get(arg[-1], 0)
            if k == 0:
                print('invalid arg', arg)
                continue
            cur += sign * float(arg[1:-1]) * k
    return cur
