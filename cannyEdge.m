%% CIS 581: Canny Edge Detection - Homework 1
%% University of Pennsylvania
%% Algorithm: 
% (a) Pre-process: Improve contrast then Use wavelets to stregnthen edges
% (b) Compute Image Gradient
% (c) Local Maxima Suppression
% (d) Hysterisis
% 
%% Code by:
% Adarsh Vakkaleri Sateesh(adarshv@seas.upenn.edu)
% Nitin Jagannatha Sanket (nitinsan@seas.upenn.edu)
%% Input: Image "I"
%% Output: Edge Image "output"
function output = cannyEdge(I)
% Convert RGB to Gray
if size(I,3)>1
    I = rgb2gray(I);
end
% Convert Image to even dimentions for SWT to work
if mod(size(I,1),2)~=0
    I = I(1:size(I,1)-1,:);
end
if mod(size(I,2),2)~=0
    I = I(:,1:size(I,2)-1);
end

%% Step (a) Pre-process: Improve contrast then Use wavelets to stregnthen edges
I = imadjust(I); % Imrpove Contrast
[cA cH cV cD] = swt2(I,1,'haar'); % Use wavelets to imrpove edge quality
% Amplify the wavelet-subbands
cA = 4.*cA; 
cH = 25.*cH;
cV = 25.*cV;
cD = 10.*cD;
I = mat2gray(iswt2(cA, cH, cV, cD, 'haar'));

%% Step (b) Compute Image Gradient
sigma = 0.8;
Gx = fspecial('gaussian',[5 5], sigma); % Kernel
Gy = Gx';
delx = [1 -1];
dely = delx';
Jx = conv2(conv2(conv2(I,Gx,'same'),delx,'same'),Gy,'same');
Jy = conv2(conv2(conv2(I,Gy,'same'),dely,'same'),Gx,'same');
DelI = sqrt(Jx.*Jx+Jy.*Jy); % Gradient
theta = atan2(Jx,Jy);
theta1 = atand(theta); % Calculating the edge orientation
[r,c]=size(I);
output = zeros(r,c);
LT = 1.5;                   
HT = 3.0;
lowT  = LT.*mean(DelI(:)); % Low and High Thresholds for Hysterisis
highT = HT.*lowT;

%% Step (c) Local Maxima Suppression
for i=1:r,
    for j=1:c,
        if(theta1(i,j)<0)
            theta1(i,j)= theta1(i,j)+360; % Converting angles to positive
        end
    end
end

for i=2:r-1,
    for j=2:c-1,
        if((theta1(i,j) >=0 && theta1(i,j) <= 45) || (theta1(i,j) >=180 && theta1(i,j) <= 225)  )
            if(DelI(i,j) > max(DelI(i-1,j+1),DelI(i+1,j-1)))
                output(i,j) = 1;
            end
        end
        if((theta1(i,j) >=45 && theta1(i,j) <= 90) || (theta1(i,j) >=225 && theta1(i,j) <= 270)  )
            if(DelI(i,j) > max(DelI(i-1,j),DelI(i+1,j)))
                output(i,j) = 1;
            end
        end
        if((theta1(i,j) >=90 && theta1(i,j) <= 135) || (theta1(i,j) >=270 && theta1(i,j) <= 315)  )                % detection of edge points 
            if(DelI(i,j) > max(DelI(i-1,j-1),DelI(i+1,j+1)))
                output(i,j) = 1;
            end
        end
        if((theta1(i,j) >=135 && theta1(i,j) <= 180) || (theta1(i,j) >=315 && theta1(i,j) <= 360)  )
            if(DelI(i,j) > max(DelI(i,j-1),DelI(i,j+1)))
                output(i,j) = 1;
            end
        end
    end
end

%% Step (d) Hysterisis
Val = 0.9;
output = output.*Val;


for i=2:r-1,
    for j=2:c-1,
        if((output(i,j) > 0) && (DelI(i,j) < lowT))
            output(i,j) = 0;                         % Pruning out points which are definitely not edge points
        elseif((output(i,j) > 0) && (DelI(i,j) >= highT))
            output(i,j) = 1;
        end
    end
end

x1 = [];
x = find(output==1);
while (size(x1,1) ~= size(x,1))
    x1 = x;
    v = [x+r+1, x+r, x+r-1, x-1, x-r-1, x-r, x-r+1, x+1];
    output(v) = (1-Val) + output(v);   % Hysterisis
    y = find(output==(1-Val));
    output(y) = 0;
    y = find(output>=1);
    output(y) = 1;
    x = find(output==1);   
end

for i=2:r-1,
    for j=2:c-1,
        if(output(i,j) < 1 && output(i,j) > 0)
            output(i,j) = 1;   % strengthening all the light edges
        end
    end
end

% imshow(output); % Displaying the output 

end
