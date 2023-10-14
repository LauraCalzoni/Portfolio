import numpy as np
import cv2


# def get_offsets(radius):
#     return [
#         (x, y)
#         for x in range(-radius, radius + 1)
#         for y in range(abs(x) - radius, radius - abs(x) + 1)
#         if x != 0 or y != 0
#     ]


def get_offsets(radius):
    offsets = []
    for x in range(-radius, radius + 1):
        width = radius - abs(x)
        for y in range(-width, width + 1):
            if x != 0 or y != 0:
                offsets.append((x, y))
    return offsets


# def get_offsets(radius):
#     return [
#         (r * x, r * y)
#         for r in range(1, radius + 1)
#         for x in range(-1, 2)
#         for y in range(-1, 2)
#         if x != 0 or y != 0
#     ]


# def get_offsets(radius):
#     offsets = []
#     for r in range(1, radius + 1):
#         for x in range(-1, 2):
#             for y in range(-1, 2):
#                 if x != 0 or y != 0:
#                     offsets.append((r * x, r * y))
#     return offsets


class Env:
    def __init__(self, max_radius: int) -> None:
        self.grid = np.zeros((2 * max_radius + 1, 2 * max_radius + 1))
        self.agent_pos = max_radius, max_radius
        self.radius = 1
        self.max_radius = max_radius
        self.units = int(200 / self.max_radius) + 1

    def render(self, mode="human"):
        image = np.zeros_like(self.grid)

        a = np.array(self.agent_pos)
        for o in get_offsets(self.radius):
            x, y = a + o
            image[x, y] = 1

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
            cv2.imshow("Game", image)
            cv2.waitKey(0)


env = Env(max_radius=10)
fps = 10


frames = []
while env.radius < env.max_radius:
    frames.append(env.render("rgb_array"))
    env.radius += 1

i = 0
while True:
    img = frames[i]
    i += 1
    img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    image = cv2.putText(
        img,
        f"radius={i}",
        (50, 50),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (0, 255, 0),
        2,
        cv2.LINE_AA,
    )

    cv2.imshow("Observation (Q to quit)", image)
    i %= len(frames)
    if cv2.waitKey(int(1000 / fps)) & 0xFF == ord("q"):
        break
