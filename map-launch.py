#map_launch.py - Launches a map in the browser using an address from the command line or clipboard

import webbrowser, sys, paperclip
if len(sys.argv) > 1:
    # Get address from command line
    address = ' '.join(sysargv[1:])
else:
    # Get address from clipboard.
    address = pyperclip.paste()

webbrowser.open('https://www.google.com/maps/place/' + address)