from gym.envs.registration import register
from importlib_metadata import entry_points


register(
   id = 'sanitizer-v0',
   entry_point = 'envs:GridWorld',
   max_episode_steps = 2000,
)