-- softcut study 2: multi
--
-- E2 rate slew
-- E3 level slew
-- K3 randomize rates/levels

file = _path.dust.."audio/common/waves/01.wav"
rate_slew = 0.1
level_slew = 2.0

function init()
  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,1,1)

  for i=1,6 do
    softcut.enable(i,1)
    softcut.buffer(i,1)
    softcut.level(i,1.0)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,2)
    softcut.position(i,1)
    softcut.play(i,1)

    softcut.rate_slew_time(i,rate_slew)
    softcut.level_slew_time(i,level_slew)
  end
  
  randomize_all()
end

function randomize_all()
  for i=1,6 do
    softcut.level(i,math.random()*0.5+0.2)
    softcut.pan(i,0.5-math.random())
    softcut.rate(i,2^(math.random(10)/2-4))
  end
end

function key(n,z)
  if n==3 and z==1 then
    randomize_all()
  end
end

function enc(n,d)
  if n==2 then
    rate_slew = util.clamp(rate_slew+d/10,0,10)
    for i=1,6 do
      softcut.rate_slew_time(i,rate_slew)
    end
  elseif n==3 then
    level_slew = util.clamp(level_slew+d/10,0,10)
    for i=1,6 do
      softcut.level_slew_time(i,level_slew)
    end
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("rate slew:")
  screen.move(118,40)
  screen.text_right(string.format("%.1f",rate_slew))
  screen.move(10,50)
  screen.text("level slew:")
  screen.move(118,50)
  screen.text_right(string.format("%.1f",level_slew))
  screen.update()
end
