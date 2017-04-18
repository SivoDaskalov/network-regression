from commons import cv_nfolds
from commons import epsilon
from models import Model
import matlab.engine
import numpy as np


c_values = [10.0, 20.0, 30.0]


def fit_linf(setup, matlab_engine):
    m_wt = matlab.double(np.sqrt(setup.degrees).tolist(), size=(setup.x_train.shape[1], 1))
    m_netwk = matlab.double([[p1, p2] for (p1, p2) in setup.network])

    # Tuning
    m_y = matlab.double(setup.y_tune.tolist(), size=(len(setup.y_tune), 1))
    m_X = matlab.double(setup.x_tune.tolist())
    c = matlab_engine.cvLinf(m_y, m_X, m_wt, m_netwk, float(cv_nfolds))

    # Training
    m_y = matlab.double(setup.y_train.tolist(), size=(len(setup.y_train), 1))
    m_X = matlab.double(setup.x_train.tolist())
    coef = matlab_engine.linf(m_y, m_X, m_wt, m_netwk, c)

    return Model(coef, params={"C": c})


def fit_alinf(setup, matlab_engine, linf_fit):
    b0 = [coef if abs(coef) > epsilon else 0 for coef in linf_fit.coef_]
    mask = np.array([True if b0[i1 - 1] != 0 or b0[i2 - 1] != 0 else False for (i1, i2) in setup.network], dtype=bool)
    network = np.array(setup.network)
    discarded = np.unique(network[~mask])
    network = network[mask]

    adj = [1 if b0[p1 - 1] * b0[p2 - 1] > 0 and b0[p1 - 1] > epsilon and b0[p2 - 1] > epsilon else -1
           for (p1, p2) in network]

    m_wt = matlab.double(np.sqrt(setup.degrees).tolist(), size=(setup.x_train.shape[1], 1))
    m_netwk = matlab.double([[p1, p2] for (p1, p2) in network])
    m_adj = matlab.double(adj)
    m_dis = matlab.double(discarded.tolist())
    m_c = matlab.double(c_values)

    # Tuning
    m_y = matlab.double(setup.y_tune.tolist(), size=(len(setup.y_tune), 1))
    m_X = matlab.double(setup.x_tune.tolist())
    e = matlab_engine.cvAlinf(m_y, m_X, m_wt, m_netwk, m_adj, m_dis, cv_nfolds, m_c)

    # Training
    m_y = matlab.double(setup.y_train.tolist(), size=(len(setup.y_train), 1))
    m_X = matlab.double(setup.x_train.tolist())
    coef = matlab_engine.alinf(m_y, m_X, m_wt, m_netwk, m_adj, m_dis, e)

    return Model(coef, params={"E": e})