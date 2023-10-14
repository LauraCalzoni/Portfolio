import numpy as np
import matplotlib.pyplot as plt
import solver_ltv_LQR as solv
import dynamics as dyn
import cost as cst
import utils as ut
import plane_pygame as ply

# Allow Ctrl-C to work despite plotting

import signal

signal.signal(signal.SIGINT, signal.SIG_DFL)

plt.rcParams["figure.figsize"] = (10, 8)
plt.rcParams.update({"font.size": 22})



def compute_trajectory(step: int) -> ply.Trajectory:

    # flag to change according to the step to show
    # step = 1 : step reference
    # step = 2 : sigmoid reference
    # step = 3 : trajectory tracking
    
    #######################################
    # Algorithm parameters
    #######################################

    max_iters = 200
    Stop = 0.06
    epsylon = 1

    #######################################
    # Flags
    #######################################

    phy_limit = False

    tf = dyn.tf     # final time in seconds
    dt = dyn.dt     # get discretization step from dynamics
    ns = dyn.ns     # number of states
    ni = dyn.ni     # number of inputs

    TT = dyn.TT     # discrete-time samples

    ######################################
    # Arrays to store data
    ######################################

    # Initialization for the reference setting
    xx_ref = np.zeros((ns, TT))
    uu_ref = np.zeros((ni, TT))
    uu_guess = np.zeros((ni, TT))
    xx_guess = np.zeros((ns, TT))
    xx_init = np.zeros((ns, 1))
    uu_temp = np.zeros((ni, TT))

    # Initialization for Newton's algorithm
    xx = np.zeros((ns, TT, max_iters))      # state seq.
    uu = np.zeros((ni, TT, max_iters))      # input seq.
    lmbd = np.zeros((ns, TT, max_iters))    # lambdas - costate seq.
    JJ = np.zeros(max_iters)                # collect cost
    descent = np.zeros((max_iters))         # collect descent direction
    AA= np.zeros((ns, ns, TT))
    BB= np.zeros((ns, ni, TT))
    aa= np.zeros((ns, TT))
    bb= np.zeros((ni, TT))
    QQ = np.zeros((ns , ns, TT))
    QQT = np.zeros((ns, ns))
    SS = np.zeros((ni, ns, TT))
    RR = np.zeros((ni, ni, TT))
    nabla_J = np.zeros((ni,TT))             # gradient of the cost funcition
    uu_tmp = np.zeros((ni,TT))              # input seq. update for Armijo implementation
    delta_x0 = np.zeros((ns,))              # state initialization for the Riccati equation
    delta_uu = np.zeros((ni,TT))            # input updating therm

    # Initialization for tracking
    xx_track = np.zeros((ns, TT))           # state seq. for tracking
    uu_track = np.zeros((ni, TT))           # input seq.for tracking
    AA_opt= np.zeros((ns, ns, TT))
    BB_opt= np.zeros((ns, ni, TT))

    ######################################
    # Reference curve
    ######################################

    ref_z_0 = 5     # setting initial and final altitude
    ref_z_T = 10
    Vref = 50       # setting a constant velocity


    # REFERENCE FOR STEP 1 ----------------------------------------------------------------------------
    # set the reference on the z variable as a step from ref_z_0 to ref_z_T then 
    # solve the system for the equilibrium state
    if(step==1):
        for t in range(TT):
            xx_ref[0,t] = dt*Vref*t
            if(t<int(TT/2)):
                xx_ref[1,t] = ref_z_0
            else:
                xx_ref[1,t] = ref_z_T
            xx_ref[2,t] = ut.solver(Vref,step)[1]
            xx_ref[3,t] = Vref
            xx_ref[4,t] = 0
            xx_ref[5,t] = 0

            #Input initial guess
            uu_guess[0,t] =ut.solver(Vref,step)[0]
            uu_guess[1,t] = 0


    # REFERENCE FOR STEP 2 ---------------------------------------------------------------------------
    # set the reference on the z variable as a sigmoid function with extremes ref_z_0 and ref_z_T then 
    # solve the simplified model system where we considered:
    # - constant velocity Vref
    # - linear horizontal displacement

    if(step==2 or step==3):
    
        for t in range(TT):

            z_d = ut.reference_position(t, ref_z_0, ref_z_T, TT)[1]
            z_dd = ut.reference_position(t, ref_z_0, ref_z_T, TT)[2]
            z_ddd = ut.reference_position(t, ref_z_0, ref_z_T, TT)[3]

            gamma = np.arcsin(z_d/Vref)
            gamma_d = (1/np.sqrt(1-(z_d/Vref)**2))*z_dd/Vref
            gamma_dd = (z_ddd/Vref+(z_dd**2/Vref)*(z_d/Vref**2)*(1-(z_d/Vref)**2)**(-1))/(1-(z_d/Vref)**2)**(1/2)

            xx_ref[0,t] = dt*Vref*t
            xx_ref[1,t] = ut.reference_position(t, ref_z_0, ref_z_T, TT)[0]
            xx_ref[2,t] = ut.solver(Vref,step,gamma,gamma_d)[1]+gamma
            xx_ref[3,t] = Vref
            xx_ref[4,t] = gamma
            xx_ref[5,t] = gamma_d

            #Input initial guess
            uu_guess[0,t] = ut.solver(Vref,step,gamma,gamma_d)[0]
            uu_guess[1,t] = dyn.J*gamma_dd

    #States initial guess
    xx_init = xx_ref[:,0]

    xx_guess[:, 0] = xx_init
    xx_guess = dyn.full_dyn(xx_init,uu_guess)


    ######################################
    # Main
    ######################################

    print('-*-*-*-*-*-')
    kk = 0
    xx[:,:,0] = xx_guess
    uu[:,:,0] = uu_guess

    # setting the initial condition for each iteration
    for kk in range(max_iters):
        xx[:,0,kk] = xx_init

    for kk in range(max_iters-1):

        ##################################
        # computation of the cost
        ##################################
        JJ[kk], epsylon = cst.full_cost(xx_init, uu[:,:,kk], xx_ref, uu_ref, phy_limit,kk,epsylon)

        ##################################
        # Descent direction calculation
        ##################################

        lmbd_temp = cst.termcost(xx[:,TT-1,kk], xx_ref[:,TT-1])[1]
        lmbd[:,TT-1,kk] = lmbd_temp.squeeze()

        # integration backward in time
        for tt in reversed(range(TT-1)):
            aa_temp, bb_temp = cst.stagecost(xx[:,tt, kk], uu[:,tt,kk], xx_ref[:,tt], uu_ref[:,tt],phy_limit,kk,epsylon)[1:3]
            aa[:, tt]=aa_temp.squeeze()
            bb[:, tt]= bb_temp.squeeze()

            fx, fu = dyn.derivatives(xx[:,tt,kk], uu[:,tt,kk])[:2]

            AA_temp = fx.T
            BB_temp = fu.T
            
            AA[:, :, tt] = AA_temp.squeeze()
            BB[:, :, tt] = BB_temp.squeeze()

            lmbd_temp  = fx@lmbd[:,tt+1,kk][:,None] + aa_temp
            lmbd[:,tt,kk] = lmbd_temp.squeeze()


        # integration forward in time
        for tt in range(TT-1):
            bb_temp = cst.stagecost(xx[:,tt, kk], uu[:,tt,kk], xx_ref[:,tt], uu_ref[:,tt], phy_limit,kk,epsylon)[2]
            nabla_J_temp = fu@lmbd[:,tt+1,kk][:,None] + bb_temp
            nabla_J[:,tt] =nabla_J_temp.squeeze()
            QQ_temp, RR_temp = cst.stagecost(xx[:,tt, kk], uu[:,tt,kk], xx_ref[:,tt], uu_ref[:,tt], phy_limit,kk,epsylon)[3:5]
            Hxx= dyn.hessian(xx[:,tt,kk], uu[:,tt,kk])[0]
            Huu= dyn.hessian(xx[:,tt,kk], uu[:,tt,kk])[1]
            Hxu= dyn.hessian(xx[:,tt,kk], uu[:,tt,kk])[2]        
            QQ[:, :, tt] = QQ_temp
            RR[:, :, tt] = RR_temp

            # # # Introduction of the hessians
            if kk > 20:
                sumHx = 0
                sumHu = 0
                sumHxu = 0

                for j in range(ns):
                    sumHx += Hxx[j,:,:]*lmbd[j, tt+1, kk]
                    sumHu += Huu[j,:,:]*lmbd[j, tt+1, kk]
                    sumHxu += Hxu[j,:,:]*lmbd[j, tt+1, kk]

                QQ[:, :, tt] = QQ[:, :, tt] + sumHx
                RR[:, :, tt] = RR[:, :, tt] + sumHu
                SS[:, :, tt] = sumHxu
            
        
        qqT_temp, QQT_temp=  cst.termcost(xx[:,-1,kk], xx_ref[:,-1])[1:]
        qqT=qqT_temp.squeeze()
        QQT=QQT_temp.squeeze()


        delta_uu = solv.ltv_LQR(AA, BB, QQ, RR, SS, QQT, TT, delta_x0, aa, bb, qqT)[3]
        for t in range(TT):
            descent[kk] += nabla_J[:,t].T@delta_uu[:,t]


            
        ##################################
        # Armijo for stepsize selection
        ##################################
        stepsize = 0.7
        cc = 0.5
        beta = 0.7
        armijo_maxiters = 20

        for i in range(armijo_maxiters):
            for t in range(0,TT):
                uu_temp[:,t] = uu[:, t, kk] + stepsize*delta_uu[:,t]
            JJ_temp = cst.full_cost(xx_init,  uu_temp, xx_ref, uu_ref,phy_limit,kk,epsylon)[0]

            if(JJ_temp > (JJ[kk]+cc*stepsize*descent[kk])):
                stepsize = beta*stepsize
            else:
                break


        print("stepsize =", stepsize)
        
        ############################
        # Update the current solution
        ############################
        uu[:,:,kk+1] = uu[:, :, kk] + stepsize*delta_uu
        xx[:,:,kk+1] = dyn.full_dyn(xx_init,uu[:,:,kk+1])

        print('Iter = {}\t Descent = {}\t Cost = {}'.format(kk, descent[kk], JJ[kk]))
        
        ############################
        # Termination condition
        ############################

        if np.linalg.norm(descent[kk]) <= Stop:
            max_iters = kk
            break


    xx_star = xx[:,:,max_iters-1]       # optimal state
    uu_star = uu[:,:,max_iters-1]       # optimal input
    uu_star[:,-1] = uu_star[:,-2]       # for plot

    ###############################
    # STEP 3 - TRAJECTORY TRACKING
    ###############################

    if(step==3):

        QQT_temp =  cst.termcost(xx[:,-1,kk], xx_ref[:,-1])[2]
        QQT = QQT_temp.squeeze()

        for tt in range(TT):
            fx, fu = dyn.derivatives(xx_star[:,tt], uu_star[:,tt])[:2]
            AA_temp = fx.T
            BB_temp = fu.T
            AA_opt[:, :, tt] = AA_temp.squeeze()
            BB_opt[:, :, tt] = BB_temp.squeeze()

            QQ_temp, RR_temp = cst.stagecost(xx_star[:,tt], uu_star[:,tt], xx_ref[:,tt], uu_ref[:,tt],phy_limit,kk,epsylon)[3:5]
            QQ[:, :, tt]= QQ_temp
            RR[:, :, tt]= RR_temp

        SS = np.zeros((ni, ns, TT))

        KK_opt = solv.ltv_LQR(AA_opt, BB_opt, QQ, RR, SS, QQT, TT, delta_x0)[0]

        #tracking trajectory
        xx_track[:,0] = xx_init

        for tt in range(TT-1):
            uu_track[:,tt] = uu_star[:,tt] + KK_opt[:,:,tt]@(xx_track[:,tt]-xx_star[:,tt])
            xx_track[:,tt+1] = dyn.dynamics(xx_track[:,tt],uu_track[:,tt])

        trj, ref = xx_track, xx_star
    else:
        trj, ref = xx_star, xx_ref

    return ply.Trajectory(
        name=STEP_NAMES[step - 1],
        time=np.arange(TT),
        height=trj[1],
        orientation=trj[2],
        reference=ref[1],
    )


if __name__ == "__main__":
    STEP_NAMES = ["Task 1", "Task 2", "Task 3"]
    game = ply.PlaneGame(STEP_NAMES, compute_trajectory, resolution=(1000, 800))
    game.run()
