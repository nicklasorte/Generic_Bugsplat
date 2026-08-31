function q = curvspace_app(app,p,N)

%% initial settings %%
currentpt = p(1,:); % current point
indfirst = 2; % index of the most closest point in p from curpt
len = size(p,1); % length of p
q = currentpt; % output point
k = 0;

%% distance between points in p %%
dist_bet_pts=NaN(len-1,1);
for k0 = 1:len-1
   dist_bet_pts(k0) = distance_app(app,p(k0,:),p(k0+1,:));
end
% totaldist = nansum(dist_bet_pts);
% check version, use nansum for 2022 and earlier and sum w/omitnan option for 2023 and later
if double(regexp(string(version('-release')), '^[0-9]+', 'match')) >= 2023
	totaldist = sum(dist_bet_pts, "omitnan");
else	
	totaldist = nansum(dist_bet_pts);
end

%% interval %%
intv = totaldist./(N-1);

%% iteration %%
for k = 1:N-1

   newpt = []; distsum = 0;
   ptnow = currentpt;
   kk = 0;
   pttarget = p(indfirst,:);
   remainder = intv; % remainder of distance that should be accumulated
   while isempty(newpt)
      % calculate the distance from active point to the most
      % closest point in p
      disttmp = distance_app(app,ptnow,pttarget);
      distsum = distsum + disttmp;
      % if distance is enough, generate newpt. else, accumulate
      % distance
      if distsum >= intv
         newpt = interpintv_app(app,ptnow,pttarget,remainder);
      else
         remainder = remainder - disttmp;
         ptnow = pttarget;
         kk = kk + 1;
         if indfirst+kk > len
            newpt = p(len,:);
         else
            pttarget = p(indfirst+kk,:);
         end
      end
   end
   
   % add to the output points
   q = [q; newpt];
   
   % update currentpt and indfirst
   currentpt = newpt;
   indfirst = indfirst + kk;
   
end



%%%%%%%%%%%%%%%%%%%%%%%%%
%%    SUBFUNCTIONS     %%
%%%%%%%%%%%%%%%%%%%%%%%%%

function l = distance_app(app,x,y)

% DISTANCE Calculate the distance.
%   distance_app(app,X,Y) calculates the distance between two
%   points X and Y. X should be a 1 x 2 (2D) or a 1 x 3 (3D)
%   vector. Y should be n x 2 matrix (for 2D), or n x 3 matrix
%   (for 3D), where n is the number of points. When n > 1,
%   distance between X and all the points in Y are returned.
%
%   (Example)
%   x = [1 1 1];
%   y = [1+sqrt(3) 2 1];
%   l = distance_app(app,x,y)
%

% 11 Mar 2005, Yo Fukushima

%% calculate distance %%
if size(x,2) == 2
   l = sqrt((x(1)-y(:,1)).^2+(x(2)-y(:,2)).^2);
elseif size(x,2) == 3
   l = sqrt((x(1)-y(:,1)).^2+(x(2)-y(:,2)).^2+(x(3)-y(:,3)).^2);
else
   error('Number of dimensions should be 2 or 3.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newpt = interpintv_app(app,pt1,pt2,intv)

% Generate a point between pt1 and pt2 in such a way that
% the distance between pt1 and new point is intv.
% pt1 and pt2 should be 1x3 or 1x2 vector.

dirvec = pt2 - pt1;
dirvec = dirvec./norm(dirvec);
l = dirvec(1); m = dirvec(2);
newpt = [intv*l+pt1(1),intv*m+pt1(2)];
if length(pt1) == 3
   n = dirvec(3);
   newpt = [newpt,intv*n+pt1(3)];
end