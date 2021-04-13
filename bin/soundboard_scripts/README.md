Pikatea Soundboard scripting.

This set of scripts will let you use a [Pikatea GB2 Macropad](https://www.pikatea.com/collections/products/products/pikatea-macropad-gb2) as a soundboard,
with 72 slots for sounds of your choosing.

I made this up as I went along,
so I'll explain how to use this setup as best I can,
but no promises on it being useful or easy to work.

The flow is this.
1) copy the CONFIG.TXT into the macropad using the SD card it provides.
Or, edit it by hand on the SD card,
the changes are simple.
You just need F13-F17 on the presses and Shift+F13 - Shift+F17 on the holds.
This is one-time,
all the work is done in autohotkey.
2) Update the `soundboard_data.json` file with sounds of your choice.
WAV files will work.
Other filetypes may but I found them unreliable in testing.
Only the filenames are mandatory.
You should provide empty strings for name/description at least
(otherwise it might break the preprocessor/the script,
SORRY),
but they aren't actually used for anything important.
3) Run the soundboard-preprocess.py file to turn the JSON data into a function AutoHotKey can import.
I did this via WSL.
It SHOULD work with Windows-installed Python that is at least 3.6,
but I have not tested it.
4) Ensure the produced `soundboard_data.ahk` file is in the same directory as the `soundboard.ahk` file,
and all sound files you have chosen,
and the `soundboard.ahk` file itself,
are all in the same directory.
I had too much trouble trying to specify absolute paths to bother,
personally.
5) Run autohotkey file,
and your pikatea has become a soundboard!

If you update the JSON file,
you will need to run the preprocessor again,
and then afterwards reload the AHK script.
I'd like to make this one step at some point,
but I wanted to get this out there first.

The mode switch takes a bit of getting used to,
but it's plenty fast when you do,
and I enjoy the huge space I can fill up with silly sounds.
