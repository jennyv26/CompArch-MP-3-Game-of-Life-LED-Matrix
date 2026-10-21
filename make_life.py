from math import *


def clip(x, lower, upper):
    x = x if x >= lower else lower
    x = x if x <= upper else upper
    return x

def H2R(x):
    return 0.5 + clip(cos(x), -0.5, 0.5)

def H2G(x):
    return 0.5 + clip(cos(x - 2 * pi / 3), -0.5, 0.5)

def H2B(x):
    return 0.5 + clip(cos(x - 4 * pi / 3), -0.5, 0.5)


red_file = open('life/red.txt', 'w')
green_file = open('life/green.txt', 'w')
blue_file = open('life/blue.txt', 'w')

size = 8
frames = 32

# grid = [
#     "00000000",   # row 0
#     "00000000",   # row 1
#     "00000000",   # row 2
#     "00010000",   # row 3
#     "00001000",   # row 4
#     "00111000",   # row 5
#     "00000000",   # row 6
#     "00000000",   # row 7
# ]


for t in range(frames):
    hue = 2 * pi * (t/frames)
    r = int(40 * H2R(hue))
    g = int(40 * H2G(hue))
    b = int(40 * H2B(hue))

    for pixel in range(64):
                red_file.write(f'{r:02X}\n')
                green_file.write(f'{g:02X}\n')
                blue_file.write(f'{b:02X}\n')



red_file.close()
green_file.close()
blue_file.close()

