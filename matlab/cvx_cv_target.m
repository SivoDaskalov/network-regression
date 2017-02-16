y = dlmread('tmp/in_y.txt');
x = dlmread('tmp/in_x.txt');
origX = x;
origY = y;
folds = dlmread('tmp/in_folds.txt');
p = size(x,2);
lam_all = dlmread('tmp/in_param_lam.txt');
gam_all = dlmread('tmp/in_param_gam.txt');
results = zeros(length(lam_all)*length(gam_all),2+1); % 2 = number of tuned parameters
tStart=tic;
k = max(folds);
k=2;
counter = 1;
for lam_it=1:size(lam_all);
    lam=lam_all(lam_it);
    for gam_it=1:size(gam_all);
        gam=gam_all(gam_it);
        cvMse = zeros(k,1);
        for fold = 1:k;
            training = find(folds ~= fold);
            holdout = find(folds == fold);
            x = origX(training,:);
            y = origY(training,:);
            cvx_begin ;
            variables b(p);
            minimize(square_pos(norm(y - x*b, 2)) / 2 + lam*norm(b, 1)*gam);
            cvx_end;
            cvMse(fold) = mean((origX(holdout,:)*b - origY(holdout)).^2);
        end;
        mse = mean(cvMse);
        results(counter,:) = [lam,gam,mse];
        counter = counter + 1;
    end;
end;
time=toc(tStart);
dlmwrite('tmp/out_results.txt', results, 'precision', '%10.10f');
dlmwrite('tmp/out_time.txt', full(time), 'precision', '%10.10f');
% exit;
