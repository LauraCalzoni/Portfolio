from __future__ import annotations
from enum import Enum
import sys

# Solve the resolution mismatch on windows
if sys.platform == "win32":
    import ctypes

    ctypes.windll.user32.SetProcessDPIAware()

import pygame
from abc import ABC
from typing import Callable, Sequence
from typing_extensions import Self
from pygame.color import Color
from pygame.math import Vector2
from pygame.rect import Rect
from pygame.surface import Surface
from pygame.event import Event
from pygame.sprite import Sprite
from pygame.sprite import Group

_Coordinate = tuple[float, float] | Sequence[float] | Vector2
_RgbaOutput = tuple[int, int, int, int]
_ColorValue = Color | int | str | tuple[int, int, int] | list[int] | _RgbaOutput


def _null_fn(*args, **kwargs):
    pass


class Game(ABC):
    def __init__(self, resolution: tuple[int, int], fps: int, caption: str, logo_filename: str | None = None) -> None:
        pygame.init()
        self.resolution = resolution
        self.fps = fps
        self.caption = caption
        self.logo = logo_filename

    def update(self, delta_time: float) -> None:
        pass

    def draw(self, screen: Surface) -> None:
        pass

    def handle_event(self, event: Event) -> None:
        pass

    def handle_pressed(self, pressed: Sequence[bool]) -> None:
        pass

    @staticmethod
    def quit():
        pygame.quit()
        sys.exit()

    def run(self) -> None:
        screen = pygame.display.set_mode(self.resolution)
        clock = pygame.time.Clock()
        pygame.display.set_caption(self.caption)

        if self.logo is not None:
            logo = pygame.image.load(self.logo)
            pygame.display.set_icon(logo)

        while True:
            delta_time = clock.tick(self.fps)
            self.update(delta_time)
            self.draw(screen)
            # pygame.display.set_caption(f"{clock.get_fps():.1f}")
            pygame.display.flip()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.quit()
                self.handle_event(event)

            self.handle_pressed(pygame.key.get_pressed())


class AnchorMode(Enum):
    CENTER = "center"
    TOPLEFT = "topleft"
    TOPRIGHT = "topright"
    BOTTOMLEFT = "bottomleft"
    BOTTOMRIGHT = "bottomright"


class AlignMode(Enum):
    TOP = "top"
    LEFT = "left"
    RIGHT = "right"
    BOTTOM = "bottom"


class AlignedSprite(Sprite):
    def __init__(self, anchor: _Coordinate, anchor_mode: AnchorMode) -> None:
        super().__init__()
        self.anchor = anchor
        self.anchor_mode = anchor_mode

    def align(self) -> None:
        if self.image is None:
            return
        self.rect = self.image.get_rect()
        self.rect.__setattr__(self.anchor_mode.value, self.anchor)


class Label(AlignedSprite):
    def __init__(
        self,
        anchor: _Coordinate,
        image: Surface,
        anchor_mode: AnchorMode = AnchorMode.CENTER,
    ):
        super().__init__(anchor, anchor_mode)
        self.image = image
        self.align()

class Button(AlignedSprite):
    rect: Rect
    image: Surface

    def __init__(
        self,
        anchor: _Coordinate,
        image: Surface,
        image_b: Surface | None = None,
        anchor_mode: AnchorMode = AnchorMode.CENTER,
    ) -> None:
        super().__init__(anchor, anchor_mode)
        self.is_selected = False
        self.image = image
        self.image_2 = image_b or image

        self.align()
        self.command = _null_fn

    def on_hover_enter(self) -> None:
        pass

    def on_hover_exit(self) -> None:
        pass

    def on_click(self) -> None:
        pass

    def register_command(self, command: Callable[[], None]) -> Self:
        self.command = command
        return self

    def swap(self):
        self.image, self.image_2 = self.image_2, self.image
        self.align()

    def update(self, pos: tuple[float, float]) -> None:
        if self.rect.collidepoint(pos):
            if not self.is_selected:
                self.is_selected = True
                self.on_hover_enter()
        elif self.is_selected:
            self.is_selected = False
            self.on_hover_exit()


class HoverButton(Button):
    """Button with hover animation.
    Executes commands without arguments.
    Switches between the images when the mouse is on it.
    """

    def on_click(self):
        self.command()

    def on_hover_enter(self):
        self.swap()

    def on_hover_exit(self) -> None:
        self.swap()


class RadioButton(Button):
    def __init__(
        self,
        anchor: _Coordinate,
        image: Surface,
        image_b: Surface | None = None,
        anchor_mode: AnchorMode = AnchorMode.CENTER,
    ) -> None:
        self.is_on = False
        super().__init__(anchor, image, image_b, anchor_mode)

    def swap(self):
        super().swap()
        self.is_on = not self.is_on

    def on_click(self) -> None:
        self.swap()
        self.command()


class ToggleButton(RadioButton):
    """Two state Button.
    Execute commands with one boolean argument, that is the state of the button.
    Switches between the images when clicked.
    """

    def register_command(self, command: Callable[[bool], None]) -> Self:
        return super().register_command(lambda: command(self.is_on))


class ButtonsGroup(Group):
    def __init__(self, *buttons: Button) -> None:
        self.buttons = buttons
        super().__init__(*buttons)

    def on_click(self, button: Button) -> None:
        button.on_click()

    def click(self):
        for button in self.buttons:
            if button.is_selected:
                self.on_click(button)
                break


class RadioButtonsGroup(ButtonsGroup):
    buttons: list[RadioButton]

    def __init__(
        self,
        topleft: _Coordinate,
        bottom_right: _Coordinate,
        image_on: pygame.surface.Surface,
        image_off: pygame.surface.Surface,
        horizontal: bool = True,
        num_buttons: int | None = None,
        labels: list[str] | None = None,
        font: pygame.font.Font | None = None,
        label_align: AlignMode = AlignMode.TOP,
        label_color: _ColorValue = "black",
        label_back_color: _ColorValue | None = None,
        commands: list[Callable[[], None]] | None = None,
    ) -> None:
        topleft = pygame.Vector2(topleft)  # type: ignore
        bottom_right = pygame.Vector2(bottom_right)  # type: ignore

        if num_buttons is None:
            if commands is None:
                raise ValueError("Specify list of commands or number of buttons")
            else:
                num_buttons = len(commands)
        if commands is None:
            commands = [_null_fn for _ in range(num_buttons)]
        if len(commands) != num_buttons:
            raise ValueError("Not enough commands for the buttons")

        def rescale(img: pygame.surface.Surface) -> pygame.surface.Surface:
            width, heigth = bottom_right - topleft
            w, h = img.get_width(), img.get_height()
            factor = heigth / h if horizontal else width / w
            n_w = w * factor if horizontal else width
            n_h = heigth if horizontal else h * factor
            return pygame.transform.scale(img, (n_w, n_h))

        image_on = rescale(image_on)
        image_off = rescale(image_off)

        img_center = pygame.math.Vector2(image_on.get_rect().center)
        start = topleft + img_center
        stop = bottom_right - img_center
        width, heigth = stop - start
        if horizontal:
            offset = pygame.math.Vector2(width / (num_buttons - 1), 0)
        else:
            offset = pygame.math.Vector2(0, heigth / (num_buttons - 1))

        buttons = [
            RadioButton(start + i * offset, image_off, image_on).register_command(command)
            for i, command in enumerate(commands)
        ]

        super().__init__(*buttons)
        self.selected_button: RadioButton | None = None
        if labels is not None:
            if font is None:
                raise ValueError("Need a Font to render labels")
            w, h = image_on.get_size()
            f = font.get_linesize()
            match label_align:
                case AlignMode.RIGHT:
                    label_offset = pygame.Vector2(0.6 * w, -f / 2)
                    anchor_mode = AnchorMode.TOPLEFT
                case AlignMode.LEFT:
                    label_offset = pygame.Vector2(-0.6 * w, -f / 2)
                    anchor_mode = AnchorMode.TOPRIGHT
                case AlignMode.TOP:
                    label_offset = pygame.Vector2(0, -0.6 * w - f / 2)
                    anchor_mode = AnchorMode.CENTER
                case AlignMode.BOTTOM:
                    label_offset = pygame.Vector2(0, 0.6 * w + f / 2)
                    anchor_mode = AnchorMode.CENTER
                case _:
                    label_offset = pygame.Vector2()
                    anchor_mode = AnchorMode.CENTER

            self.add(
                [
                    Label(
                        anchor=start + i * offset + label_offset,
                        image = font.render(label,True,label_color,label_back_color),
                        anchor_mode=anchor_mode,
                    )
                    for i, label in enumerate(labels)
                ]
            )

    # Click of the button
    def on_click(self, button: RadioButton) -> None:
        if button.is_on:
            return
        button.on_click()
        if self.selected_button is not None:
            self.selected_button.swap()
        self.selected_button = button
    # To select a default value
    def select(self, button_idx: int):
        self.on_click(self.buttons[button_idx])
