from models.glm import fit_lasso, fit_enet
from models.grace import fit_grace
import matlab.engine
import time

enable_logging = False
full_method_list = ["lasso", "enet", "grace"]


def fit_models(setup, methods = full_method_list):
    engine = matlab.engine.start_matlab("-nodesktop")
    models = {}

    if "lasso" in methods:
        log_timestamp(setup.label, "lasso")
        models["lasso"] = fit_lasso(setup=setup)

    if "enet" in methods:
        log_timestamp(setup.label, "enet")
        models["enet"] = fit_enet(setup=setup)

    if "grace" in methods:
        log_timestamp(setup.label, "grace")
        models["grace"] = fit_grace(setup=setup, matlab_engine=engine)

    return models


def batch_fit_models(setups, methods = full_method_list):
    return [(setup, fit_models(setup=setup, methods=methods)) for setup in setups]


def log_timestamp(setup, method):
    if enable_logging:
        print("%s\t%s\t%.0f s" % (setup, method, time.clock()))