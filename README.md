[![Build Status](https://travis-ci.org/l0k1/superhappyfunbubbletime.svg?branch=master)](https://travis-ci.org/l0k1/superhappyfunbubbletime)

# superhappyfunbubbletime

...definitely isn't going to be the name in the long run.

A homebrew adventure game aimed at the old grey Gameboy.

Check out [the unofficial website](http://superhappyfunbubbletime.withdraft.com) for more info. It may be out of date.

*SHFBT is currently not in a workable/playable condition. It is still pre-alpha.*

As such, if you want the ROM you have to build it yourself for now.

If there haven't been any updates in a month or two, it's because I've been busy. But SHFBT is always there, in my brain, telling me I have to come back and work on it.

### Building

I try to make sure that building works and is error free before pushing to Github. This isn't always the case, however.

I use RGBDS. I don't plan on porting it to WLA.

Dependencies are [RGBDS](https://github.com/bentley/rgbds) and make.

To make:

    cd ./superhappyfunbubbletime/
    make

### Contributing
I'm using soft-tabs, 3 spaces wide. Please use the same.

Over-comment the code. A comment on every single line is okay.

The makefile is hand-written. If you add an assembly file, you also have to add it to the make file under SOURCES.

For debugging, etc, you can use

    make debug
    
This will output .sym and .map files for your debugger/emulator of choice.

To undo the make, do a 

    make clean
    
Any makefile artists out there? A better makefile would be nice.

### License
I'm using GPL V2.

Feel free to use whatever you need to from here.
