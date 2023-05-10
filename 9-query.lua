-- softcut study 9: query
--
-- K1 load sample
-- E1 adjust level
-- K3 microloop
-- E2 adjust loop start
-- E3 adjust loop end
-- while looping:
--   K2 change rate
--   (see params)

fileselect = require 'fileselect'

level = 1
rec = 1
pre = 1
preroll = 1 -- 1 second of preroll
sample_length = 1
position = 0
micro_start = 0
micro_end = 0.15
microloop_length = micro_end - micro_start
selecting_file = false
file_selected = false
waveform_loaded = false
queued_reset = false

screen_dirty = false
screen_timer = metro.init()
screen_timer.time = 1/15 -- 15fps
screen_timer.event = function()
  if screen_dirty and not selecting_file then
    redraw()
    screen_dirty = false
  end
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

  params:add_separator('softcut_study_9_separator', 'softcut study 9')
  params:add_option('play_mode', 'play mode', {'continuous', 'bound by loop'}, 1)
  params:add_option('playback_rate', 'K2 hold playback rate', {-4,-2,-1,-0.5,0.5,1,2,4}, 3)
end

function update_positions(i,pos)
  position = (pos - preroll) / sample_length
  if selecting_file == false then screen_dirty = true end
end

function load_file(file)
  selecting_file = false
  if file ~= "cancel" then
    softcut.buffer_clear() -- clear buffer before loading a file
    local ch, samples = audio.file_info(file)
    sample_length = samples/48000
    softcut.buffer_read_stereo(file, 0, preroll, -1)
    update_waveform(1, 1, sample_length + preroll, 128)
    queued_reset = true
    file_selected = true
  end
end

function reset()
  level = 1
  microloop_length = 0.15
  for i=1,3 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i, i ~= 3 and level or 0)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,preroll + sample_length)
    softcut.position(i,1)
    softcut.rate(i,1)
    softcut.play(i,1)
    softcut.fade_time(i,0.01)
    if i ~= 3 then
      softcut.pan(i,i == 1 and -1 or 1)
    else
      softcut.pan(3,0)
    end
  end
  screen_dirty = true
end

function microloop(i,pos)
  micro_start = pos - microloop_length
  micro_end = pos
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
    micro_end = util.clamp(micro_end + d/100, micro_start + 0.01, sample_length + preroll)
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
    selecting_file = true
    fileselect.enter(_path.audio,load_file)
  elseif file_selected then
    if n == 2 and z == 1 then
      if looping == true then
        for i = 1,2 do
          softcut.rate(i,tonumber(params:string('playback_rate')))
        end
      end
    elseif n == 2 and z == 0 then
      for i = 1,2 do
        softcut.rate(i,1)
      end
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
          softcut.loop_end(i,1+sample_length)
          softcut.rate(i,1)
          if params:string('play_mode') == 'continuous' then
            softcut.voice_sync(i,3,0)
          else
            if i == 2 then
              softcut.voice_sync(2,1,0)
            end
          end
        end
        update_waveform(1, 1, sample_length + preroll, 128)
      end
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
  if queued_reset then
    reset()
    queued_reset = false
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
      local _min = (micro_start-1)/sample_length
      local _max = (micro_end-1)/sample_length
      screen.move(util.linlin(_min, _max, 10, 120, position), 28)
    else
      screen.move(util.linlin(0, 1, 10, 120, position), 28)
    end
    screen.line_rel(0, 25)
    screen.stroke()
  elseif queued_reset then
    screen.level(4)
    screen.move(64,45)
    screen.text_center('loading...')
  end
  screen.level(15)
  screen.move(10,10)
  screen.text('...')
  screen.move(10,20)
  screen.text("E1: level ")
  screen.move(118, 20)
  screen.text_right(string.format("%.2f",level))
  if micro_start ~= 0 then
    screen.move(10,60)
    screen.text("microloop length: "..util.round(microloop_length,0.001))
  end
  screen.update()
end