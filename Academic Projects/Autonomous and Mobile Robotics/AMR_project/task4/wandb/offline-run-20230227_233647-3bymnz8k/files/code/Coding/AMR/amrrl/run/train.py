import numpy as np
import math as m

from stable_baselines3 import DQN , PPO
from stable_baselines3.common.logger import configure 

# Wandb callback and log
import wandb
from wandb.integration.sb3 import WandbCallback
 
from envs.parabolic import ParabolicEnv
from envs.task4 import ProjEnv
  
episode_horizon = 100
num_train_episodes = 700
  
# Wandb initialization
run = wandb.init(  
            sync_tensorboard=True, 
            project="prabolic",
            monitor_gym=True, # automatically upload gym environements' videos
            save_code=True,
) 
wand_cb = WandbCallback(
   model_save_path=f"data/wandb/{run.id}",
   gradient_save_freq=1,
   verbose = 2)

# Create Environment
# env = ParabolicEnv(
#    time_horizon = episode_horizon,
#    delta_angle= m.pi/100,
#    debug = True
#    )  

# Create Agent
# model = DQN(
#    policy = "MlpPolicy", 
#    env = env, 
#    learning_rate = 0.001,
#    batch_size = 128,
#    train_freq = (10, "step"),
#    gradient_steps = 20,
#    gamma = 0.99,
#    verbose = 1) 

env = ProjEnv(
   )  
# Create Agent
model = PPO(
   policy = "CnnPolicy", 
   env = env, 
   learning_rate = 0.001,
   batch_size = 128,
   train_freq = (10, "step"),
   gradient_steps = 20,
   gamma = 0.99,
   verbose = 1) 
  

# Create Logger
logs_folder_path = "data/logs"
new_logger = configure(logs_folder_path, ["stdout", "csv", "tensorboard"])
model.set_logger(new_logger)

# Train the agent   
model.learn(total_timesteps=episode_horizon*num_train_episodes, callback=wand_cb)

# Save the agent and delete agent
model.save("data/models/dpn")
wandb.finish()