function gabor = make_gabor(cfg)
% parameters
if ~isfield(cfg,'imsize'),  cfg.imsize  = 600;      end % image size: n X n
% wavelength (number of pixels per cycle)
if ~isfield(cfg,'lambda') || cfg.lambda == 0 || isnan(cfg.lambda),
    cfg.lambda  = 10;
end
if ~isfield(cfg,'orientation') || cfg.orientation == 0 || isnan(cfg.orientation),
    cfg.orientation   = 10;
end % grating orientation
if ~isfield(cfg,'sigma'),   cfg.sigma   = 90;      end % gaussian standard deviation in pixels
if ~isfield(cfg,'phase'),   cfg.phase   = .25;      end % cfg.phase (0 -> 1)
if ~isfield(cfg,'trim'),    cfg.trim    = .005;     end % cfg.trim off gaussian values smaller than this
if ~isfield(cfg,'cgRGB'),   cfg.cgRGB   = false;    end % get a RGB value
if ~isfield(cfg,'color'),   cfg.color   = [1 1 1];  end
if ~isfield(cfg,'square_gauss'),cfg.square_gauss  = 0;  end  %e.g. .15 size of the circle if no gaussian. Put it down to 0 to keep a gradient gaussian

% make linear ramp
X           = 1:cfg.imsize;                             % X is a vector from 1 to imageSize
X0          = (X / cfg.imsize) - .5;                    % rescale X -> -.5 to .5

% plot a one-dimensional sinewave
%sinX        = sin(X0 * 2*pi);                           % convert to radians and do sine

% mess about with wavelength and cfg.phase
freq        = cfg.imsize/cfg.lambda;                    % compute frequency from wavelength
Xf          = X0 * freq * 2*pi;                         % convert X to radians: 0 -> ( 2*pi * frequency)
%sinX        = sin(Xf) ;                                 % make new sinewave
cfg.phaseRad= (cfg.phase * 2* pi);                      % convert to radians: 0 -> 2*pi
%sinX        = sin( Xf + cfg.phaseRad) ;                 % make cfg.phase-shifted sinewave

% Now make a 2D grating
% Start with a 2D ramp use meshgrid to make 2 matrices with ramp values across columns (Xm) or across rows (Ym) respectively
[Xm Ym]     = meshgrid(X0, X0);                         % 2D matrices

% Put 2D ramps through sine
Xf          = Xm * freq * 2*pi;
%grating     = sin( Xf + cfg.phaseRad);                  % make 2D sinewave

% Change orientation by adding Xm and Ym together in different proportions
cfg.thetaRad= (cfg.orientation / 360) * 2*pi;                 % convert cfg.orientation (orientation) to radians
Xt          = Xm * cos(cfg.thetaRad);                   % compute proportion of Xm for given orientation
Yt          = Ym * sin(cfg.thetaRad);                   % compute proportion of Ym for given orientation
XYt         = Xt + Yt;                                  % sum X and Y components
XYf         = XYt * freq * 2*pi;                        % convert to radians and scale by frequency
grating     = sin( XYf + cfg.phaseRad);                 % make 2D sinewave
gratingR    = grating .* cfg.color(1);
gratingG    = grating .* cfg.color(2);
gratingB    = grating .* cfg.color(3);

% Make a gaussian mask
% first look at the 1D function
s           = cfg.sigma / cfg.imsize;                   % gaussian width as fraction of imageSize
Xg          = exp( -( ( (X0.^2) ) ./ (2* s^2) ));       % formula for 1D gaussian
Xg          = normpdf(X0, 0, (20/cfg.imsize));
Xg          = Xg/max(Xg);                               % alternative using normalized probability function (stats toolbox)

% Make 2D gaussian blob
gauss       = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) );  % formula for 2D gaussian

 x=(1+gauss).^2-1;
 x(x>1) = 1;
 gauss = x;

% Now multply grating and gaussian to get a GABOR
gauss(gauss < cfg.trim) = 0;                            % cfg.trim around edges (for 8-bit colour displays)

if cfg.square_gauss ~= 0
    gauss = gauss > cfg.square_gauss;
end

gabor       = grating .* gauss;
gaborR      = gratingR .* gauss;
gaborG      = gratingG .* gauss;
gaborB      = gratingB .* gauss;

% colors
if cfg.cgRGB
    gabor = ([...
        (reshape(gaborR,1,[]))' ...
        reshape(gaborG,1,[])' ...
        reshape(gaborB,1,[])'] + 1)./2;
end
return
