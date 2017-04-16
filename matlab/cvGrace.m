function [coef,lam1,lam2,mse] = cvGrace(Y, X, wt, netwk, a, lam1_all, lam2_all, k)
cv = cvpartition(size(Y,1),'k',k);
for lam1_idx =1:size(lam1_all); 
    clam1=lam1_all(lam1_idx);
    for lam2_idx=1:size(lam2_all); 
        clam2=lam2_all(lam2_idx); 
        
        err = zeros(k,1);
        for fold = 1:k
            train = cv.training(fold);
            holdout = cv.test(fold);
            b = grace(Y(train,:), X(train,:), wt, netwk, a, clam1, clam2);
            err(fold) = mean((X(holdout,:)*b - Y(holdout)).^2); 
        end
        cur_mse = mean(err); 
        
        if exist('mse','var') == 0 || cur_mse < mse
            coef = b;
            lam1 = clam1;
            lam2 = clam2;
            mse = cur_mse;
        end
    end;
end;