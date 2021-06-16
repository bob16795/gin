import unittest

import gin
import gin/graphics

test "setup inits gl":
    Setup:
        discard

test "main loop ends":
    Loop:
        template update(time: cuint): untyped =
            endLoop

        template draw(time: cuint, context: GraphicsContext): untyped =
            discard