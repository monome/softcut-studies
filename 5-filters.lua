-- softcut study 5: filters
-- sample playing on voice 1
-- audio input echo on voice 2
--
-- E1 rate
-- E2 low pass freq voice 1
-- E3 band pass freq voice 2

file = _path.dust.."/code/softcut-studies/lib/whirl1.aif"
rate = 1.0
low = 8000
band = 2000

-- softcut's pre- and post-filters clamp values below 10Hz and above 12000Hz
-- here we specify the max and min values for the encoders
max_freq = 12000
min_freq = 200

function init()
  audio.level_adc_cut(1)
  softcut.level_input_cut(1,2,1.0)
  softcut.level_input_cut(2,2,1.0)

  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,1,1)

  for i=1,2 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    softcut.rate(i,rate)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.position(i,1)
    softcut.play(i,1)
  end

  softcut.loop_end(1,3.42)
  softcut.loop_end(2,1.25)

  softcut.rec(2,1)
  softcut.rec_level(2,0.5)
  softcut.pre_level(2,0.75)

  -- set voice 1 (sample playback) post-filter
  -- set voice 1 dry level to 0.0
  softcut.post_filter_dry(1,0.0)
  -- set voice 1 low pass level to 1.0 (full wet)
  softcut.post_filter_lp(1,1.0)
  -- set voice 1 filter cutoff
  softcut.post_filter_fc(1,low)
  -- set voice 1 filter rq (flattish)
  softcut.post_filter_rq(1,10)

  -- set voice 2 (echo recorder) pre-filter
  -- set voice 2 dry level to 0.0
  softcut.pre_filter_dry(2,0.0)
  -- set voice 2 band pass level to 1.0 (full wet)
  softcut.pre_filter_bp(2,1.0)
  -- set voice 2 filter cutoff
  softcut.pre_filter_fc(2,band)
  -- set voice 2 filter rq (peaky)
  softcut.pre_filter_rq(2,1)
end

function enc(n,d)
  if n==1 then
    rate = util.clamp(rate+d/100,-4,4)
    softcut.rate(1,rate)
  elseif n==2 then
    low = util.clamp(low+d*200,min_freq,max_freq)
    softcut.post_filter_fc(1,low)
  elseif n==3 then
    band = util.clamp(band+d*1000,min_freq,max_freq)
    softcut.pre_filter_fc(2,band)
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
  screen.text("low (voice 1): ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",low))
  screen.move(10,50)
  screen.text("band (voice 2): ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",band))
  screen.update()
end
