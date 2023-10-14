#  Laura Calzoni 0001058438 
#  Jacopo Merlo Pich 0001038025 
#  Francesca Paradiso 0001037825

import numpy as np
import math as m
import datetime

from stable_baselines3 import DQN
from stable_baselines3.common.logger import configure 

# Wandb callback and log
from envs.sanitizer_energy import GridWorldObs
from stable_baselines3.common.preprocessing import is_image_space


episode_horizon = 300
num_train_episodes = 15000


env = GridWorldObs(episode_horizon)  

#Create Agent
model = DQN(
policy = "MlpPolicy", 
env = env,
learning_starts = 500000, 
learning_rate = 0.0001,
batch_size = 128, 
train_freq = (25, "step"),
target_update_interval=1,
gradient_steps = -1,
gamma = 0.9,
exploration_fraction=0.3,
verbose = 1) 
    
now = datetime.datetime.now()
formatted_date = now.strftime("%Y-%m-%d_%H-%M-%S")

# # Create Logger
logs_folder_path = f"data/logs/{formatted_date}"
new_logger = configure(logs_folder_path, ["stdout", "csv", "tensorboard"])
model.set_logger(new_logger)

# Train the agent   
try:  
   model.learn(total_timesteps=episode_horizon*num_train_episodes,progress_bar=True,reset_num_timesteps=False)
except KeyboardInterrupt:
   pass

# Save the agent and delete agent
model.save("data/models/dpn_energize")
