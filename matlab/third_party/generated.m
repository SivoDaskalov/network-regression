disp('Tuning Adaptive Grace parameters');
xtr = dlmread('../tmp/in_xtr.txt');
ytr = dlmread('../tmp/in_ytr.txt');
xtu = dlmread('../tmp/in_xtu.txt');
ytu = dlmread('../tmp/in_ytu.txt');
folds = dlmread('../tmp/in_folds.txt');
netwk = dlmread('../tmp/in_netwk.txt');
deg = dlmread('../tmp/in_deg.txt');
wt = dlmread('../tmp/in_wt.txt');
a = dlmread('../tmp/in_a.txt');
lam1_all = dlmread('../tmp/in_param_lam1.txt');
lam2_all = dlmread('../tmp/in_param_lam2.txt');

results = zeros(36,3);
p = 90;
k = max(folds);
counter = 1;
tStart=tic;
netnorm = @(x, netwk, wt, gamma) sum(norms([x(netwk(:,1))./wt(netwk(:,1)) x(netwk(:,2))./wt(netwk(:,2))], gamma, 2));

for lam1_it=1:size(lam1_all); 
    lam1=lam1_all(lam1_it);
    for lam2_it=1:size(lam2_all); 
        lam2=lam2_all(lam2_it); 
        disp(sprintf('Combination %d of 36 ( %0.1f%% )', counter, (counter-1)*(100/36))); 
        cvMse = zeros(k,1); 
        for fold = 1:k; 
            training = find(folds ~= fold); 
            holdout = find(folds == fold); 
            x = xtu(training,:); 
            y = ytu(training,:); 
            cvx_begin quiet; 
                variable b(p); 
                pen = b(netwk(:,1))./deg(netwk(:,1))-a(:).*b(netwk(:,2))./deg(netwk(:,2)); 
                minimize(sum_square(y-x*b)+lam1*norm(b,1)+lam2*sum((pen.^2).*wt(:))); 
            cvx_end; 
            cvMse(fold) = mean((xtu(holdout,:)*b - ytu(holdout)).^2); 
        end; 
        mse = mean(cvMse); 
        results(counter,:) = [lam1,lam2,mse]; 
        counter = counter + 1;
    end;
end;

disp('Training model'); 
x = xtr; 
y = ytr; 
[minErrVal, minErrIdx] = min(results(:,3));
lam1=results(minErrIdx,1);
lam2=results(minErrIdx,2);
cvx_begin quiet; 
    variable b(p); 
    pen = b(netwk(:,1))./deg(netwk(:,1))-a(:).*b(netwk(:,2))./deg(netwk(:,2)); 
    minimize(sum_square(y-x*b)+lam1*norm(b,1)+lam2*sum((pen.^2).*wt(:))); 
cvx_end;

time=toc(tStart);
disp('Done');
dlmwrite('tmp/out_time.txt', full(time), 'precision', '%10.6f');
dlmwrite('tmp/out_results.txt', results, 'precision', '%10.6f');
dlmwrite('tmp/out_coefficients.txt', b, 'precision', '%10.6f');
dlmwrite('tmp/out_parameters.txt', results(minErrIdx,:), 'precision', '%10.6f');
exit;