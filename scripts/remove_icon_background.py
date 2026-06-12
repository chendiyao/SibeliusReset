from collections import deque
from pathlib import Path
import sys

from PIL import Image


def is_background_candidate(pixel):
    r, g, b, _ = pixel
    return r >= 220 and g >= 220 and b >= 220 and max(r, g, b) - min(r, g, b) <= 36


def alpha_for_edge_pixel(pixel):
    r, g, b, _ = pixel
    brightness = (r + g + b) / 3
    if brightness >= 245:
        return 0
    if brightness <= 210:
        return 255
    return int((245 - brightness) / 35 * 255)


def main():
    if len(sys.argv) != 3:
        raise SystemExit("Usage: remove_icon_background.py input.png output.png")

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    image = Image.open(source).convert("RGBA")
    width, height = image.size
    pixels = image.load()

    visited = set()
    queue = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in visited:
            continue
        if x < 0 or y < 0 or x >= width or y >= height:
            continue
        if not is_background_candidate(pixels[x, y]):
            continue

        visited.add((x, y))
        queue.append((x + 1, y))
        queue.append((x - 1, y))
        queue.append((x, y + 1))
        queue.append((x, y - 1))

    for x, y in visited:
        r, g, b, a = pixels[x, y]
        pixels[x, y] = (r, g, b, min(a, alpha_for_edge_pixel((r, g, b, a))))

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)


if __name__ == "__main__":
    main()
