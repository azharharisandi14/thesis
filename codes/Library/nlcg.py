import numpy as np 

def make_sigma(grads):
    mts = grads[:6]
    loc = grads[6:]

    sigma_mts = np.sqrt(2) * (mts**2 @ np.array([1, 1, 1, 2, 2, 2]))**(-0.5)
    sigma_loc = np.sum((loc**(2)))**(-0.5)

    sigma = np.ones(9) * sigma_mts
    sigma[6] = sigma_loc
    sigma[7] = sigma_loc
    sigma[8] = sigma_loc

    return sigma

def make_sigma(grads):
    mts = grads[:6]
    loc = grads[6:]

    sigma_mts = np.sqrt(2) * (mts**2 @ np.array([1, 1, 1, 2, 2, 2]))**(-0.5)
    sigma_loc = np.sum((loc**(2)))**(-0.5)

    sigma = np.ones(9) * sigma_mts
    sigma[6] = 1
    sigma[7] = 1
    sigma[8] = 1

    return sigma

def compute_beta_pr(g_k_hat, g_k_min1_hat):
    """
    beta using Polak-Ribiere formula with a direction reset
    """

    b = (g_k_hat @ (g_k_hat - g_k_min1_hat))/(g_k_min1_hat @ g_k_min1_hat)
    beta = max(0, b)
    return beta

def compute_beta_fr(g_k_hat, g_k_min1_hat):
    beta = (g_k_hat @ g_k_hat) / (g_k_min1_hat @ g_k_min1_hat)
    return beta


def compute_lambda(lambda_t, f1, f2, g1):
    # lambda_t = -2*gamma*f1/g1

    b = ((f2-f1) - g1*lambda_t)/lambda_t**2
    c = g1
    if b == 0:
        raise ValueError
    else:
        return -c/(2*b)
