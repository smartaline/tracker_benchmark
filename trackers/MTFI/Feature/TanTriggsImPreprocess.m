function Output_Im = TanTriggsImPreprocess(Input_Im, gamma, sigma0, sigma1, alpha, tao, mask)
%%  INPUT:
%       Input_Im:        the input image data;
%       gamma:           exponent for the power law (parameter for Gamma Correction);
%       sigma0:          standard deviation for the inner (smaller) Gaussian of DoG;
%       sigma1:          standard deviation for the outer (larger) Gaussian of DoG;
%       alpha:           for contrast equalization;
%       tao:             for contrast equalization;
%       mask:            the mask for face imge to avoid influence of interferences.
%
%   OUTPUT:
%       Output_Im:       image data after preprocessing.
%
%   AUTHOR:
%       Changxing Ding @ University of Technology, Sydney
%



%% Checking for Input Arguments
if nargin < 7,    mask = [];       end;
if nargin < 6,    tao = 10;        end;
if nargin < 5,    alpha = 0.1;     end;
if nargin < 4,    sigma1 = 5;      end;
if nargin < 3,    sigma0 = 1.4;    end;
if nargin < 2,    gamma = 0.3;     end;


%% Gamma Correction
% to increase local contrast in shadowed regions
if gamma == 0
    Gamma_Im = log(double(Input_Im) + max(1,max(max(Input_Im)))/256); 
else
    Gamma_Im = (double(Input_Im)).^gamma;
end


%% DoG Filtering (Difference of Gaussian)
F1 = fspecial('gaussian', 2*ceil(3*sigma0) + 1, sigma0);
F2 = fspecial('gaussian', 2*ceil(3*sigma1) + 1, sigma1);
DoG_Im = imfilter(Gamma_Im, F1, 'replicate', 'same') - imfilter(Gamma_Im, F2, 'replicate', 'same');


%% Masking
if ~isempty(mask) % mask out unwanted pixels
    DoG_Im = DoG_Im.*mask; 
end       


%% Contrast Equalization
Output_Im = DoG_Im./mean(mean(abs(DoG_Im).^alpha))^(1/alpha);
Output_Im = Output_Im./mean(mean(min(tao, abs(Output_Im)).^alpha))^(1/alpha);
Output_Im = tao*tanh(Output_Im/tao);


%% Pixel Normalization
maxVal = max(max(Output_Im));
minVal = min(min(Output_Im));
if maxVal~= minVal
    Output_Im = (Output_Im - minVal)/(maxVal - minVal);
    Output_Im = uint8(Output_Im*255);
else
    Output_Im = zeros(size(Output_Im), 'uint8');
end





        

