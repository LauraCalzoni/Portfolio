import numpy as np
from scipy.optimize import fsolve
from math import sin, cos
import matplotlib.pyplot as plt

def sigmoid_fcn(tt):
  """
  Input:
    - tt: time instant

  Outputs
    - s: sigmoid function
    - ds: first derivative of the sigmoid function
    - dds: second derivative of the sigmoid function
    - ddds: third derivative of the sigmoid function
  """

  ss = 1/(1 + np.exp(-tt))
  ds = ss*(1-ss)
  dds = -(2*ss*ds)+ds
  ddds = -2*ds**2-2*ss*dds+dds

  return ss, ds, dds,ddds


def reference_position(tt, p0, pT, T):
  """
  Inputs:
    - tt: time instant
    - p0: initial position
    - pT: final position
    - T: time horizon

  Outputs:
    - pp: position
    - dd: velocity (first derivative of the position)
    - ddd: acceleration (second derivative of the position)
    - dddd: third derivative of the position
  """
  x = (15/(T))*(tt-(T/2))
  pp = p0 + sigmoid_fcn(x)[0]*(pT - p0)
  dd = sigmoid_fcn(x)[1]*(pT - p0)
  ddd = sigmoid_fcn(x)[2]*(pT-p0)
  dddd = sigmoid_fcn(x)[3]*(pT-p0)

  return pp, dd, ddd, dddd


def solver(v, i, gamma=None, gam_d=None):
  """
  Inputs:
    - v: fixed velocity
    - i: step I'm executing
    - gamma: fixed value of the flight path angle
    - gam_d: fixed value of the flight path angular velocity

  Outputs:
    - T: thrust force
    - theta: pitch angle (case i=1)
    - alpha: angle of attack (case i=2/3)

  """
  # Constants
  Cd0 = 0.1716
  Cda = 2.395
  Cla = 3.256
  m = 12
  g = 9.81
  s = 0.61
  rho = 1.2
  J = 0.24

  if(i==1):
      def func(var):

          (T, theta) = var
          eqn_1 = -(rho*s/(2*m))*v**2*(Cd0+Cda*(theta**2)) + (T/m)*cos(theta)
          eqn_2 = (rho*s/(2*m))*v*Cla*theta -(g/v) +(T/(m*v))*sin(theta)

          return [eqn_1, eqn_2]

      T, theta = fsolve(func,(200, 0.035))

      return T, theta


  if(i==2 or i==3):

      def func(var):
          (T, alpha) = var
          eqn_1 = (1/(2*m))*(rho*(v**2)*s)*Cla*alpha-g*np.cos(gamma)+T/m*np.sin(alpha)-v*gam_d
          eqn_2 = -(1/2*m)*rho*(v**2)*s*(Cd0+Cda*(alpha**2))-g*np.sin(gamma)+(T/m)*np.cos(alpha)
      
          return [eqn_1, eqn_2]
      
      T, alpha = fsolve(func,(200, 0.035))
          
      return T, alpha


def plot_graph(y, ref=None, title=None, state=None):

  plt.rcParams.update({'font.size': 16 * 0.8})
  x = range(len(y))
  fig, ax = plt.subplots(figsize=(8, 6))
  ax.plot(x, y, label='Trajectory')
  plt.grid()

  if title is not None:
      ax.set_title(title)
  if ref is not None:
      ax.plot(x, ref, '--',label='Reference', color='orange')
      ax.legend()
  if(state is not None):
    if(state==0):
      plt.xlabel('t [ms]')
      plt.ylabel('x_t [m]')
    if(state==1):
      plt.xlabel('t [ms]')
      plt.ylabel('z_t [m]')
    if(state==2):
      plt.xlabel('t [ms]')
      plt.ylabel('theta_t [m]')
    if(state==3):
      plt.xlabel('t [ms]')
      plt.ylabel('V_t [m/s]')
    if(state==4):
      plt.xlabel('t [ms]')
      plt.ylabel('gamma_t [rad]')
    if(state==5):
      plt.xlabel('t [ms]')
      plt.ylabel('q_t [rad/s]')
    if(state=="u0"):
      plt.xlabel('t [ms]')
      plt.ylabel('Th_t [N]')
    if(state=="u1"):
      plt.xlabel('t [ms]')
      plt.ylabel('M_t [Nm]')
      
  if(title=="JJ"):
    plt.xlabel('k')
    plt.ylabel('cost')
  plt.show(block=False)
  if(title=="descent"):
    plt.xlabel('k')
    plt.ylabel('|descent|')
  plt.show(block=False)
