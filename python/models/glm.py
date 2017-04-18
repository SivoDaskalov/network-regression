from commons import cv_nfolds
from models import Model
from sklearn.linear_model import Lasso, LassoCV, ElasticNet, ElasticNetCV

n_alphas = 20
l1_ratios = [0.5]
max_iter = 10000
n_jobs = -1


def fit_lasso(setup):
    # Tuning
    model = LassoCV(n_alphas=n_alphas, cv=cv_nfolds, n_jobs=-n_jobs, max_iter=max_iter, random_state=1,
                    fit_intercept=False)
    model.fit(X=setup.x_tune, y=setup.y_tune)

    # Training
    cv_alpha = model.alpha_
    model = Lasso(alpha=cv_alpha, random_state=1, fit_intercept=False, max_iter=max_iter)
    model.fit(setup.x_train, y=setup.y_train)

    return Model(model.coef_, params={"alpha": model.alpha, "l1_ratio": model.l1_ratio}, from_matlab=False)


def fit_enet(setup):
    # Tuning
    model = ElasticNetCV(n_alphas=n_alphas, l1_ratio=l1_ratios, cv=cv_nfolds, n_jobs=-n_jobs, max_iter=max_iter,
                         random_state=1, fit_intercept=False)
    model.fit(X=setup.x_tune, y=setup.y_tune)

    # Training
    cv_alpha = model.alpha_
    cv_l1_ratio = model.l1_ratio_
    model = ElasticNet(alpha=cv_alpha, l1_ratio=cv_l1_ratio, random_state=1, fit_intercept=False, max_iter=max_iter)
    model.fit(setup.x_train, y=setup.y_train)

    return Model(model.coef_, params={"alpha": model.alpha}, from_matlab=False)
