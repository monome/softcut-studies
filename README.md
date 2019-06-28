# softcut studies

softcut is a multi-voice sample playback and recording system build into the norns environment. it features level-smoothing, interpolated overdubbing, and matrix mixing. it was written by @zebra.

for an introduction to scripting see the norns [studies](https://monome.org/docs/norns/study-1/) and [tutorial](https://llllllll.co/t/norns-tutorial/23241).

## 1. basic playback

* see/run softcut-studies/1-basic [(source)](https://github.com/monome/softcut-studies/blob/master/1-basics.lua)

![](https://raw.githubusercontent.com/monome/softcut-studies/master/lib/1-basics.png)

first, some nomenclature:

- _voice_ --- a play/record head. mono. each has its own parameters (ie rate, level, etc). there are 6 voices.
- _buffer_ --- digital tape, there are 2 buffers. mono. just about 5 minutes each.

softcut parameters are reset when a script is loaded. to get a looping sound we need at a minimum the following, where the arguments are `(voice, value)`:

```
softcut.enable(1,1)
softcut.buffer(1,1)
softcut.level(1,1.0)
softcut.loop(1,1)
softcut.loop_start(1,1)
softcut.loop_end(1,2)
softcut.position(1,1)
softcut.play(1,1)
```

the buffers are blank. load a file (wav/aif/etc):

```
softcut.buffer_read_mono(file, start_src, start_dst, dur, ch_src, ch_dst)
```

- `file` --- the filename, full path required ie `"/home/we/dust/audio/spells.wav"`
- `start_src` --- start of file to read (seconds)
- `start_dst` --- start of buffer to write into (seconds)
- `dur` --- how much to read/write (seconds, use `-1` for entire file)
- `ch_src` --- which channel in file to read
- `ch_dst` --- which buffer to write


## 2. more voices and parameters

...

## 3. record and overdub

...

## 4. routing

...

---

## reference

- [softcut API docs](https://monome.github.io/norns/doc/modules/softcut.html)

contributions welcome: [github/monome/softcut-studies](https://github.com/monome/softcut-studies)

