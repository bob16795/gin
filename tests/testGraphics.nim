import unittest

import gin.graphics

test "point class can create from 2":
    var point = InitPoint(0, 1)
    assert point.X == 0
    assert point.Y == 1

test "rectangle class can create from 4":
    var rectangle = InitRectangle(0, 0, 4, 4)
    assert rectangle.X == 0
    assert rectangle.Y == 0
    assert rectangle.Width == 4
    assert rectangle.Height == 4