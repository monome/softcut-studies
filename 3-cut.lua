-- softcut study 3

file = "/home/we/dust/code/softcut-studies/lib/whirl1.aif"
fade_time = 0.01
metro_time = 1.0 

positions = {0,0,0,0}

m = metro.init()
m.time = metro_time
m.event = function()
  for i=1,4 do
    softcut.position(i,1+math.random(8)*0.25)
  end
end

function update_positions(i,pos)
  positions[i] = pos - 1
  redraw()
end

function init()
  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,0,0) --FIXME: ch is 0-indexed

  for i=1,4 do
    softcut.enable(i,1)
    softcut.buffer(i,1)
    softcut.level(i,1.0)
    softcut.pan(i,i*0.25)
    softcut.rate(i,i*0.25)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,3)
    softcut.position(i,1)
    softcut.play(i,1)
    softcut.fade_time(i,fade_time)
    softcut.phase_quant(i,0.125)
  end

  softcut.event_phase(update_positions)
  softcut.poll_start_phase()

  m:start()
end

function enc(n,d)
  if n==2 then
    fade_time = util.clamp(fade_time+d/100,0,1)
    for i=1,4 do
      softcut.fade_time(i,fade_time)
    end
  elseif n==3 then
    metro_time = util.clamp(metro_time+d/8,0.125,4)
    m.time = metro_time
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,20)
  screen.line_rel(positions[1]*8,0)
  screen.move(40,20)
  screen.line_rel(positions[2]*8,0)
  screen.move(70,20)
  screen.line_rel(positions[3]*8,0)
  screen.move(100,20)
  screen.line_rel(positions[4]*8,0)
  screen.stroke()

  screen.move(10,40)
  screen.text("fade time:")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",fade_time))
  screen.move(10,50)
  screen.text("metro time:")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",metro_time))
  screen.update()
end
