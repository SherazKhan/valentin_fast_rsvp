function gabor = make_circular_gabor(cfg)
% parameters
if ~isfield(cfg,'imsize'),  cfg.imsize  = 800;      end % image size: n X n
if ~isfield(cfg,'lambda'),  cfg.lambda  = 10;       end % wavelength (number of pixels per cycle)
if ~isfield(cfg,'sigma'),   cfg.sigma   = 150;   end % gaussian standard deviation in pixels
if ~isfield(cfg,'phase'),   cfg.phase   = -.25;     end % cfg.phase (0 -> 1)
if ~isfield(cfg,'trim'),    cfg.trim    = .005;     end % cfg.trim off gaussian values smaller than this
if ~isfield(cfg,'cgRGB'),   cfg.cgRGB   = false;    end % get a RGB value
if ~isfield(cfg,'color'),   cfg.color   = [1 1 1];  end 
if ~isfield(cfg,'square_gauss'),cfg.square_gauss  = .1;  end  %e.g. .15 size of the circle if no gaussian. Put it down to 0 to keep a gradient gaussian

% make linear ramp
X           = 1:cfg.imsize;                             % X is a vector from 1 to imageSize
X0          = (X / cfg.imsize) - .5;                    % rescale X -> -.5 to .5
%-- circle equation, * 2 to get values between 0 and 1
for ii =  cfg.imsize:-1:1
    for jj =  cfg.imsize:-1:1
        Xc(ii,jj) = sqrt(((ii/ cfg.imsize -.5)^2 + (jj/ cfg.imsize -.5)^2));
    end
end
freq        = cfg.imsize/cfg.lambda;                  % compute frequency from wavelength
grating     = sin(Xc*freq*2*pi + cfg.phase * 2* pi);    % make 2D sinewave
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
[Xm Ym]     = meshgrid(X0, X0);                         % 2D matrices
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