clear all
close all
clc

%% Setup Experiment Parameters
cfg = [];

%-- Input device
cfg.response.until_release = true;
cfg.response.escape = 'ESCAPE';
cfg.response.pause = 'p';
cfg.response.port = 'keyboard';
cfg.response.keys = {'q', 's'};
cfg.response.t_max = inf;

%-- General
cfg.n_trials = 20;
cfg.task = 'angle'; % TODO vary task with spatial_frequency
cfg.soa = .050; % 1/60. * 4; % TODO vary SOA
cfg.duration = 0.032;% cfg.soa - 1/60.;
cfg.n_stimuli = 20; % number of stim per trial

%-- Gabors
cfg.gabor.n = 6;  % number of different items
cfg.gabor.angles = linspace(0+180/(2*cfg.gabor.n), 180-180/(2*cfg.gabor.n), cfg.gabor.n);
cfg.gabor.spatial_frequencies = linspace(20, 50, cfg.gabor.n);
cfg.gabor.sigma = 80;  % spatial spread
cfg.gabor.contrasts = 1.;
cfg.gabor.phases = linspace(0, 2 * pi, cfg.gabor.n);

mask = [];
mask.lambda = mean(cfg.gabor.spatial_frequencies);  % spatial frequency
mask_grating = make_circular_gabor(mask);  % bitmap
mask_grating = repmat(255*(mask_grating+1)/2, [1, 1, 3]);  % RGB

%% Start Experiment
window = start_psychtb(1);
bw2gw = @(x) min(x/2,255);  % ensure adequate 255 values
random_value = @(x) x(randi(length(x)));  % random selector
add_fixation = @() Screen('FrameOval', window.window, [0 255 0], [Sc.center-(5) Sc.center+(5)],30,2);
mask_pointer  = Screen('MakeTexture', window.window, mask_grating);

%% Run Experiment
trials = [];  % TODO make pseudo randomization
for trial = 1:cfg.n_trials
  disp(trial);
  clear time

  %% Setup stimuli for given trial
  stim_list = [];
  for stim = 1:cfg.n_stimuli
    % TODO: clear graphic card
    % TODO: make pseudo randomization prior to experiment
    % setup gabor parameter for each stimulus
    gabor = [];
    gabor.sigma = cfg.gabor.sigma;
    gabor.contrast = random_value(cfg.gabor.contrasts);
    gabor.orientation = random_value(cfg.gabor.angles);  % /!\ FIXME in degrees
    gabor.lambda = random_value(cfg.gabor.spatial_frequencies);
    gabor.phase = random_value(cfg.gabor.phases);  % /!\ in radians
    % generate image
    bitmap = make_gabor(gabor) * gabor.contrast;
    bitmap_rgb = repmat(255 * (bitmap + 1) / 2, [1, 1, 3]);
    % load in graphic card
    pointer = Screen('MakeTexture', window.window, bitmap_rgb);
    stim_list(stim) = pointer;
  end
  % Add mask at beginning and end of sequence
  stim_list = [mask_pointer; stim_list(:); mask_pointer];


  %% Present stimuli
  %-- start
  add_fixation;
  trials(trial).time_start = Screen('Flip', window.window);
  % TODO: add jitter
  trials(trial).time_onsets = [];
  trials(trial).time_offsets = []; 
  for stim = 1:length(stim_list)
    %-- onset
    t_onset = trials(trial).time_start + cfg.soa * stim;
    add_fixation;
    Screen('DrawTexture',window.window, stim_list(stim));
    trials(trial).time_onsets(stim) = Screen('Flip', window.window, t_onset);
    % TODO: draw photodiod
    % TODO: TTL onsets
    %-- offset
    t_offset = trials(trial).time_start + cfg.soa * stim + cfg.duration;
    add_fixation;
    trials(trial).time_offsets(stim) = Screen('Flip', window.window, t_offset);
    % TODO: TTL offset
  end

  %% Get response
  [resp response_time response_code] = collect_response(cfg.response, cfg.response.t_max);
  % TODO: deal with missing response
  trials(trial).response_time = response_time;
  trials(trial).response_RT = response_time - trials(trial).time_offsets(stim);
  trials(trial).response_code = response_code;

  %% Compute true value
  if strcmp(cfg.task, 'angle')
    % TODO
  elseif strcmp(cfg.task, 'spatial_frequency')
    % TODO
  end


  %% compute accuracy
  % TODO

  %% Get visibility
  % TODO

end

Screen('CloseAll');
ListenChar(0);
DisableKeysForKbCheck([]);
ShowCursor()
