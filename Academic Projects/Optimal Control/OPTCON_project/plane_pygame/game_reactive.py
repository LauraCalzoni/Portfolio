from dataclasses import dataclass
from functools import partial
from typing import Callable

import numpy as np
import pygame
from . import pygame_ui as ui


@dataclass
class Trajectory:
    name: str
    time: np.ndarray
    height: np.ndarray
    orientation: np.ndarray
    reference: np.ndarray


class _Plane(pygame.sprite.Sprite):
    def __init__(self, image: pygame.surface.Surface) -> None:
        super().__init__()
        self.original_image = image
        self.image = self.original_image
        self.rect = self.image.get_rect()

    def update(self, center: tuple[int, int], angle: float) -> None:
        self.image = pygame.transform.rotate(self.original_image, angle)
        self.rect = self.image.get_rect()
        self.rect.center = center


class PlaneGame(ui.Game):
    def __init__(
        self,
        trajectory_labels: list[str],
        get_trajectory_function: Callable[[int], Trajectory],
        resolution: tuple[int, int] = (800, 600),
        fps: int = 0,
    ) -> None:
        # SETTINGS
        speed = 0.2
        pad_bottom = 0.2
        pad_left = 0.1
        pad_top = 0.1
        pad_right = 0.1
        ticks_font_scale = 0.025
        title_font_scale = 0.05
        line_width_scale = 3e-3
        grid_width_scale = 0
        plane_scale_factor = 0.1

        axis_color = "black"
        trajectory_color = "red"
        reference_color = "darkgreen"
        grid_color = "gray"
        default_color = (215, 215, 215)

        font_name = "microsoftnewtailue"

        # background_file = "./assets/background.jpg"
        background_file = None
        sky_file = "./assets/sky.jpg"
        switch_on_file = "./assets/switch_on.png"
        switch_off_file = "./assets/switch_off.png"
        plane_image_file = "./assets/aircraft.png"
        pause_file = "./assets/pause.png"
        play_file = "./assets/play.png"
        logo_file = "./assets/logo.png"
        logo_icon_file = "./assets/logo.png"

        title = "Aircraft Project - Laura Calzoni - Jacopo Merlo Pich - Francesca Paradiso"
        x_label = "Time (ms)"
        y_label = "Height (m)"

        #call the constructor
        super().__init__(resolution, fps, title, logo_icon_file)
        # Save params (assegno all oggetto la funzione che genera la traiettoria)
        self.get_trajectory_function = get_trajectory_function

        # Units from relative to pixel values 
        def to_abs(value: float, ref: int) -> float:
            return value * ref if value < 1 else value

        self.res_x, self.res_y = resolution
        self.pad_bottom = to_abs(pad_bottom, self.res_y)
        self.pad_top = to_abs(pad_top, self.res_y)
        self.pad_left = to_abs(pad_left, self.res_x)
        self.pad_right = to_abs(pad_right, self.res_x)
        ticks_fontsize = int(to_abs(ticks_font_scale, self.res_y))
        title_fontsize = int(to_abs(title_font_scale, self.res_y))
        self.line_width = 1 + int(to_abs(line_width_scale, self.res_y))
        self.grid_width = 1 + int(to_abs(grid_width_scale, self.res_y))

        # Anchors of the draw box
        self.topleft = pygame.Vector2(self.pad_left, self.pad_top)
        self.topright = pygame.Vector2(self.res_x - self.pad_right, self.pad_top)
        self.bottomleft = pygame.Vector2(self.pad_left, self.res_y - self.pad_bottom)
        self.bottomright = pygame.Vector2(self.res_x - self.pad_right, self.res_y - self.pad_bottom)

        # Style of the graphics
        self.axis_color = axis_color
        self.trajectory_color = trajectory_color
        self.reference_color = reference_color
        self.grid_color = grid_color

        #Load images and holds errors if it occurs
        def safe_load(filename: str | None) -> pygame.surface.Surface:
            if filename is None:
                default_surface = pygame.Surface((100, 100))
                default_surface.fill(default_color)
                return default_surface
            try:
                return pygame.image.load(filename)
            except FileNotFoundError as e:
                print("[ERROR] -", e, "- Creating default red surface")
                default_surface = pygame.Surface((100, 100))
                default_surface.fill("red")
                return default_surface

        sky = safe_load(sky_file)
        logo = safe_load(logo_file)
        play = safe_load(play_file)
        pause = safe_load(pause_file)
        switch_on = safe_load(switch_on_file)
        switch_off = safe_load(switch_off_file)
        background = safe_load(background_file)
        plane_image = safe_load(plane_image_file)

        # Units definitions to allign buttons
        bottom_units = self.pad_bottom / 6
        play_pause_scale = 0.7 * min(self.pad_top, self.pad_right)
        logo_scale = 10 * play_pause_scale
        plne_factor = plane_scale_factor * self.res_x / plane_image.get_width()
        plane_size = plne_factor * pygame.Vector2(plane_image.get_size())

        # Fonts
        self.tick_font = pygame.font.SysFont(font_name, ticks_fontsize)
        self.title_font = pygame.font.SysFont(font_name, title_fontsize)
        self.loading_font = pygame.font.SysFont(font_name, 3 * title_fontsize)

        # Rescaling images
        play = pygame.transform.scale(play, (play_pause_scale, play_pause_scale))
        pause = pygame.transform.scale(pause, (play_pause_scale, play_pause_scale))
        logo = pygame.transform.scale(logo, (logo_scale, logo_scale))
        plane_image = pygame.transform.scale(plane_image, plane_size)
        self.background = pygame.transform.scale(background, self.resolution)
        self.sky = pygame.transform.scale(sky, self.bottomright - self.topleft)

        # Creating containers
        self.plane_group = pygame.sprite.GroupSingle(_Plane(plane_image))
        self.tick_lables_group = pygame.sprite.Group()
        self.title_lable_group = pygame.sprite.GroupSingle()
        self.trajectory_points: list[pygame.math.Vector2] = []
        self.reference_points: list[pygame.math.Vector2] = []
        self.x_ticks: list[tuple[pygame.math.Vector2, pygame.math.Vector2]] = []
        self.y_ticks: list[tuple[pygame.math.Vector2, pygame.math.Vector2]] = []
        self.data_loaded = False
        self.running = False

        # Creating Items (Group of buttons to switch traj.)
        self.trajectory_selector = ui.RadioButtonsGroup(
            (2 * self.pad_left, self.res_y - 4 * bottom_units), #top left 
            (self.res_x - 2 * self.pad_left, self.res_y - 2 * bottom_units), #bottom right
            switch_on,
            switch_off,
            horizontal=True,
            labels=trajectory_labels,
            font=self.tick_font,
            label_color=self.axis_color,
            label_align=ui.AlignMode.BOTTOM,
            commands=[partial(self.set_plot_data, tr_id) for tr_id in range(len(trajectory_labels))], # associate functions to the buttons 
        )

        # Buttons velocity an for the legend
        def color_box(color, border=10) -> pygame.surface.Surface:
            box = pygame.Surface((100, 100))
            box.fill("black")
            col = pygame.Surface((100 - 2 * border, 100 - 2 * border))
            col.fill(color)
            box.blit(col, (border, border))
            return box

        #Radio buttons for speed
        self.speed_selector = ui.RadioButtonsGroup(
            (self.res_x - self.pad_left - bottom_units, self.res_y - 4 * bottom_units),
            (self.res_x - self.pad_left, self.res_y - bottom_units),
            color_box("green"),
            color_box("red"),
            horizontal=False,
            labels=["x2", "x1", "x0.5"],
            font=self.tick_font,
            label_color=self.axis_color,
            label_align=ui.AlignMode.RIGHT,
            commands=[partial(self.set_speed, s * speed) for s in [2, 1, 0.5]],
        )

        #Set up play button
        self.play_button = ui.ToggleButton(
            anchor=(self.pad_left, self.res_y - 3 * bottom_units), image=play, image_b=pause
        ).register_command(self.set_running)

        self.buttons = ui.ButtonsGroup(
            self.play_button,
        )

        #Legend 
        tra_lab = self.tick_font.render("Trajectory", True, self.axis_color)
        ref_lab = self.tick_font.render("Reference", True, self.axis_color)
        
        w = max(tra_lab.get_width(), ref_lab.get_width())
        s = self.tick_font.get_linesize()
        tra_sq = pygame.transform.scale(color_box(self.trajectory_color, 5), (s, s))
        ref_sq = pygame.transform.scale(color_box(self.reference_color, 5), (s, s))
        legend = pygame.transform.scale(color_box(default_color, 1), (w + 2.5 * s, 2.75 * s))

        legend.blit(ref_sq, (s / 2, s / 4))
        legend.blit(ref_lab, (2 * s, s / 4))
        legend.blit(tra_sq, (s / 2, 1.5 * s))
        legend.blit(tra_lab, (2 * s, 1.5 * s))
        pos = self.topleft + pygame.Vector2(s, s)

        lx, ly = logo.get_size()
        #Setting the unibo background
        self.background.blit(logo, (self.res_x - (self.pad_left + lx) / 2, (self.pad_top - ly) / 2))
        
        #Stiching labels
        self.labels = pygame.sprite.Group(
            ui.Label(pos, legend, ui.AnchorMode.TOPLEFT),
            ui.Label(
                self.bottomright, self.tick_font.render(x_label,True,self.axis_color),anchor_mode=ui.AnchorMode.BOTTOMLEFT
            ),
            ui.Label(
                self.topleft, self.tick_font.render(y_label,True,self.axis_color), anchor_mode=ui.AnchorMode.BOTTOMLEFT
            ),
        )

        self.speed_selector.select(1)

    # Function passed to play/pause button
    def set_running(self, running: bool):
        if not self.data_loaded:
            print("No data loaded: Press one of the buttons below!")
            self.play_button.swap()
        self.running = not running

    def set_speed(self, speed: float) -> None:
        self.animation_speed = speed

    #Function called by the tasks switch
    def set_plot_data(self, trajectory_id: int):
        self.running = True
        if self.play_button.is_on:
            self.play_button.swap()

        # Loading Screen
        s = pygame.Surface((100, 100))
        s.fill("black")
        s.set_alpha(150)
        s = pygame.transform.scale(s, self.resolution)
        if self.trajectory_selector.selected_button is not None:
            self.trajectory_selector.selected_button.swap()
        self.draw(self.screen)
        self.screen.blit(s, (0, 0))
        loading = self.loading_font.render("Loading...", True, "white")
        w, h = loading.get_size()
        topleft = ((self.res_x - w) / 2, (self.res_y - h) / 2)
        self.screen.blit(loading, topleft)
        pygame.display.flip()
        if self.trajectory_selector.selected_button is not None:
            self.trajectory_selector.selected_button.swap()

        trajectory = self.get_trajectory_function(trajectory_id+1)
        self.data_loaded = True
        print("loading", trajectory.name)
        self.time = 0
        self.tick_lables_group.empty()
        self.trajectory_points.clear()
        self.reference_points.clear()
        self.x_ticks.clear()
        self.y_ticks.clear()
        
        #Setting title
        self.title_lable_group.add(
            ui.Label(
                (self.res_x / 2, self.pad_top / 2),
                self.title_font.render(trajectory.name,True,self.axis_color),
            )
        )

        #For plots
        width, height = self.bottomright - self.topleft
        left, bottom = self.bottomleft

        def _scale(data: np.ndarray, min_data: float, max_data: float) -> np.ndarray:
            return (data - min_data) / (max_data - min_data)

        #scaling data for a good plots
        y_off = 0.02 * max(trajectory.height)
        min_t, max_t = min(trajectory.time), max(trajectory.time)
        min_y, max_y = min(trajectory.height) - y_off, max(trajectory.height) + y_off

        self._t = width * _scale(trajectory.time, min_t, max_t) + left
        self._y = -height * _scale(trajectory.height, min_y, max_y) + bottom
        self._r = -height * _scale(trajectory.reference, min_y, max_y) + bottom
        self._w = np.rad2deg(trajectory.orientation)

        self.plane_group.update((self._t[0], self._y[0]), self._w[0])
        for t, r in zip(self._t, self._r):
            self.reference_points.append(pygame.Vector2(t, r))

        # Ticks generation for the axis numbers
        tick_len = self.res_x / 200
        label_offset = pygame.Vector2(0, self.tick_font.get_linesize() / 2)

        # Tick for x-axis
        num_ticks = 11
        tick_label = lambda tick: f"{round(tick)}"
        for i, tick in enumerate(np.linspace(min_t, max_t + 1, num_ticks)):
            label = tick_label(tick)
            point_ax = self.bottomleft + i * pygame.Vector2(width / (num_ticks - 1), 0)
            tick_end = point_ax + pygame.Vector2(0, tick_len)
            anchor = tick_end + label_offset
            self.tick_lables_group.add(ui.Label(anchor,self.tick_font.render(label,True,self.axis_color)))
            self.x_ticks.append((point_ax, tick_end))

      # Tick for y-axis
        num_ticks = 7
        tick_label = lambda tick: f"{tick:.2f}"
        for i, tick in enumerate(np.linspace(min_y, max_y, num_ticks)):
            label = tick_label(tick)
            point_ax = self.bottomleft - i * pygame.Vector2(0, height / (num_ticks - 1))
            tick_end = point_ax - pygame.Vector2(tick_len, 0)
            anchor = tick_end + label_offset
            self.tick_lables_group.add(
                ui.Label(
                     anchor, self.tick_font.render(label,True,self.axis_color),anchor_mode=ui.AnchorMode.BOTTOMRIGHT
                )
            )
            self.y_ticks.append((point_ax, tick_end))

    # Update all
    def update(self, delta_time: float) -> None: #delta time = time between two ticks to update time invariant
        #Chacking all the buttons if the cursor is on it
        pos = pygame.mouse.get_pos()
        self.buttons.update(pos)
        self.speed_selector.update(pos)
        self.trajectory_selector.update(pos)
        if not self.running:
            return

        #Calculate the time passed * velocity to update time
        prev_time_idx = int(self.time)
        self.time += delta_time * self.animation_speed
        time_idx = int(self.time)
        #To rewind the time for the animation
        if len(self._t) < time_idx:
            self.time = 0
            self.trajectory_points.clear()
            return
        #If no changes are present return 
        if prev_time_idx == time_idx:
            return

        #Loading points from traj. for the instance of time
        t_s = self._t[prev_time_idx:time_idx]
        y_s = self._y[prev_time_idx:time_idx]
        w_s = self._w[prev_time_idx:time_idx]

        #I add the point to the traj. list for the further draw
        for t, y in zip(t_s, y_s):
            self.trajectory_points.append(pygame.Vector2(t, y))
        self.plane_group.update(pygame.Vector2(t_s[-1], y_s[-1]), w_s[-1]) # Plane update on the graph

    def draw(self, screen: pygame.surface.Surface) -> None:
        self.screen = screen #screen for plot
        screen.blit(self.background, (0, 0)) #put grey background
        screen.blit(self.sky, self.topleft) #put the blue sky

        right, top = self.topright

        # Drawing ticks and grid (x)
        for a, b in self.x_ticks:
            pygame.draw.line(screen, self.grid_color, a, (a.x, top), self.grid_width)
            pygame.draw.line(screen, self.axis_color, a, b, self.line_width)
        #(y)
        for a, b in self.y_ticks:
            pygame.draw.line(screen, self.grid_color, a, (right, a.y), self.grid_width)
            pygame.draw.line(screen, self.axis_color, a, b, self.line_width)
        #axis
        pygame.draw.line(screen, self.axis_color, self.bottomleft, self.topleft, self.line_width)
        pygame.draw.line(screen, self.axis_color, self.bottomleft, self.bottomright, self.line_width)

        #others
        self.labels.draw(screen)
        self.buttons.draw(screen)
        self.speed_selector.draw(screen)
        self.trajectory_selector.draw(screen)

        self.tick_lables_group.draw(screen)
        self.title_lable_group.draw(screen)

        if self.data_loaded:
            # Drawing the reference
            if len(self.reference_points) > 1:
                pygame.draw.lines(screen, self.reference_color, False, self.reference_points, self.line_width)
            # Drawing the traj.
            if len(self.trajectory_points) > 1:
                pygame.draw.lines(screen, self.trajectory_color, False, self.trajectory_points, self.line_width)
            # Drawing the airplane
            self.plane_group.draw(screen)

    # Event Handler
    def handle_event(self, event: pygame.event.Event) -> None:
        # Standard event on pygame
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                self.quit()
        # Mouse click event
        if event.type == pygame.MOUSEBUTTONDOWN:
            if event.button == pygame.BUTTON_LEFT:
                self.buttons.click()
                self.speed_selector.click()
                self.trajectory_selector.click()
