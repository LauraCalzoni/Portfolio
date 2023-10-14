
import numpy as np
import math as mt
from scipy.optimize import fsolve

# Constant definitions
Cd0 = 0.1716
Cda = 2.395
Cla = 3.256
m = 12
g = 9.81
s = 0.61
rho = 1.2
J = 0.24
tf = 1 
dt = 1e-3       # discretization step
TT = int(tf/dt) # total time instants 

ns = 6          # number of states
ni = 2          # number of inputs


def dynamics(xx, uu):
  """
  Dynamics of a simplified aircraft model

  Inputs:
    - xx (in R^6): state at time t
    - uu (in R^2): input at time t
  
  Output:
    xx_d (in R^6): discretized dynamics
  """

  xx_d = np.zeros((ns, ))

  alpha = xx[2]-xx[4]

  # Lift and drag forces
  D = (1/2*rho*(xx[3]**2)*s*(Cd0+Cda*((xx[2]-xx[4])**2)))
  L = 1/2*rho*(xx[3]**2)*Cla*s*(xx[2]-xx[4])

  # Dynamics
  # x_dot
  xx_d[0] = xx[0] + dt * xx[3]*np.cos(xx[4])
  # z_dot 
  xx_d[1] = xx[1] + dt * xx[3]*np.sin(xx[4])
  # teta_dot
  xx_d[2] = xx[2] + dt*xx[5]
  # v_dot                            
  xx_d[3] = xx[3] + dt * ((1/m)*((-D-m*g*np.sin(xx[4])+uu[0]*np.cos(xx[2]-xx[4]))))
  # gamma_dot
  xx_d[4] = xx[4] + dt * ((1/(m*xx[3]))*(L-m*g*np.cos(xx[4])+uu[0]*np.sin(xx[2]-xx[4])))
  # q_dot
  xx_d[5] = xx[5] + dt * (uu[1]/J)

  return xx_d




def derivatives(x_t, u_t):
  """
  Inputs:
    - x_t (in R^6): state vector at time t
    - u_t (in R^2): input vector at time t

  Outputs:
    - nablax_F_t (in R^6x6): gradient of the dynamics wrt state x
    - nablau_F_t (in R^2x6): gradient of the dynamics wrt input u
  """

  # Initialization
  nablax_F = np.zeros((6,6))
  nablau_F = np.zeros((2,6))

  # Casting
  x = x_t[0]
  z = x_t[1]
  theta = x_t[2]
  V = x_t[3]
  gamma =  x_t[4]
  q = x_t[5]
  alpha = theta -gamma
  u1 = u_t[0]
  u2 = u_t[1]

  # Gradient of function f1 with respect to x
  nablax_F[0,0] = 1
  nablax_F[1,0] = 0
  nablax_F[2,0] = 0
  nablax_F[3,0] = dt*np.cos(gamma)
  nablax_F[4,0] = -dt*V*np.sin(gamma)
  nablax_F[5,0] = 0

  # Gradient of function f1 with respect to u
  nablau_F[0,0] = 0
  nablau_F[1,0] = 0

  # Gradient of function f2 with respect to x
  nablax_F[0,1] = 0
  nablax_F[1,1] = 1
  nablax_F[2,1] = 0
  nablax_F[3,1] = dt*np.sin(gamma)
  nablax_F[4,1] = dt*V*np.cos(gamma)
  nablax_F[5,1] = 0

  # Gradient of function f2 with respect to u
  nablau_F[0,1] = 0
  nablau_F[1,1] = 0

  # Gradient of function f3 with respect to x
  nablax_F[0,2] = 0
  nablax_F[1,2] = 0
  nablax_F[2,2] = 1
  nablax_F[3,2] = 0
  nablax_F[4,2] = 0
  nablax_F[5,2] = dt

  # Gradient of function f3 with respect to u
  nablau_F[0,2] = 0
  nablau_F[1,2] = 0

  # Gradient of function f4 with respect to x
  nablax_F[0,3] = 0
  nablax_F[1,3] = 0
  nablax_F[2,3] = dt*( -(rho*s*Cda/m)*(V**2)*alpha -(u1/m)*np.sin(alpha))
  nablax_F[3,3] = 1-dt*( (rho*s/m)*(Cd0+Cda*alpha**2)*V )
  nablax_F[4,3] = dt*( (rho*s/m)*Cda*(V**2)*alpha -g*np.cos(gamma) +(u1/m)*np.sin(alpha) )
  nablax_F[5,3] = 0 

  # Gradient of function f4 with respect to us
  nablau_F[0,3] = (dt/m)*np.cos(alpha)
  nablau_F[1,3] = 0

  # Gradient of function f5 with respect to x
  nablax_F[0,4] = 0
  nablax_F[1,4] = 0
  nablax_F[2,4] = dt*( (rho*s*Cla/(2*m))*V + u1/(m*V)*np.cos(alpha) )
  nablax_F[3,4] = dt*( (rho*s*Cla/(2*m))*alpha +(g/(V**2))*np.cos(gamma) -(u1/(m*(V**2)))*np.sin(alpha) )
  nablax_F[4,4] = 1+ dt*( -(rho*s*Cla/(2*m))*V +(g/V)*np.sin(gamma) - (u1/(m*V))*np.cos(alpha) )
  nablax_F[5,4] = 0 

  # Gradient of function f5 with respect to u
  nablau_F[0,4] = (dt/(m*V))*np.sin(alpha)
  nablau_F[1,4] = 0

  # Gradient of function f6 with respect to x
  nablax_F[0,5] = 0
  nablax_F[1,5] = 0
  nablax_F[2,5] = 0
  nablax_F[3,5] = 0
  nablax_F[4,5] = 0
  nablax_F[5,5] = 1

  # Gradient of function f6 with respect to u
  nablau_F[0,5] = 0
  nablau_F[1,5] = dt/J

  return nablax_F, nablau_F


def hessian (x_t, u_t):
  """
  Inputs:
    - x_t (in R^6): state vector at time t
    - u_t (in R^2): input vector at time t

  Outputs:
    - hx (in R^6x6x6): hessian of the dynamics wrt state x
    - hu (in R^2x2x6): hessian of the dynamics wrt input u
    - fxu (in R^6x2x6): hessian of the dynamics wrt both state and input
  """

  # Casting
  x = x_t[0]
  z = x_t[1]
  theta = x_t[2]
  V = x_t[3]
  gamma =  x_t[4]
  q = x_t[5]
  alpha = theta -gamma
  u1 = u_t[0]
  u2 = u_t[1]

  h_xdot_s=np.zeros((ns,ns))
  h_xdot_s[3,4]=-dt*np.sin(gamma)
  h_xdot_s[4,4]=-dt*V*np.cos(gamma)
  h_xdot_s[4,3]=-dt*np.sin(gamma)


  h_zdot_s=np.zeros((ns,ns))
  h_zdot_s[3,4]=-dt*np.cos(gamma)
  h_zdot_s[4,4]=dt*V*np.sin(gamma)
  h_zdot_s[4,3]=-dt*np.cos(gamma)

  h_thetadot_s=np.zeros((ns,ns))

  h_Vdot_s=np.zeros((ns,ns))
  h_Vdot_s[2,2]=8.3333e-5*u1*np.cos(gamma-theta)-0.000146095*V**2
  h_Vdot_s[3,2]=-6.1e-5*V*(-4.79*gamma+4.79*theta)
  h_Vdot_s[4,2]=-8.3333e-5*u1*np.cos(gamma-theta)+0.000146095*V**2
  h_Vdot_s[2,3]=-6.1e-5*V*(-4.79*gamma+4.79*theta)
  h_Vdot_s[3,3]=-0.000146095*(-gamma+theta)**2-1.04676e-5
  h_Vdot_s[4,3]=-6.1e-5*V*(+4.79*gamma-4.79*theta)
  h_Vdot_s[2,4]=-8.3333e-5*u1*np.cos(gamma-theta)+0.000146095*V**2
  h_Vdot_s[3,4]=-6.1e-5*V*(4.79*gamma-4.79*theta)
  h_Vdot_s[4,4]=8.3333e-5*u1*np.cos(gamma-theta)-0.000146095*V**2-0.00981*np.sin(gamma)

  h_gamdot_s = np.zeros((ns,ns))
  h_gamdot_s[2,2]=(8.3333e-5*u1*np.sin(gamma-theta))/V
  h_gamdot_s[3,2]=-8.3333e-5*(u1*np.cos(gamma-theta)+1.191696*V**2)/(V**2)+0.000198616
  h_gamdot_s[4,2]=-(8.3333e-5*u1*np.sin(gamma-theta))/V
  h_gamdot_s[2,3]=-(8.3333e-5*(u1*np.cos(gamma-theta)+1.191696*V**2))/(V**2)+0.000198616
  h_gamdot_s[3,3]=(0.000166*(-u1*np.sin(gamma-theta)+1.191696*V**2*(theta-gamma)-117.72*np.cos(gamma)))/(V**3)-(0.000198616*(theta-gamma))/V
  h_gamdot_s[4,3]=-(8.3333e-5*(-u1*np.cos(gamma-theta)-1.191696*V**2+117.72*np.sin(gamma)))/(V**2)-0.000198616
  h_gamdot_s[2,4]=(8.3333e-5*u1*np.sin(gamma-theta))/V
  h_gamdot_s[3,4]=-8.3333e-5*(-u1*np.cos(gamma-theta)-1.191696*V**2+117.72*np.sin(gamma))/(V**2)-0.000198616
  h_gamdot_s[4,4]=(8.3333e-5*(u1*np.sin(gamma-theta)+117.71*np.cos(gamma)))/V

  h_qdot_s = np.zeros((ns,ns))

  hx= np.array([h_xdot_s, h_zdot_s, h_thetadot_s, h_Vdot_s, h_gamdot_s, h_qdot_s])


  h_xdot_i=np.zeros((ni,ni))
  h_zdot_i=np.zeros((ni,ni))
  h_thetadot_i=np.zeros((ni,ni))
  h_Vdot_i=np.zeros((ni,ni))
  h_gamdot_i=np.zeros((ni,ni))
  h_qdot_i=np.zeros((ni,ni))
  hu= np.array([h_xdot_i, h_zdot_i, h_thetadot_i, h_Vdot_i, h_gamdot_i, h_qdot_i])


  fxu_xdot=np.zeros((ns,ni))
  fxu_zdot=np.zeros((ns,ni))
  fxu_thetadot=np.zeros((ns,ni))

  fxu_Vdot=np.zeros((ns,ni))
  fxu_Vdot[2,0]=8.333e-4*np.sin(gamma-theta)
  fxu_Vdot[4,0]=-8.333e-4*np.sin(gamma-theta)

  fxu_gamdot=np.zeros((ns,ni))
  fxu_gamdot[2,0]=(8.333e-4*np.cos(gamma-theta))/V
  fxu_gamdot[3,0]=(8.333e-4*np.sin(gamma-theta))/(V**2)
  fxu_gamdot[4,0]=-(8.333e-4*np.cos(gamma-theta))/V

  fxu_qdot=np.zeros((ns,ni))

  fxu= np.array([fxu_xdot.T, fxu_zdot.T, fxu_thetadot.T, fxu_Vdot.T, fxu_gamdot.T, fxu_qdot.T])

  return hx, hu, fxu


def full_dyn(x_init, uu):
  """
  Inputs:
    - x_init (in R^6): state vector at time 0
    - uu (in R^2xTT): input fot each instant of time

  Outputs:
    - xx (in R^6xTT): state fot each instant of time
  """

  ns = x_init.shape[0]
  xx = np.zeros((ns,TT))
  xx[:,0] = x_init
  for t in range (TT-1):
    xx[:,t+1]=dynamics(xx[:,t], uu[:,t])
  
  return xx