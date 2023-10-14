import numpy as np
import dynamics as dyn

ns = dyn.ns
ni = dyn.ni

# Weight matrixes initialization

QQt = np.array([[1, 0, 0, 0, 0, 0],
                [0, 50, 0, 0, 0, 0],
                [0, 0, 0.001, 0, 0, 0],
                [0, 0, 0, 0.001, 0, 0],
                [0, 0, 0, 0, 0.001, 0],
                [0, 0, 0, 0, 0, 0.001]])


SSt = np.array([[0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0]])

RRt = 1e-3*np.eye(ni)

QQT = 5*QQt

def stagecost(xx, uu, xx_ref, uu_ref, phy_lim:bool, kk, epsy):
  """
  Input parameters:
    - xx (in R^6): state vector
    - uu (in R^2): input vector
    - xx_ref (in R^6): state reference vector
    - uu_ref (in R^2): input reference vector
    - phy_lim: boolean variable to enable the phisical limits consideration
    - kk: current iteration of the algorithm
    - epsy: current epsilon parameter necessary for the barrier function implementation

  Output parameters:
    - ll: stage cost
    - lx: gradient of the stage cost wrt the states
    - lu: gradient of the stage cost wrt the inputs
    - lxx: hessian of the stage cost wrt the states
    - luu: hessian of the stage cost wrt the inputs
    - epsy: updated epsilon parameter necessary for the barrier function implementation
  """

  xx = xx[:,None]
  uu = uu[:,None]

  xx_ref = xx_ref[:,None]
  uu_ref = uu_ref[:,None]

  ll = 0.5*(xx - xx_ref).T@QQt@(xx - xx_ref) + 0.5*(uu - uu_ref).T@RRt@(uu - uu_ref)

  lx = QQt@(xx - xx_ref)
  lu = RRt@(uu - uu_ref)
  lxx = QQt
  luu = RRt

  if(phy_lim == True):

    T_max = 40          # limit value for T
    M_max = 20          # limit value fo M

    if(kk%5==0):
      epsy = epsy/10    # decrease the epsylon each five iterations of the opt algorithm

    m = np.zeros((ni,1))
    m2 = np.zeros((ni,ni))
    
    if(uu[0]>0):
      ll += epsy*(-np.log(-(uu[0])+T_max)-np.log(-(uu[1])+M_max))
      m[0,0] = epsy*(1/(-(uu[0])+T_max))
      m2[0,0] = epsy*(1/(-(uu[0])+T_max)**2)
      m[1,0] = epsy*(1/(-(uu[1])+M_max))
      m2[1,1] = epsy*(1/(-(uu[1])+M_max)**2)
    
    else:
      ll += epsy*(-np.log((uu[0])+T_max)-np.log((uu[1])+M_max))
      m[0,0] = -epsy*(1/((uu[0])+T_max))
      m[1,0] = -epsy*(1/((uu[1])+M_max))
      m2[0,0] = epsy*(1/((uu[0])+T_max)**2)
      m2[1,1] = epsy*(1/((uu[1])+M_max)**2)
    
    lu += m
    luu += m2

  return ll, lx, lu, lxx, luu, epsy


def termcost(xx, xx_ref):
  """
  Input parameters:
    - xx (in R^6): state vector
    - xx_ref (in R^6): state reference vector

  Output parameters:
    - llT (in R): term cost
    - lTx (in R): gradient of the term cost wrt the states
    - lTxx (in R): hessian of the term cost wrt the states
  """

  xx = xx[:,None]
  xx_ref = xx_ref[:,None]

  llT = 0.5*(xx - xx_ref).T@QQT@(xx - xx_ref)

  lTx = QQT@(xx - xx_ref)
  lTxx = QQT

  return llT, lTx, lTxx 



def full_cost(x_init, uu, xx_ref, uu_ref, phy_lim:bool, kk, epsy):
  """
  Input parameters:
    - xx_init (in R^6): initial state vector
    - uu (in R^2): input vector
    - xx_ref (in R^6): state reference vector
    - uu_ref (in R^2): input reference vector
    - phy_lim: boolean variable to enable the phisical limits consideration
    - kk: current iteration of the algorithm
    - epsy: current epsilon parameter necessary for the barrier function implementation


  Output parameters:
    - JJ (in R): full cost function
    - epsy: updated epsilon parameter necessary for the barrier function implementation

  """
  xx = dyn.full_dyn(x_init, uu)
  JJ = 0

  for tt in range(0,dyn.TT-1):
    cost_temp = stagecost(xx[:,tt], uu[:,tt], xx_ref[:,tt], uu_ref[:,tt], phy_lim, kk, epsy)[0]
    JJ = JJ + cost_temp
  
  JJ = JJ + termcost(xx[:,-1],xx_ref[:,-1])[0]

  epsy = stagecost(xx[:,0], uu[:,0], xx_ref[:,0], uu_ref[:,0], phy_lim, kk, epsy)[-1]
  
  return JJ ,epsy