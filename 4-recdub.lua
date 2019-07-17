-- softcut study 4
-- record and overdub
-- audio input required
--
-- E1 rate
-- E2 rec level
-- E3 pre level
-- K2 toggles rec
-- K3 toggles pre

rate = 1.0
rec = 1.0
pre = 0.0

function init()
  -- send audio input to softcut input
	audio.level_adc_cut(1)
  
  softcut.buffer_clear()
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.level(1,1.0)
  softcut.loop(1,1)
  softcut.loop_start(1,1)
  softcut.loop_end(1,3)
  softcut.position(1,1)
  softcut.play(1,1)

  -- set input rec level: input channel, voice, level
  softcut.level_input_cut(1,1,1.0)
  softcut.level_input_cut(2,1,1.0)
  -- set voice 1 record level 
  softcut.rec_level(1,rec)
  -- set voice 1 pre level
  softcut.pre_level(1,pre)
  -- set record state of voice 1 to 1
  softcut.rec(1,1)
end

function enc(n,d)
  if n==1 then
    rate = util.clamp(rate+d/100,-4,4)
    softcut.rate(1,rate)
  elseif n==2 then
    rec = util.clamp(rec+d/100,0,1)
    softcut.rec_level(1,rec)
  elseif n==3 then
    pre = util.clamp(pre+d/100,0,1)
    softcut.pre_level(1,pre)
  end
  redraw()
end

function key(n,z)
  if n==2 and z==1 then
    if rec==0 then rec = 1 else rec = 0 end
    softcut.rec_level(1,rec)
  elseif n==3 and z==1 then
    if pre==1 then pre = 0 else pre = 1 end
    softcut.pre_level(1,pre)
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,30)
  screen.text("rate: ")
  screen.move(118,30)
  screen.text_right(string.format("%.2f",rate))
  screen.move(10,40)
  screen.text("rec: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",rec))
  screen.move(10,50)
  screen.text("pre: ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",pre))
  screen.update()
end

