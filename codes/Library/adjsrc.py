import numpy as np
from glob import glob 
from scipy.signal import butter, sosfilt
from pprint import pprint

def hanning_window(t, t1, t2):
    """create hanning window in the interval of t1 to t2

    Args:
        t (ndarray): time sample of a seismogram
        t1 (float): start window time
        t2 (float): end window time

    Returns:
        ndarray : hanning window
    """
    t0 = t[0]
    dt = abs(t[1]-t[0])

    idx_start = int((t1-t0) / dt)
    idx_end = int((t2-t0)/dt)
    
    nsamples = idx_end-idx_start

    window = np.hanning(nsamples)
    
    all_window = np.zeros_like(t)
    all_window[idx_start:idx_end] = window
    return all_window


def create_adjsrc(t, t1, t2, data, syn):
    """multiply hanning window with waveform misfit

    Args:
        t (ndarray): time sample of seismogram
        t1 (float): start time
        t2 (float): end time
        data (ndarray): displacement sample data waveform
        syn (ndarray): displacement sample synthetic waveform

    Returns:
        ndarray: waveform adjoint source
    """
    window = hanning_window(t, t1, t2)
    #return window*(data-syn)
    return data-syn

def butter_bandpass(lowcut, highcut, fs, order=5):
        nyq = 0.5 * fs
        low = lowcut / nyq
        high = highcut / nyq
        sos = butter(order, [low, high], analog=False, btype='band', output='sos')
        return sos

def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
        sos = butter_bandpass(lowcut, highcut, fs, order=order)
        y = sosfilt(sos, data)
        return y

def make_adjsrc(ADJ_PATH:str, DATA_PATH:str, SYN_PATH:str, NET:str, t1:float, t2:float):
    strdat = f'{DATA_PATH}/{NET}.*.semd'
    dat = glob(f'{DATA_PATH}/{NET}.*.semd')
    syn = glob(f'{SYN_PATH}/{NET}.*.semd')

    for i, (d, s) in enumerate(zip(dat, syn)):
        DAT = np.loadtxt(d)
        SYN = np.loadtxt(s)
        adjsrc = create_adjsrc(SYN[:,0], t1, t2, DAT[:,1], SYN[:,1])
        # if d[-6] != 'Z':
        #    adjsrc = adjsrc * 0 
        writeto = d.replace(DATA_PATH, ADJ_PATH)
        writeto = writeto.replace('semd', 'adj')
        np.savetxt(writeto, np.c_[SYN[:,0], adjsrc])


def calculate_misfit_waveform(PATH_ADJ:str):
    adjsrc = glob(f'{PATH_ADJ}/*.adj')
    integral = 0 
    for adj in adjsrc:
        data = np.loadtxt(adj)
        integral += (np.trapz(np.abs(data[:,1]), data[:,0]))

    return integral/2


