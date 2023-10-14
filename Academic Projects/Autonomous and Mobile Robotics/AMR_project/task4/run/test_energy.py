#  Laura Calzoni 0001058438 
#  Jacopo Merlo Pich 0001038025 
#  Francesca Paradiso 0001037825

from stable_baselines3 import DQN
from stable_baselines3.common.evaluation import evaluate_policy  

from envs.sanitizer_energy import GridWorldObs
  
episode_horizon = 350
num_test_episodes = 10

# Create Environment
env = GridWorldObs(episode_horizon)

   
# Load the trained agent 
model = DQN.load("data/models/dpn_energize",  env=env, verbose=1)


# Evaluate the agent
mean_reward, std_reward = evaluate_policy(model, model.get_env(), n_eval_episodes=100, render=True)


