-- softcut study 8: copy
--
-- K1 load backing track
-- K2 random copy/paste
-- K3 save clip
-- E1 level

fileselect = require 'fileselect'

saved = "..."
level = 1.0
rec = 1.0
pre = 1.0
length = 1
position = 1
selecting = false
waveform_loaded = false
dismiss_K2_message = false

function load_file(file)
  softcut.buffer_clear_region(1,-1)
  selecting = false
  if file ~= "cancel" then
    local ch, samples = audio.file_info(file)
    length = samples/48000
    softcut.buffer_read_mono(file,0,1,-1,1,1)
    softcut.buffer_read_mono(file,0,1,-1,1,2)
    reset()
    waveform_loaded = true
  end
end

function update_positions(i,pos)
  position = (pos - 1) / length
  if selecting == false then redraw() end
end

function reset()
  for i=1,2 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(1,1.0)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,1+length)
    softcut.position(i,1)
    softcut.rate(i,1.0)
    softcut.play(1,1)
    softcut.fade_time(1,0)
  end
  update_content(1,1,length,128)
end

function copy_cut()
  local rand_copy_end = math.random(1,util.round(length))
  local rand_copy_start = math.random(1,util.round(rand_copy_end - (rand_copy_end/10)))
  local rand_dest = math.random(1,util.round(length))
  softcut.buffer_copy_mono(2,1,rand_copy_start,rand_dest,rand_copy_end-rand_copy_start,0.1,math.random(0,1))
  update_content(1,1,length,128)
end

-- WAVEFORMS
local interval = 0
waveform_samples = {}
scale = 30

function on_render(ch, start, i, s)
  waveform_samples = s
  interval = i
  redraw()
end

function update_content(buffer,winstart,winend,samples)
  softcut.render_buffer(buffer, winstart, winend - winstart, 128)
end
--/ WAVEFORMS

function init()
  softcut.buffer_clear()
  
  audio.level_adc_cut(1)
  softcut.level_input_cut(1,2,1.0)
  softcut.level_input_cut(2,2,1.0)

  softcut.phase_quant(1,0.01)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
  softcut.event_render(on_render)

  reset()
end

function key(n,z)
  if n==1 and z==1 then
    selecting = true
    fileselect.enter(_path.dust,load_file)
  elseif n==2 and z==1 then
    if waveform_loaded then
      copy_cut()
      if not dismiss_K2_message then dismiss_K2_message = true end
    end
  elseif n==3 and z==1 then
    saved = "ss7-"..string.format("%04.0f",10000*math.random())..".wav"
    softcut.buffer_write_mono(_path.dust.."/audio/"..saved,1,length,1)
  end
end

function enc(n,d)
  if n==1 then
    level = util.clamp(level+d/100,0,2)
    softcut.level(1,level)
  end
  redraw()
end

function redraw()
  screen.clear()
  if not waveform_loaded then
    screen.level(15)
    screen.move(62,50)
    screen.text_center("hold K1 to load sample")
  else
    screen.level(15)
    screen.move(62,10)
    if not dismiss_K2_message then
      screen.text_center("K2: random copy/paste")
    else
      screen.text_center("K3: save new clip")
    end
    screen.level(4)
    local x_pos = 0
    for i,s in ipairs(waveform_samples) do
      local height = util.round(math.abs(s) * (scale*level))
      screen.move(util.linlin(0,128,10,120,x_pos), 35 - height)
      screen.line_rel(0, 2 * height)
      screen.stroke()
      x_pos = x_pos + 1
    end
    screen.level(15)
    screen.move(util.linlin(0,1,10,120,position),18)
    screen.line_rel(0, 35)
    screen.stroke()
  end
  
  screen.update()
end
