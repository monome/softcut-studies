-- softcut study 9: query
--
-- K1 load backing track
-- E1 adjust level
-- K3 microloop
--  E2 adjust loop start
--  E3 adjust loop end

fileselect = require 'fileselect'

saved = "..."
level = 1.0
rec = 1.0
pre = 1.0
length = 1
position = 0
selecting = false
selected = false
micro_start = 0
micro_end = 0.15
microloop_length = 0.15
waveform_loaded = false
first_pass = true

screen_dirty = false
screen_timer = metro.init()
screen_timer.time = 1/15 -- 15fps
screen_timer.event = function()
  if screen_dirty and not selecting then
    redraw()
    screen_dirty = false
  end
end

function load_file(file)
  selecting = false
  if file ~= "cancel" then
    softcut.buffer_clear() -- clear buffer before loading a file
    local ch, samples = audio.file_info(file)
    length = samples/48000
    for i = 1,2 do
      softcut.buffer_read_stereo(file,0,1,-1)
    end
    update_waveform(1,1,length+1,128)
    selected = true
    first_pass = true
  end
end

function update_positions(i,pos)
  position = (pos - 1) / length
  if selecting == false then screen_dirty = true end
end

function reset()
  for i=1,2 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,1+length)
    softcut.position(i,1)
    softcut.rate(i,1.0)
    softcut.play(i,1)
    softcut.fade_time(i,0.005)
    softcut.pan(i,i == 1 and -1 or 1)
  end
  microloop_length = 0.15
end

function init()
  softcut.buffer_clear()

  softcut.phase_quant(1,0.025)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
  
  softcut.event_position(microloop)
  softcut.event_render(on_render)

  reset()
  softcut.level(1,0)
  softcut.level(2,0)
  screen_timer:start()
end

function microloop(i,pos)
  micro_start = pos - 0.01 -- 10ms allowance for reaction time
  micro_end = pos + microloop_length
  softcut.loop_start(i, micro_start)
  softcut.loop_end(i, micro_end)
  if i == 1 then
    update_waveform(1,micro_start,micro_end,128)
  end
end

function adjust_bounds(bound, d)
  if bound == 'start' then
    micro_start = util.clamp(micro_start + d/100, 1, micro_end - 0.01)
  else
    micro_end = util.clamp(micro_end + d/100, micro_start + 0.01, length+1)
  end
  microloop_length = micro_end - micro_start
  if looping then
    for i = 1,2 do
      softcut.loop_start(i, micro_start)
      softcut.loop_end(i, micro_end)
    end
    update_waveform(1,micro_start,micro_end,128)
  end
end

function key(n,z)
  if n == 1 and z == 1 then
    selecting = true
    fileselect.enter(_path.audio,load_file)
  elseif n == 3 then
    if z == 1 then
      looping = true
      for i = 1,2 do
        softcut.query_position(i)
      end
    else
      looping = false
      for i = 1,2 do
        softcut.loop_start(i,1)
        softcut.loop_end(i,1+length)
      end
      update_waveform(1,1,length+1,128)
    end
  end
end

function enc(n,d)
  if n==1 then
    level = util.clamp(level+d/100,0,1)
    for i = 1,2 do
      softcut.level(i,level)
    end
  elseif n == 2 then
    adjust_bounds('start', d)
  elseif n == 3 then
    adjust_bounds('end', d)
  end
  screen_dirty = true
end

-- WAVEFORMS
local interval = 0
waveform_samples = {}
scale = 30

function on_render(ch, start, i, s)
  waveform_samples = s
  interval = i
  waveform_loaded = true
  screen_dirty = true
  if first_pass then
    reset()
    first_pass = false
  end
end

function update_waveform(buffer,winstart,winend,samples)
  softcut.render_buffer(buffer, winstart, winend - winstart, 128)
end
--/ WAVEFORMS

function redraw()
  screen.clear()
  if waveform_loaded then
    screen.level(4)
    local x_pos = 0
    for i,s in ipairs(waveform_samples) do
      local height = util.round(math.abs(s) * (scale*level))
      screen.move(util.linlin(0,128,10,120,x_pos), 40 - height)
      screen.line_rel(0, 2 * height)
      screen.stroke()
      x_pos = x_pos + 1
    end
    screen.level(15)
    if looping then
      screen.move(util.linlin((micro_start-1)/length,(micro_end-1)/length,10,120,position),28)
    else
      screen.move(util.linlin(0,1,10,120,position),28)
    end
    screen.line_rel(0, 25)
    screen.stroke()
  end
  screen.level(15)
  screen.move(10,10)
  screen.text(saved)
  screen.move(10,20)
  screen.text("E1: level ")
  screen.move(118,20)
  screen.text_right(string.format("%.2f",level))
  screen.move(10,60)
  screen.text(micro_start~= 0 and "microloop length: "..util.round(microloop_length,0.001) or "")
  screen.update()
end