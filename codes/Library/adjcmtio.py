import re
import os
from typing import List
import numpy as np
from glob import glob

real_in = r"-?\d+"
real_dn = r"-?\d*\.\d+"
real_sn = r"-?\d.\d+[Ee][+\-]\d\d?"
real = r"\s*("+real_sn + "|" + real_dn + "|" + real_in + r")\s*"

scinot = re.compile(real)

def get_cmtparams(path:str) -> tuple:
    """parse cmt parameters from gcmt file format,
    returns numpy array containing cmt parameters in this order
    [lat/y, lon/x, z, mrr, mtt, mpp, mrt, mrp, mtp]
    and list containing original string of source parameters
    in the same order (for updating cmt solution later on)

    Args:
        path (str): path of the CMT file

    Returns:
        tuple: (cmt parameters, original parameters:str)
    """
    
    
    cmtparams = []
    original_string = [] # to update old cmt file
    with open(path, 'r') as cmt:
        for i, line in enumerate(cmt.readlines()):
            # skip header, start with latorUTM
            if i > 3:
                param = re.findall(scinot, line)[0]
                original_string.append(param)
                cmtparams.append(float(param))
    
    return np.array(cmtparams), original_string


def get_frechet(path:str):
    """Parse frechet derivative file with respect to 
    source parameters. Returns numpy array containing frechet
    derivative of misfit functional in this order
    [dmrr, dmtt, dmpp, dmrt, dmrp, dmtp]

    Args:
        path (str): path of frechet derivative

    Returns:
        ndarray : frechet derivative elements
    """
    grads = []
    with open(path, 'r') as frechet:
        for line in frechet.readlines():
            grad = re.findall(scinot, line)[0]
            grads.append(float(grad))
    
    grads = np.array(grads)
    return grads


def rewrite_cmtsolution(path:str, newparams, oldparams:List):
    """
    newparams = new updated cmt solution (numpy array)
    oldparams = old cmt solution parameter (list of string)
    """
    newtext = ""
    with open(path, 'r+') as f:
        for i, line in enumerate(f.readlines()):
            if i > 3:
                newline = line.replace(oldparams[i-4], str(newparams[i-4]))
                newtext = newtext + newline 
            
            else:
                newtext = newtext+line
    
    with open(path, 'w') as f:
        f.write(newtext)

def cmt2specfem(params):
    """convert from CMT format to specfem format

    # params = [y, x, z, mrr, mtt, mpp, mrt, mrp, mtp]
    # to [mrr, mtt, mpp, mrt, mrp, mtp, x, y, z]

    Args:
        params (List): list of cmt parameters extracted from CMT file

    Returns:
        params_new (List): List of cmt parameters, ordered same as the frechet derivative
    """

    params_new = np.zeros_like(params)
    params_new[0] = params[3]
    params_new[1] = params[4]
    params_new[2] = params[5]
    params_new[3] = params[6]
    params_new[4] = params[7]
    params_new[5] = params[8]
    params_new[6] = params[1]
    params_new[7] = params[0]
    params_new[8] = params[2]
    return params_new

def specfem2cmt(params):
    """
    convert from specfem format to cmt format
    convert [mrr, mtt, mpp, mrt, mrp, mtp, x, y, z]
    to [y, x, z, mrr, mtt, mpp, mrt, mrp, mtp]
    """
    params_new = np.zeros_like(params)
    params_new[0] = params[7]
    params_new[1] = params[6]
    params_new[2] = params[8]
    params_new[3] = params[0]
    params_new[4] = params[1]
    params_new[5] = params[2]
    params_new[6] = params[3]
    params_new[7] = params[4]
    params_new[8] = params[5]
    return params_new


