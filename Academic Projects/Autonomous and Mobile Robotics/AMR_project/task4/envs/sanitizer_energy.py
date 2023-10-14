 
#  Laura Calzoni 0001058438 
#  Jacopo Merlo Pich 0001038025 
#  Francesca Paradiso 0001037825

import gym
from gym import spaces
import numpy as np
import cv2
import random
import math
from collections import deque

class GridWorldObs(gym.Env):
    def __init__(self,timeout):

        self.passed=0
        self.tried=0
        self.min_value = 10*10**-3
        self.timeout = timeout
        self.n_obstacles = random.randint(3,5)
        self.t=0
        x = random.randint(15,20)
        y = random.randint(15,20)
        self.grid_size = (x, y)
        self.offsets = self.get_offsets(20)
        self.grid = np.zeros(self.grid_size)
        self.path = deque(maxlen=5)
        self.put_obstacles()
        self.spawn_agent()
        self.update_energy_map()
        self.path.append(self.agent_pos)
        self.reward=0
        self.counter=0
        self.counter2=0
        self.done = False
        self.time_penalty = 1
        self.action_space = spaces.Discrete(5)
        self.observation_space = spaces.Box(low=-2, high=1, shape=(np.shape(self.offsets)[0],)) #np.shape(self.offsets))


    def reset(self):
        self.t=0
        self.tried+=1
        self.n_obstacles = random.randint(3,5)
        x = random.randint(15,20)
        y = random.randint(15,20)
        self.grid_size = (x, y)
        self.grid = np.zeros(self.grid_size)
        self.path = deque(maxlen=5)
        self.put_obstacles()
        self.spawn_agent()
        self.update_energy_map()
        self.path.append(self.agent_pos)
        self.reward=0
        self.counter=0
        self.counter2=0
        self.done = False
        return self.get_obs(self.offsets)
    
    def check_matrix(self,matrix):
    
        #Check if all elements in a matrix are either 1 or -2.
    
        x,y = self.grid_size
        n = x*y
        minimum = np.round(n/100*5) # We set up a tollerance of 5%
        count = 0

        for row in matrix:
            for element in row:
                if element < self.min_value and element != -2:
                    count+=1
        if count<=minimum:
            return True
        return False


    def spawn_agent(self):
        flag = True

        while flag:
            x = random.randint(0,self.grid_size[0]-1)
            y = random.randint(0,self.grid_size[1]-1)

            agent_pos = (x,y)

            if self.grid[agent_pos] != -2:

                self.agent_pos = agent_pos
                flag=False
            
    def put_obstacles(self):

        # Generate n random indices
        indices = np.random.randint(0, self.grid_size[0]*self.grid_size[1], size=self.n_obstacles)
        rows = indices // self.grid_size[1]
        cols = indices % self.grid_size[1]

        # Set the randomly selected elements to a certain number
        value_to_set = -2  # Example value to set
        for r, c in zip(rows, cols):
            self.grid[r, c] = value_to_set

    def pixels_in_shadow(self):
       
        obstacle_map = np.where(self.grid == -2, 1, 0)

        obstacles = []
        for i in range(len(obstacle_map)):
            for j in range(len(obstacle_map[i])):
                if obstacle_map[i][j] == 1:
                    obstacles.append((i, j))
        
        # know we have a list with the obstacles positions, now for
        # each position i have tu calculate the ray of the shadow

        dark = []
        k=0.5 # coefficient to make the ray centered in the pixel
        
        for obstacle in obstacles: 

            if self.agent_pos[1]!=obstacle[1]:
                m = ((obstacle[0]+k) - (self.agent_pos[0]+k))/((obstacle[1]+k) - (self.agent_pos[1]+k))
                q = (self.agent_pos[0]+k)-(self.agent_pos[1]+k)*m

            if self.agent_pos[1]<obstacle[1]:

                for x in range(obstacle[1]+1,self.grid_size[1]):
                    xp = x+k
                    y = math.floor(m*xp+q)
                    if y<self.grid_size[0] and y>=0:                      
                        dark.append((y,x))
                
            if self.agent_pos[1]>obstacle[1]:

                for x in range(obstacle[1]-1,-1,-1):
                    xp = x+k
                    y = math.floor(m*xp+q)
                    if y<self.grid_size[0] and y>=0:                     
                        dark.append((y,x))

            if self.agent_pos[0]>obstacle[0] and self.agent_pos[1]==obstacle[1]:

                for y in range(obstacle[0]-1,-1,-1):
                    if y<self.grid_size[0] and y>=0:                  
                        dark.append((y,obstacle[1]))

            if self.agent_pos[0]<obstacle[0] and self.agent_pos[1]==obstacle[1]:

                for y in range(obstacle[0]+1,self.grid_size[0]):
                    dark.append((y,obstacle[1]))
        
        return dark


            
    def get_next_pos(self,action):
        if action == 0: # move up
            return (self.agent_pos[0]-1, self.agent_pos[1])
        elif action == 1: # move right
            return (self.agent_pos[0], self.agent_pos[1]+1)
        elif action == 2: # move down
            return (self.agent_pos[0]+1, self.agent_pos[1])
        elif action == 3: # move left
            return (self.agent_pos[0], self.agent_pos[1]-1)
        elif action == 4: # stay in posotion
            return (self.agent_pos[0], self.agent_pos[1])
    
    
    def get_offsets(self,radius):

        # Star
        # return [
        #     (r * x, r * y)
        #     for r in range(1, radius + 1)
        #     for x in range(-1, 2)
        #     for y in range(-1, 2)
        #     if x != 0 or y != 0
        # ]
    
        # Rhombus
        return [
        (x, y)
        for x in range(-radius, radius + 1)
        for y in range(abs(x) - radius, radius - abs(x) + 1)
        if x != 0 or y != 0
        ]

        # Square
        # return [
        # (x, y)
        # for x in range(-radius, radius + 1)
        # for y in range(-radius, radius + 1)
        # if x != 0 or y != 0
        # ]
    

    def get_obs(self,offsets):

        x, y = self.agent_pos 
        max_x, max_y = self.grid.shape

        obs = np.zeros(len(offsets)) # default cosnidered as sanitized
        for i, (ox, oy) in enumerate(offsets):
            nx = x + ox
            ny = y + oy

            if nx not in range(0, max_x) or ny not in range(0, max_y) or self.grid[nx,ny] == -2 :
                # Outside the grid
                obs[i] = -2
                continue
            
            if self.grid[nx,ny]>= self.min_value: 
                # cell sanitized
                obs[i] = -1
                continue            

            if self.grid[nx, ny] < self.min_value: 
                # not sanitized
                obs[i] = 1
            
            # if (nx, ny) in self.path:
            #     #path 
            #     obs[i] = 0


        return obs
    

    def energy_value(self,x,y):

        Pl = 100*10**-6
        unit = 0.20

        energy = Pl/((unit*(x-self.agent_pos[0]))**2+(unit*(y-self.agent_pos[1]))**2)

        return energy


    def update_energy_map(self):

        unsanitized = False

        dark = self.pixels_in_shadow()

        for i in range(self.grid_size[0]):
            for j in    range(self.grid_size[1]):
                if (i,j)!=self.agent_pos and self.grid[i,j]!=-2:
                    if (i,j) not in dark:
                        if self.grid[i,j] < self.min_value:
                            unsanitized=True

                        self.grid[i,j] += self.energy_value(i,j)
                        
                        if self.grid[i,j] >= self.min_value and unsanitized==True:
                            self.reward += 1
                            unsanitized=False
                        else:
                            unsanitized=False
                    

    
    
    def step(self, action):

        self.t+=1
        if self.t>self.timeout:
            self.done=True

        self.reward = 0
        next_pos = self.get_next_pos(action)
    
        if next_pos[0] < 0 or next_pos[0] >= self.grid_size[0] or next_pos[1] < 0 or next_pos[1] >= self.grid_size[1] or self.grid[next_pos]==-2:
            # agent hit wall or hit an obstacle, stay in place and get negative reward
            self.reward += -10
            self.done = True

        else:
            
            # In order to break the simulation if i stuck in a loop 
            if next_pos in self.path:
                if self.counter2>= 30:
                    self.done=True
                self.counter2 += 1
            elif next_pos != self.agent_pos:
                self.counter2=0

            self.agent_pos = next_pos
            self.path.append(self.agent_pos)
        
        self.update_energy_map()
            

            
        if self.check_matrix(self.grid):
            # all cells have been visited, end episode
            self.passed+=1
            print("Passed: ",self.passed,"/",self.tried)
            self.done = True
        
        obs = self.get_obs(self.offsets)

        return obs, self.reward, self.done, {}
    

    def render(self, mode="human"):

        zeros = np.zeros_like(self.grid)
        sanitized = np.clip((1/self.min_value) * self.grid, 0, 1)
        image = np.stack([zeros, sanitized, zeros], axis=2)
        image[self.grid == -2] = (1, 0, 0)
        image[self.agent_pos] = (0, 0, 1)

        self.units = 20
        image = (image * 255).astype(np.uint8)
        image = cv2.resize(
            image,
            (self.units * image.shape[1], self.units * image.shape[0]),
            interpolation=cv2.INTER_NEAREST,
        )

        if mode == "rgb_array":
            return image  # return RGB frame suitable for video
        elif mode == "human":
            # pop up a window and render
            cv2.imshow("AMR Sanitizer Project", image)
            cv2.waitKey(10)
        else:
            super().render(mode=mode)  # just raise an exception
