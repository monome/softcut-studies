-- softcut study 6
-- routing
--
-- K2 clear buffer
-- K3 reload audio file
--
-- accepts audio input

file = _path.dust.."code/softcut-studies/lib/whirl1.aif"

jumpy = 0.5
feed = 1.0
preserve = 0.25

m = metro.init()
m.time = 0.5
m.event = function()
  m.time = 0.1+math.random()*jumpy
  softcut.position(2,1+math.random()*4)
end

function init()
  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,0,0)

	audio.level_adc_cut(1)
	audio.level_adc_cut(2)
  softcut.level_input_cut(1,2,1)
  softcut.level_cut_cut(1,2,1)

  -- sample player
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.loop_start(1,1)
  softcut.loop_end(1,5)
  softcut.position(1,1)
  softcut.rate(1,1)
  softcut.play(1,1)
  softcut.level(1,1)
 
  -- record head
  softcut.enable(2,1)
  softcut.buffer(2,1)
  softcut.loop(2,1)
  softcut.loop_start(2,1)
  softcut.loop_end(2,5)
  softcut.position(2,2)
  softcut.play(2,1)
  softcut.rec(2,1)
  softcut.rec_level(2,0.75)
  softcut.pre_level(2,0.25)
  softcut.level(2,0)

  m:start()
end

function enc(n,d)
  if n==1 then
    jumpy = util.clamp(jumpy+d/20,0.5,2)
  elseif n==2 then
    feed = util.clamp(feed+d/20,0,1)
    softcut.level_cut_cut(1,2,feed)
  elseif n==3 then
    preserve = util.clamp(preserve+d/100,0,0.25)
    softcut.pre_level(2,preserve)
  end
  redraw()
end

function key(n,z)
  if n==2 and z==1 then
    softcut.buffer_clear()
  elseif n==3 and z==1 then
    softcut.buffer_read_mono(file,0,1,-1,0,0)
  end
end


function redraw()
  screen.clear()
  screen.move(10,30)
  screen.text("jumpy: ")
  screen.move(118,30)
  screen.text_right(string.format("%.2f",jumpy))
  screen.move(10,40)
  screen.text("feed: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",feed))
  screen.move(10,50)
  screen.text("preserve: ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",preserve))
  screen.update()
end

